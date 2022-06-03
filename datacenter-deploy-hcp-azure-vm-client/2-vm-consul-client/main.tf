data "azurerm_resource_group" "selected" {
  name = var.azurerm_resource_group
}

data "hcp_hvn" "selected" {
  hvn_id = data.hcp_consul_cluster.selected.hvn_id
}

data "hcp_consul_cluster" "selected" {
  cluster_id = var.hcp_consul_cluster_id
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = data.hcp_consul_cluster.selected.id
}

# Create Network Security Group and rule
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow_ssh"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.selected.name
  network_security_group_name = var.azurerm_nsg
}

resource "azurerm_network_security_rule" "hcp_consul_serf_tcp" {
  name                        = "Consul LAN Serf (tcp)"
  priority                    = 201
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8301"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.selected.name
  network_security_group_name = var.azurerm_nsg
}

resource "azurerm_network_security_rule" "hcp_consul_serf_udp" {
  name                        = "Consul LAN Serf (udp)"
  priority                    = 202
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "8301"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.selected.name
  network_security_group_name = var.azurerm_nsg
}

resource "azurerm_network_security_rule" "allow_egress" {
  name                        = "egress-internet"
  priority                    = 203
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.selected.name
  network_security_group_name = var.azurerm_nsg
}

# By default if the user doesn't disable it we create an asg
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-client-ip"
  location            = data.azurerm_resource_group.selected.location
  resource_group_name = data.azurerm_resource_group.selected.name
  allocation_method   = "Static"

  tags = {
    environment = "Development"
  }
}

resource "azurerm_network_interface" "client_nic" {
  name                = "${var.prefix}-client-nic"
  location            = data.azurerm_resource_group.selected.location
  resource_group_name = data.azurerm_resource_group.selected.name

  ip_configuration {
    name                          = "${var.prefix}-ip-config"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

data "azurerm_network_security_group" "selected" {
  name                = var.azurerm_nsg
  resource_group_name = data.azurerm_resource_group.selected.name
}

resource "azurerm_network_interface_security_group_association" "hcp_consul" {
  network_interface_id      = azurerm_network_interface.client_nic.id
  network_security_group_id = data.azurerm_network_security_group.selected.id
}

resource "random_string" "random" {
  length  = 16
  special = false
  upper   = false
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "consul_client" {
  count                 = 1
  name                  = "consul-client-${count.index}-${random_string.random.id}"
  location              = data.azurerm_resource_group.selected.location
  resource_group_name   = data.azurerm_resource_group.selected.name
  network_interface_ids = [azurerm_network_interface.client_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  admin_username                  = "ubuntu"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    setup = base64gzip(templatefile("${path.module}/scripts/setup.sh", {
      consul_ca        = data.hcp_consul_cluster.selected.consul_ca_file
      consul_config    = data.hcp_consul_cluster.selected.consul_config_file
      consul_acl_token = hcp_consul_cluster_root_token.token.secret_id,
      consul_version   = data.hcp_consul_cluster.selected.consul_version,
      consul_service = base64encode(templatefile("${path.module}/scripts/service", {
        service_name = "consul",
        service_cmd  = "/usr/bin/consul agent -data-dir /var/consul -config-dir=/etc/consul.d/",
      })),
      vpc_cidr = data.hcp_hvn.selected.cidr_block
    })),
  }))

  tags = {
    Name = "hcp-consul-client-${count.index}"
  }
}
