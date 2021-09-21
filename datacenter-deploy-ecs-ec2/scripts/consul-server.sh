#!/bin/bash

#Utils
sudo apt-get install unzip

#Download Consul
CONSUL_VERSION="1.10.2"
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

#Install Consul
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
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
ConditionFileNotEmpty=/etc/consul.d/server.json
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
sudo touch /etc/consul.d/server.json
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/server.json

cat << EOF > /etc/consul.d/server.json
{
    "node_name": "consul-server",
    "server": true,
    "bootstrap" : true,
    "ui_config": {
        "enabled" : true
    },
    "datacenter": "dc1",
    "data_dir": "/opt/consul",
    "log_level":"INFO",
    "addresses": {
        "http" : "0.0.0.0"
    }
}
EOF

#Enable the service
sudo systemctl enable consul
sudo service consul start
sudo service consul status