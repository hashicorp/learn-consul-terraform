clusterContext = lambdaTutorial

.PHONY apply:
apply:
	terraform apply -auto-approve
	terraform -chdir=working-environment apply -auto-approve && terraform output -json | jq -r '.consul_values.value' | grep -v consul_ca_cert

.PHONY destroy:
destroy:
	cp ./working-environment/terraform.tfvars ./working-environment/terraform.tfvars.bkp
	terraform -chdir=working-environment destroy -auto-approve
	terraform destroy -auto-approve
	kubectl config delete-context $(clusterContext)


.PHONE debug:
debug:
	terraform -chdir=working-environment destroy -auto-approve


.PHONY work:
work:
	terraform -chdir=working-environment apply -auto-approve