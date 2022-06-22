#all:
#	. working-environment

.PHONY install:
ifeq ($(install),"true")
	@terraform init
	#@terraform init
endif


.PHONY apply:
apply:
	terraform apply -auto-approve
	terraform -chdir=working-environment apply -auto-approve

.PHONY destroy:
destroy:
	terraform chdir=working-environment destroy -auto-approve
	terraform destroy -auto-approve
