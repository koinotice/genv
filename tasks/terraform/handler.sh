#!/usr/bin/env bash

if [[ ${AWS_ACCESS_KEY_ID:-} && ${AWS_SECRET_ACCESS_KEY:-} ]]; then
	DOCKER_RUN_WITH_ENV+=" -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY"
fi

if [ ! ${TERRAFORM_IMAGE_VERSION:-} ]; then
	export TERRAFORM_IMAGE_VERSION=latest
fi

if [ ! ${TERRAFORM_IMAGE:-} ]; then
	export TERRAFORM_IMAGE=hashicorp/terraform:${TERRAFORM_IMAGE_VERSION}
fi

if [ ! ${TERRAFORM_CMD:-} ]; then
	export TERRAFORM_CMD=""
fi

if [ ! ${TERRAFORM_DIR:-} ]; then
	export TERRAFORM_DIR=$PWD/terraform
fi

# terraform tfvars
if [ ${TERRAFORM_TFVARS:-} ]; then
	export TERRAFORM_TFVARS="-var-file ${TERRAFORM_TFVARS}"
fi

export TERRAFORM_TEMP="${HARPOON_TEMP}/terraform"

export BACKEND_FILE="${TERRAFORM_TEMP}/backend.tfvars"


if [ ! ${REMOTE_STATEFILE_PREFIX:-} ]; then
	export REMOTE_STATEFILE_PREFIX=${REPO_ROOT}
fi

if [ ! ${TF_BACKEND_BUCKET_PREFIX:-} ]; then
	export TF_BACKEND_BUCKET_PREFIX=terraform-state
fi

export BACKEND_CONFIG=$(cat <<-END
bucket = "${TF_BACKEND_BUCKET_PREFIX}-${DEPLOY_ENV}"
key = "${REMOTE_STATEFILE_PREFIX}/terraform.tfstate"
region = "us-east-1"
encrypt = true
lock_table = "terraform_locks"
END
)

# HAS_BACKEND_CONFIG
#   Determine whether or not a backend configuration already exists within the
#   terraform modules. If it does, this configuration should override the
#   auto-generated configuration.

TERRAFORM_BLOCK_FILENAME=$(grep -lr "^terraform\s*{\?\s*$" ${TERRAFORM_DIR} || true)
BACKEND_BLOCK_FILENAME=$(grep -lr "^\s*backend\s*\"[a-zA-Z0-9]\+\"\s*{\?\s*$" ${TERRAFORM_DIR} || true)

if [[ \
    ! -z ${TERRAFORM_BLOCK_FILENAME} && \
    ! -z ${BACKEND_BLOCK_FILENAME} && \
    ${TERRAFORM_BLOCK_FILENAME} == ${BACKEND_BLOCK_FILENAME} \
 ]]; then
    HAS_BACKEND_CONFIG=true
else
    HAS_BACKEND_CONFIG=false
fi

# $1 ARGS
tf() {
	dockerRunWithDynamicEnv "-e TF_DEBUG -w ${TERRAFORM_TEMP} ${TERRAFORM_IMAGE}" "${TERRAFORM_CMD} ${1}"
}

tfClean() {
	dockerRunWithDynamicEnv ${TERRAFORM_IMAGE} "rm -fr ${TERRAFORM_TEMP}"
}

tfInit() {
	tfClean
	mkdir -p ${TERRAFORM_TEMP}

	if [ ${HAS_BACKEND_CONFIG} == true ]; then
		printInfo "Initializing Terraform configuration..."
	    tf "init ${TERRAFORM_DIR}"
    else
		printInfo "Initializing Terraform backend configuration..."
        echo -e "${BACKEND_CONFIG}" >> ${BACKEND_FILE}
        tf "init -backend-config ${BACKEND_FILE} ${TERRAFORM_DIR}"
    fi
}

tfGet() {
	tf "get"
}

tfWithVars() {
	tf "${1} ${TERRAFORM_TFVARS:-}"
}

case "${command}" in
	tf) ## <arg>... %% Manipulate infrastructure as code
		tf "${args}" ;;

	tf:init) ## %% Run `tf:clean`, then `terraform init`, loading the backend.tfvars for the specified DEPLOY_ENV
		tfInit ;;

	tf:with-vars) ## <arg>... %% Run Terraform with secret variables/environment (requires 'secrets' directory in project)
		tfWithVars "${args}" ;;

	tf:get) ## %% Run `terraform get`
		tfGet ;;

	tf:clean) ## %% 🗑  Clean up temporary Terraform files
		tfClean ;;

	tf:run) ## %% 🏃  Run `tf:init`, `terraform plan`, `terraform apply`, then `tf:clean`
		tfInit
		tfGet
		tfWithVars "plan ${args}"
		tfWithVars "apply ${args}"
		;;

	tf:refresh) ## %% 🔄  Run `terraform refresh` with secret/environment, then `tf:clean`
		tfInit
		tfGet
		tfWithVars "refresh ${args}"
		;;

	tf:plan) ## %% Run `tf:init`, `terraform plan` with secret/environment, then `tf:clean`
		tfInit
		tfGet
		tfWithVars "plan ${args}"
		;;

	tf:destroy) ## %% ⚠️  Run `tf:init`, `terraform destroy` with secret/environment, then `tf:clean`
		tfInit
		tfGet
		dockerRunWithDynamicEnv -ti "${TERRAFORM_IMAGE} terraform destroy ${args}"
		;;

	tf:rekt) ## %% ☠  Run `tf:init`, `terraform destroy -force` with secret/environment, then `tf:clean`
		tfInit
		tfGet
		tfWithVars "destroy -force ${args}"
		;;

	tf:unlock) ## <lock id> %% 🔓  Run `terraform init`, `terraform force-unlock` with secret/environment
		tfInit
		tfGet
		tfWithVars "force-unlock -force"
		;;

	*)
		taskHelp
esac
