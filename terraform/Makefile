.DEFAULT_GOAL := help

ENV_FILE ?= config/dev.env.local
TERRAFORM_DIR := terraform/environments/dev

.PHONY: help
help:
	@printf "%-30s %-60s\n" "[Sub command]" "[Description]"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %-60s\n", $$1, $$2}'

.PHONY: require-env-file
require-env-file:
	@if [ ! -f "$(ENV_FILE)" ]; then \
		printf 'ERROR: ENV_FILE does not exist: %s\n' "$(ENV_FILE)" >&2; \
		exit 2; \
	fi

.PHONY: bootstrap bootstrap-dry-run
bootstrap: require-env-file ## Terraform state bucketを作成・設定する
	bash ./bootstrap/scripts/bootstrap.sh --env-file "$(ENV_FILE)"

bootstrap-dry-run: require-env-file ## Terraform state bucketの作成内容を確認する
	bash ./bootstrap/scripts/bootstrap.sh --env-file "$(ENV_FILE)" --dry-run

.PHONY: destroy destroy-execute
destroy: require-env-file ## Terraform state bucketの削除内容を確認する
	bash ./bootstrap/scripts/destroy.sh --env-file "$(ENV_FILE)"

destroy-execute: require-env-file ## Terraform state bucketと全object versionを削除する
	bash ./bootstrap/scripts/destroy.sh --env-file "$(ENV_FILE)" --execute

.PHONY: configure-terraform
configure-terraform: require-env-file ## Terraformのbackendと変数を設定する
	bash ./bootstrap/scripts/configure-terraform.sh --env-file "$(ENV_FILE)"

.PHONY: terraform-plan terraform-test terraform-apply sakila-load
terraform-plan: ## Terraformの変更予定を確認する
	terraform -chdir=$(TERRAFORM_DIR) plan

terraform-test: ## Terraformのmock testを実行する
	terraform -chdir=$(TERRAFORM_DIR) test

terraform-apply: ## Terraformの変更をGoogle Cloudへ適用する
	terraform -chdir=$(TERRAFORM_DIR) apply -auto-approve

sakila-load: require-env-file ## Sakila検証用テーブルをBigQueryへ投入する
	bash ./sakila/load.sh --env-file "$(ENV_FILE)"
