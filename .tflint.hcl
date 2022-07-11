config {
  format = "compact"
  plugin_dir = "./tflint.d/plugins"

  module = true
  force = false
  disabled_by_default = false

  ignore_module = {
    "terraform-aws-modules/vpc/aws" = true
    "terraform-aws-modules/eks" = true
  }
	plugin "aws" {
  	enabled = true
  	version = "0.4.0"
  	source  = "github.com/terraform-linters/tflint-ruleset-aws"
	}

	rule "terraform_comment_syntax" {
	enabled = true
	}

	rule "terraform_documented_outputs" {
	enabled = true
	}
	rule "terraform_documented_variables" {
	enabled = true
	}
	rule "terraform_naming_conventions" {
	enabled = true
	format = "snake_case"
	}
	rule "terraform_required_providers" {
	enabled = true
	}
	rule "terraform_required_version" {
	enabled = true
	}
	rule "terraform_standard_module_structure" {
	enabled = true
	}
	rule "terraform_typed_variables" {
	enabled = true
	}
	rule "terraform_unused_declarations" {
	enabled = true
	}
	rule "terraform_unused_required_providers" {
	enabled = true
	}

	rule "aws_resource_missing_tags"  {
	enabled = true
	}
}
