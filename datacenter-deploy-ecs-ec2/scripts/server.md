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
    },
	"acl": { 
		"enabled": true,
		"default_policy": "deny",
		"enable_token_persistence": true,
		"tokens": {
			"master": "${random_uuid.bootstrap_token.result}",
			"agent": "${random_uuid.bootstrap_token.result}"
		}
	},
	"connect": { "enabled": true },
    "verify_incoming": false,
    "verify_outgoing": false,
    "verify_server_hostname": false,
    "encrypt": "${random_id.gossip_encryption_key.result}",
    "ca_file": "${tls_self_signed_cert.ca.cert_pem}"
}
EOF