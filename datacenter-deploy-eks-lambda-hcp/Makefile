all:
	tutorial tutorial_resources

tutorial:
	@terraform init
	@terraform apply -auto-approve

tutorial_resources:
	@terraform init -chdir='./working-environment'
	@terraform apply -auto-approve -chdir='./working-environment'

