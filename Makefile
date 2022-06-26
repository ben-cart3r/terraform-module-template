TERRAFORM_VERSION		?= 1.1.7
TERRAFORM_DOCS_VERSION	?= 0.16.0
TFSEC_VERSION			?= v1.13.2-amd64
CUR_DIR					:= $(shell pwd)# ${PWD} is incosistent in GitHub Actions

export

clean:
	rm -rf terraform/.terraform

fmt:
	docker run --platform=linux/amd64 \
		-v ${CUR_DIR}:/src \
		-w /src \
		hashicorp/terraform:${TERRAFORM_VERSION} fmt -recursive

sec-scan: clean
	docker run --rm --platform=linux/amd64 \
		-v ${CUR_DIR}:/src \
		tfsec/tfsec:${TFSEC_VERSION} /src/terraform

docs:
	docker run --rm --platform=linux/amd64 \
		-v "$(CUR_DIR):/terraform-docs" \
		quay.io/terraform-docs/terraform-docs:${TERRAFORM_DOCS_VERSION} markdown \
		--output-file ../README.md \
		--output-mode inject \
		/terraform-docs/terraform

init-no-backend:
	docker run --platform=linux/amd64 \
		-v ${CUR_DIR}:/src \
		-v ${HOME}/.ssh:/root/.ssh/ \
		-v ${HOME}/.gitconfig:/root/.gitconfig \
		-w /src/terraform \
		hashicorp/terraform:${TERRAFORM_VERSION} init \
		-backend=false

validate: clean init-no-backend
	docker run --platform=linux/amd64 \
		-v ${CUR_DIR}:/src \
		-w /src/terraform \
		hashicorp/terraform:${TERRAFORM_VERSION} validate
