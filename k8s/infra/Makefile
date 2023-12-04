UNAME:= $(shell uname)
ifeq ($(UNAME),Darwin)
		OS_X  := true
		SHELL := /bin/bash
else
		OS_DEB  := true
		SHELL := /bin/bash
endif

TERRAFORM:= $(shell command -v terraform 2> /dev/null)
TERRAFORM_VERSION:= "1.6.4"

ifeq ($(OS_X),true)
		TERRAFORM_MD5:= $(shell md5 -q `which terraform`)
		TERRAFORM_REQUIRED_MD5:= 6221010e55b78e83a9987163baf7061f
else
		TERRAFORM_MD5:= $(shell md5sum - < `which terraform` | tr -d ' -')
		TERRAFORM_REQUIRED_MD5:= 6221010e55b78e83a9987163baf7061f
endif

default:
	@echo "Creates a Terraform system from a template."
	@echo "The following commands are available:"
	@echo " - plan               : runs terraform plan for an environment"
	@echo " - apply              : runs terraform apply for an environment"
	@echo " - destroy            : will delete the entire project's infrastructure"

check:
	@echo "Checking Terraform version... success expecting md5 of [${TERRAFORM_REQUIRED_MD5}], found [${TERRAFORM_MD5}]"
	@if [ "${TERRAFORM_MD5}" != "${TERRAFORM_REQUIRED_MD5}" ]; then echo "Please ensure you are running terraform ${TERRAFORM_VERSION}."; exit 1; fi

init: check
	@echo "Doing the working directory initialization ..."
	@terraform init -force-copy

plan-dev: check
	@echo 'Switching to the dev environment ...'
	@terraform workspace select -or-create dev
	@terraform plan  \
  	-var-file="env.dev.tfvars" \
		-out dev.plan

plan-test: check
	@echo 'Switching to the test environment ...'
	@terraform workspace select -or-create test
	@terraform plan  \
  	-var-file="env.test.tfvars" \
		-out test.plan

plan-prod: check
	@echo 'Switching to the prod environment ...'
	@terraform workspace select -or-create prod
	@terraform plan  \
  	-var-file="env.prod.tfvars" \
		-out prod.plan

targetplan: check
	$(call check_defined, ENV, Please set the ENV to plan for. Values should be dev, test, uat or prod)
	@terraform fmt

	@echo "Pulling the required modules..."
	@terraform get

	@echo 'Switching to the [$(value ENV)] environment ...'
	@terraform workspace select $(value ENV) 

	@terraform plan  \
  	  -var-file="env/$(value ENV).tfvars" \
		-target "$(value restype).$(value resname)" \
		-out $(value ENV).plan


apply-dev: check
	@echo 'Switching to the dev environment ...'
	@terraform workspace select dev

	@echo "Will be applying the following to dev environment:"
	@terraform show -no-color dev.plan

	@terraform apply dev.plan
	@rm dev.plan

apply-test: check
	@echo 'Switching to the test environment ...'
	@terraform workspace select test

	@echo "Will be applying the following to test environment:"
	@terraform show -no-color test.plan

	@terraform apply test.plan
	@rm test.plan

apply-prod: check
	@echo 'Switching to the prod environment ...'
	@terraform workspace select prod

	@echo "Will be applying the following to prod environment:"
	@terraform show -no-color prod.plan

	@terraform apply prod.plan
	@rm prod.plan

taint: check
	$(call check_defined, ENV, Please set the ENV to plan for. Values should be dev, test, uat or prod)
	@terraform fmt

	@echo "Pulling the required modules..."
	@terraform get

	@echo 'Switching to the [$(value ENV)] environment ...'
	@terraform workspace select $(value ENV) 

	@terraform taint  \
		 "$(value restype).$(value resname)" 

	@ENV=$(value ENV) restype=$(value restype) resname=$(value resname) make targetplan

	@ENV=$(value ENV) make apply
	

destroy-dev: check
	@echo "Switching to the dev environment ..."
	@terraform workspace select dev

	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@echo "Are you really sure you want to completely destroy dev environment ?"
	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@read -p "Press enter to continue"
	@terraform destroy \
		-var-file="env.dev.tfvars"

destroy-test: check
	@echo "Switching to the test environment ..."
	@terraform workspace select test

	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@echo "Are you really sure you want to completely destroy test environment ?"
	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@read -p "Press enter to continue"
	@terraform destroy \
		-var-file="env.test.tfvars"

destroytarget: check
	@echo "Switching to the [$(value ENV)] environment ..."
	@terraform workspace select $(value ENV)

	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@echo "Are you really sure you want to completely destroy [$(value ENV)]  Resource:  [$(value restype).$(value resname)]  ?"
	@echo "## 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥 ##"
	@read -p "Press enter to continue"
	@terraform destroy \
  	  -var-file="env/$(value ENV).tfvars" \
		-target "$(value restype).$(value resname)" \

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))