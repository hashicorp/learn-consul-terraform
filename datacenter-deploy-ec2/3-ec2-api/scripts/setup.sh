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

start_public_api() {
  export GOPATH=/home/ubuntu/go
  export PATH=$PATH:$GOPATH/bin
  export GOCACHE=/home/ubuntu/.cache/go-build
  
  #Create Systemd Config
sudo cat << EOF > /etc/systemd/system/public-api.service
[Unit]
Description="HashiCups Public API"
Documentation=https://github.com/hashicorp-demoapp/public-api
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/public-api
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

  # curl -sSL --fail -o /tmp/public-api https://github.com/hashicorp-demoapp/public-api/releases/download/v${public_api_version}/public-api
  # wget https://github.com/hashicorp-demoapp/product-api-go/releases/download/v0.0.22/product_api_go_linux_amd64.zip
  # unzip product_api_go_linux_amd64.zip

  git clone https://github.com/hashicorp-demoapp/public-api
  cd public-api
  go mod tidy
  go build -o /tmp/public-api

  mv /tmp/public-api /usr/bin/public-api
  chmod +x /usr/bin/public-api

  systemctl daemon-reload
  systemctl enable public-api
  systemctl start public-api
}

start_product_api() {
  #Create Systemd Config
sudo cat << EOF > /etc/systemd/system/product-api.service
[Unit]
Description="HashiCups Product API"
Documentation=https://github.com/hashicorp-demoapp/product-api-go
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/product-api.d/conf.json

[Service]
Type=simple
Environment=CONFIG_FILE=/etc/product-api.d/conf.json
ExecStart=/usr/bin/product-api
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/product-api.d

sudo cat << EOF > /etc/product-api.d/conf.json
{
  "db_connection": "host=${postgres_host} port=${postgres_port} user=postgres password=password dbname=postgres sslmode=disable",
  "bind_address": "0.0.0.0:9090",
  "metrics_address": "0.0.0.0:9102"
}
EOF

  # curl -sSL --fail -o /tmp/product-api https://github.com/hashicorp-demoapp/product-api-go/releases/download/v${product_api_version}/product-api
  wget https://github.com/hashicorp-demoapp/product-api-go/releases/download/v0.0.22/product_api_go_linux_amd64.zip
  unzip product_api_go_linux_amd64.zip

  mv product-api /usr/bin/product-api
  chmod +x /usr/bin/product-api

  systemctl daemon-reload
  systemctl enable product-api
  systemctl start product-api
}


setup_deps() {
  add-apt-repository universe -y
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/getenvoy.list
  sudo add-apt-repository -y ppa:longsleep/golang-backports
  apt update -qy
  version="${consul_version}"
  consul_package="consul=$${version}-1"
  apt install -qy apt-transport-https gnupg2 curl lsb-release golang-go $${consul_package} getenvoy-envoy unzip jq apache2-utils nginx

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

start_postgres() {
  set -o errexit

  export DEBIAN_FRONTEND=noninteractive

  PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
  if [ ! -f "$PG_REPO_APT_SOURCE" ]
  then
    # Add PG apt repo:
    echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > "$PG_REPO_APT_SOURCE"

    # Add PGDG repo key:
    wget --quiet -O - https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
  fi

  apt-get update
  apt-get -y upgrade

  apt-get install -y \
    "postgresql-${postgres_version}" \
    "postgresql-contrib-${postgres_version}"

  PG_CONF="/etc/postgresql/${postgres_version}/main/postgresql.conf"
  PG_HBA="/etc/postgresql/${postgres_version}/main/pg_hba.conf"
  PG_DIR="/var/lib/postgresql/${postgres_version}/main"

  sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
  echo "host    all             all             all                     md5" >> "$PG_HBA"
  echo "client_encoding = utf8" >> "$PG_CONF"

  systemctl restart postgresql

  # Get HashiCups SQL
  wget https://raw.githubusercontent.com/hashicorp-demoapp/product-api-go/main/database/products.sql

  sudo -u postgres psql -c "CREATE DATABASE products owner postgres;"
  sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password';"
  sudo -u postgres psql -d postgres -f ~/products.sql
}

cd /home/ubuntu/

setup_networking
setup_deps

setup_consul
start_product_api
start_public_api

start_consul

# nomad and consul service is type simple and might not be up and running just yet.
sleep 10

echo "done"