## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.43 |
| <a name="requirement_hcp"></a> [hcp](#requirement\_hcp) | >= 0.18.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.3.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.11.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.75.2 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_consul_client"></a> [eks\_consul\_client](#module\_eks\_consul\_client) | ./modules/eks-client | n/a |
| <a name="module_infrastructure"></a> [infrastructure](#module\_infrastructure) | ./modules/infra | n/a |
| <a name="module_lambda-registration"></a> [lambda-registration](#module\_lambda-registration) | hashicorp/consul-lambda-registrator/aws//modules/lambda-registrator | 0.1.0-beta1 |
| <a name="module_remove_kubernetes_backed_enis"></a> [remove\_kubernetes\_backed\_enis](#module\_remove\_kubernetes\_backed\_enis) | github.com/webdog/terraform-kubernetes-delete-eni | n/a |
| <a name="module_render_tutorial"></a> [render\_tutorial](#module\_render\_tutorial) | ./modules/rendering | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.lambda-registrator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_iam_policy.lambda_payments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_payments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_payments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.lambda-payments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_ssm_parameter.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [null_resource.push-lambda-registrator-to-ecr](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The AWS region to create resources in | `string` | `"us-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_logs_path"></a> [cloudwatch\_logs\_path](#output\_cloudwatch\_logs\_path) | n/a |
| <a name="output_consul_addr"></a> [consul\_addr](#output\_consul\_addr) | n/a |
| <a name="output_eks_update_kubeconfig_command"></a> [eks\_update\_kubeconfig\_command](#output\_eks\_update\_kubeconfig\_command) | n/a |
| <a name="output_hcp_login_token"></a> [hcp\_login\_token](#output\_hcp\_login\_token) | n/a |
| <a name="output_kubernetes_cluster_endpoint"></a> [kubernetes\_cluster\_endpoint](#output\_kubernetes\_cluster\_endpoint) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
