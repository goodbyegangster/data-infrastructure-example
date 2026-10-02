.DEFAULT_GOAL := help

ENV_FILE ?= config/dev.env
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

.PHONY: bootstrap-dry-run
bootstrap-dry-run: require-env-file ## Terraform state bucket 作成処理のドライラン
	bash ./scripts/bootstrap.sh --env-file "$(ENV_FILE)" --dry-run

.PHONY: bootstrap-run
bootstrap-run: require-env-file ## Terraform state bucket を作成する
	bash ./scripts/bootstrap.sh --env-file "$(ENV_FILE)"

.PHONY: bootstrap-destroy-dry-run
bootstrap-destroy-dry-run: require-env-file ## Terraform state bucket 削除処理のドライラン
	bash ./scripts/destroy.sh --env-file "$(ENV_FILE)" --dry-run

.PHONY: bootstrap-destroy-run
bootstrap-destroy-run: require-env-file ## Terraform state bucket を削除する
	bash ./scripts/destroy.sh --env-file "$(ENV_FILE)"

.PHONY: terraform-configure
terraform-configure: require-env-file ## Terraform の backend と vars ファイルを作成する
	bash ./scripts/terraform-configure.sh --env-file "$(ENV_FILE)"

.PHONY: terraform-plan terraform-test terraform-apply sakila-load
terraform-plan: ## Terraformの変更予定を確認する
	terraform -chdir=$(TERRAFORM_DIR) plan

terraform-test: ## Terraformのmock testを実行する
	terraform -chdir=$(TERRAFORM_DIR) test

terraform-apply: ## Terraformの変更をGoogle Cloudへ適用する
	terraform -chdir=$(TERRAFORM_DIR) apply -auto-approve

sakila-load: require-env-file ## Sakila検証用テーブルをBigQueryへ投入する
	bash ./sakila/load.sh --env-file "$(ENV_FILE)"
