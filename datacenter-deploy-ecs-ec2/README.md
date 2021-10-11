## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.53.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.53.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acl_controller"></a> [acl\_controller](#module\_acl\_controller) | ../modules/acl-controller | n/a |
| <a name="module_example_client_app"></a> [example\_client\_app](#module\_example\_client\_app) | ../modules/mesh-task | n/a |
| <a name="module_example_server_app"></a> [example\_server\_app](#module\_example\_server\_app) | ../modules/mesh-task | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 2.78.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.example_client_app](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/ecs_service) | resource |
| [aws_ecs_service.example_server_app](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/ecs_service) | resource |
| [aws_eip.consul](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/eip) | resource |
| [aws_eip_association.eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.consul](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.consul](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/iam_role) | resource |
| [aws_iam_role.instance_role](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.describe_instances_policy](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/iam_role_policy) | resource |
| [aws_instance.consul](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/instance) | resource |
| [aws_lb.example_client_app](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/lb) | resource |
| [aws_lb_listener.example_client_app](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.example_client_app](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/lb_target_group) | resource |
| [aws_secretsmanager_secret.bootstrap_token](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.ca_cert](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.ca_key](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.gossip_key](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.bootstrap_token](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.ca_cert](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.ca_key](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.gossip_key](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.consul](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/security_group) | resource |
| [aws_security_group.example_client_app_alb](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingress_from_client_alb_to_ecs](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/resources/security_group_rule) | resource |
| [random_id.gossip_encryption_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_uuid.bootstrap_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [tls_private_key.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/data-sources/caller_identity) | data source |
| [aws_security_group.vpc_default](https://registry.terraform.io/providers/hashicorp/aws/3.53.0/docs/data-sources/security_group) | data source |
| [template_file.userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acls"></a> [acls](#input\_acls) | Whether to enable ACLs on the server. | `bool` | `true` | no |
| <a name="input_consul_version"></a> [consul\_version](#input\_consul\_version) | Consul server version | `string` | `"1.10.2"` | no |
| <a name="input_gossip_key_secret_arn"></a> [gossip\_key\_secret\_arn](#input\_gossip\_key\_secret\_arn) | The ARN of the Secrets Manager secret containing the Consul gossip encryption key. | `string` | `""` | no |
| <a name="input_lb_ingress_ip"></a> [lb\_ingress\_ip](#input\_lb\_ingress\_ip) | Your Public IP. This is used in the load balancer security groups to ensure only you can access the Consul UI and example application. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier. | `string` | `"consul-ecs"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | `"us-east-1"` | no |
| <a name="input_secure"></a> [secure](#input\_secure) | Whether to create all resources in a secure installation (with TLS, ACLs and gossip encryption). | `bool` | `true` | no |
| <a name="input_ssh_keypair_name"></a> [ssh\_keypair\_name](#input\_ssh\_keypair\_name) | Name of the SSH keypair to use in AWS. | `string` | `null` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Suffix to add to all resource names. | `string` | `"nosuffix"` | no |
| <a name="input_tls"></a> [tls](#input\_tls) | Whether to enable TLS on the server for the control plane traffic. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Consul_ui_address"></a> [Consul\_ui\_address](#output\_Consul\_ui\_address) | n/a |
| <a name="output_acl_bootstrap_token"></a> [acl\_bootstrap\_token](#output\_acl\_bootstrap\_token) | n/a |
| <a name="output_client_lb_address"></a> [client\_lb\_address](#output\_client\_lb\_address) | n/a |
