#!/usr/bin/env bash
set -ex

start_consul() {
  #Create Systemd Config
sudo cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=simple
ExecStart=${consul_cmd}
ExecReload=/usr/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

  systemctl enable consul
  systemctl start consul
}

setup_deps() {
  add-apt-repository universe -y
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/getenvoy.list
  apt update -qy
  version="${consul_version}"
  consul_package="consul=$${version}-1"
  apt install -qy apt-transport-https gnupg2 curl lsb-release nomad $${consul_package} getenvoy-envoy unzip jq apache2-utils nginx

  curl -fsSL https://get.docker.com -o get-docker.sh
  sh ./get-docker.sh
}

setup_networking() {
  # echo 1 | tee /proc/sys/net/bridge/bridge-nf-call-arptables
  # echo 1 | tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
  # echo 1 | tee /proc/sys/net/bridge/bridge-nf-call-iptables
  curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$([ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
  mkdir -p /opt/cni/bin
  tar -C /opt/cni/bin -xzf cni-plugins.tgz
}

setup_consul() {
  mkdir --parents /etc/consul.d /var/consul
  chown --recursive consul:consul /etc/consul.d
  chown --recursive consul:consul /var/consul

  echo "${consul_ca}" | base64 -d >/etc/consul.d/ca.pem

  local_ip=`ip -o route get to 169.254.169.254 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
  # Modify the default consul.hcl file
  cat > /etc/consul.d/consul.hcl <<- EOF
data_dir = "/opt/consul"
client_addr = "0.0.0.0"
server = false
bind_addr = "0.0.0.0"
acl = {
  enabled = true,
  down_policy = "async-cache",
  default_policy = "deny",
  tokens = {
    agent = "${bootstrap_token}"
  }
}
encrypt = "${gossip_key}"
ca_file = "/etc/consul.d/ca.pem"
advertise_addr = "$local_ip"
retry_join = ["provider=aws tag_key=\"Name\" tag_value=\"learn-consul-consul-server\""]
EOF
}

start_nginx() {
  sudo cat << EOF > /etc/systemd/system/nginx.service
[Unit]
Description=A high performance web server and a reverse proxy server
After=network.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

  sudo cat << EOF > /etc/nginx/nginx.conf
events {}

http {
  server {
    listen 80;
    server_name localhost;

    server_tokens off;

    gzip on;
    gzip_proxied any;
    gzip_comp_level 4;
    gzip_types text/css application/javascript image/svg+xml;

    proxy_http_version 1.1;
    proxy_set_header Connection 'upgrade';

    location / {
      proxy_pass http://${frontend_host};
    }

    location /api {
      proxy_pass http://${public_api_host};
    }
  }
}
EOF

#     sudo cat << EOF > /etc/systemd/system/nginx.service.d/override.conf
# [Service]
# ExecStartPost=/bin/sleep 0.1
# EOF

#   mkdir /etc/systemd/system/nginx.service.d

  mkdir /etc/systemd/system/nginx.service.d
  printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
  systemctl daemon-reload
  systemctl enable nginx
  systemctl restart nginx
}

cd /home/ubuntu/

setup_networking
setup_deps

setup_consul
start_nginx

start_consul

# nomad and consul service is type simple and might not be up and running just yet.
sleep 10

echo "done"
