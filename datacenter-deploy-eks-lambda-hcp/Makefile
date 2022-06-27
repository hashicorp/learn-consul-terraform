clusterContext = lambdaTutorial

.PHONY apply:
apply:
	terraform apply -auto-approve
	terraform -chdir=working-environment apply -auto-approve && terraform output -json

.PHONY destroy:
destroy:
	terraform -chdir=working-environment destroy -auto-approve
	terraform destroy -auto-approve
	kubectl config delete-context $(clusterContext)


.PHONE debug:
debug:
	terraform -chdir=working-environment destroy -auto-approve


.PHONY work:
work:
	terraform -chdir=working-environment apply -auto-approve