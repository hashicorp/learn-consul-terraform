#all:
#	. working-environment

.PHONY install:
ifeq ($(install),"true")
	@terraform init
	#@terraform init
endif


.PHONY apply:
apply:
	terraform apply -autoa-approve
	terraform -chdir=working-environment apply -auto-approve