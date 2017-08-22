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
	docker_run_with_dynamic_env "-e TF_DEBUG -w ${TERRAFORM_TEMP} ${TERRAFORM_IMAGE}" "${TERRAFORM_CMD} ${1}"
}

tf_clean() {
	docker_run_with_dynamic_env ${TERRAFORM_IMAGE} "rm -fr ${TERRAFORM_TEMP}"
}

tf_init() {
	tf_clean
	mkdir -p ${TERRAFORM_TEMP}

	if [ ${HAS_BACKEND_CONFIG} == true ]; then
		print_info "Initializing Terraform configuration..."
	    tf "init ${TERRAFORM_DIR}"
    else
		print_info "Initializing Terraform backend configuration..."
        echo -e "${BACKEND_CONFIG}" >> ${BACKEND_FILE}
        tf "init -backend-config ${BACKEND_FILE} ${TERRAFORM_DIR}"
    fi
}

tf_get() {
	tf "get"
}

tf_with_vars() {
	tf "${1} ${TERRAFORM_TFVARS:-}"
}

case "${command}" in
	tf) ## <arg>... %% Manipulate infrastructure as code
		tf "${args}" ;;

	tf:init) ## %% Run `tf:clean`, then `terraform init`, loading the backend.tfvars for the specified DEPLOY_ENV
		tf_init ;;

	tf:with-vars) ## <arg>... %% Run Terraform with secret variables/environment (requires 'secrets' directory in project)
		tf_with_vars "${args}" ;;

	tf:get) ## %% Run `terraform get`
		tf_get ;;

	tf:clean) ## %% 🗑  Clean up temporary Terraform files
		tf_clean ;;

	tf:run) ## %% 🏃  Run `tf:init`, `terraform plan`, `terraform apply`, then `tf:clean`
		tf_init
		tf_get
		tf_with_vars "plan ${args}"
		tf_with_vars "apply ${args}"
#		tf_clean
		;;

	tf:refresh) ## %% 🔄  Run `terraform refresh` with secret/environment, then `tf:clean`
		tf_init
		tf_get
		tf_with_vars "refresh ${args}"
#		tf_clean
		;;

	tf:plan) ## %% Run `tf:init`, `terraform plan` with secret/environment, then `tf:clean`
		tf_init
		tf_get
		tf_with_vars "plan ${args}"
#		tf_clean
		;;

	tf:destroy) ## %% ⚠️  Run `tf:init`, `terraform destroy` with secret/environment, then `tf:clean`
		tf_init
		tf_get
		docker_run_with_dynamic_env -ti "${TERRAFORM_IMAGE} terraform destroy ${args}"
#		tf_clean
		;;

	tf:rekt) ## %% ☠  Run `tf:init`, `terraform destroy -force` with secret/environment, then `tf:clean`
		tf_init
		tf_get
		tf_with_vars "destroy -force ${args}"
#		tf_clean
		;;

	tf:unlock) ## <lock id> %% 🔓  Run `terraform init`, `terraform force-unlock` with secret/environment
		tf_init
		tf_get
		tf_with_vars "force-unlock -force"
#		tf_clean
		;;

	*)
		task_help
esac
