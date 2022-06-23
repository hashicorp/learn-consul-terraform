.PHONY apply:
apply:
	terraform apply -auto-approve
	terraform -chdir=working-environment apply -auto-approve && terraform output -json

.PHONY destroy:
destroy:
	cluster-context := lambdaTutorial
	terraform -chdir=working-environment destroy -auto-approve
	terraform destroy -auto-approve
	kubectl config delete-context ${cluster-context}


.PHONE debug:
debug:
	terraform -chdir=working-environment destroy -auto-approve
	terraform -chdir=working-environment state rm module.kubernetes_resources.null_resource.cleanup
	

.PHONY work:
work:
	terraform -chdir=working-environment apply -auto-approve