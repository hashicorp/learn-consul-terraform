#!/bin/bash

#Utils
sudo apt-get install unzip

#Download Consul
curl --silent --remote-name https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

#Install Consul
unzip consul_${consul_version}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

#Create Consul User
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

#Create Systemd Config
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/server.hcl
[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=always
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

#Create config dir
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/server.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/server.hcl

#Create certificate file
sudo touch /etc/consul.d/consul-agent-ca.pem
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul-agent-ca.pem

#Populate certificate file
cat << EOF > /etc/consul.d/consul-agent-ca.pem
${consul_ca_cert}
EOF

#Create Consul config file
cat << EOF > /etc/consul.d/server.hcl
node_name = "consul-server"
server = true
datacenter = "dc1"
data_dir = "/opt/consul"
bootstrap = true
ui_config {
    enabled = true
}
addresses {
    http = "0.0.0.0"
}
acl { 
	enabled = true
	default_policy = "deny"
	enable_token_persistence = true
	tokens {
		master = "${consul_acl_token}"
		agent = "${consul_acl_token}"
	}
}
connect {
    enabled = true
}
verify_incoming = false
verify_outgoing = false
verify_server_hostname = false
encrypt = "${consul_gossip_key}"
ca_file = "consul-agent-ca.pem"
EOF

#Enable the service
sudo systemctl enable consul
sudo service consul start
sudo service consul status