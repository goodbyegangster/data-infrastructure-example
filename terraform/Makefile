.DEFAULT_GOAL := help

ENV_FILE ?= config/dev.env
ENVIRONMENT ?= dev
DEPLOYMENTS := raw_data mart_red mart_blue

.PHONY: help
help:
	@printf "%-30s %-45s\n" "[Sub command]" "[Description]"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %-45s\n", $$1, $$2}'

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
terraform-configure: require-env-file ## Terraform の backend と tfvars ファイルを作成する
	bash ./scripts/terraform-configure.sh --env-file "$(ENV_FILE)"

.PHONY: terraform-raw-data-init
terraform-raw-data-init: ## [raw_data] terraform init
	terraform -chdir="./deployments/raw_data/dev" init

.PHONY: terraform-raw-data-plan
terraform-raw-data-plan: ## [raw_data] terraform plan
	terraform -chdir="./deployments/raw_data/dev" plan

.PHONY: terraform-raw-data-test
terraform-raw-data-test: ## [raw_data] terraform test
	terraform -chdir="./deployments/raw_data/dev" test

.PHONY: terraform-raw-data-apply
terraform-raw-data-apply: ## [raw_data] terraform apply
	terraform -chdir="./deployments/raw_data/dev" apply -auto-approve

.PHONY: terraform-raw-data-destroy
terraform-raw-data-destroy: ## [raw_data] terraform destroy
	terraform -chdir="./deployments/raw_data/dev" destroy

.PHONY: terraform-mart-red-init
terraform-mart-red-init: ## [mart_red] terraform init
	terraform -chdir="./deployments/mart_red/dev" init

.PHONY: terraform-mart-red-plan
terraform-mart-red-plan: ## [mart_red] terraform plan
	terraform -chdir="./deployments/mart_red/dev" plan

.PHONY: terraform-mart-red-test
terraform-mart-red-test: ## [mart_red] terraform test
	terraform -chdir="./deployments/mart_red/dev" test

.PHONY: terraform-mart-red-apply
terraform-mart-red-apply: ## [mart_red] terraform apply
	terraform -chdir="./deployments/mart_red/dev" apply -auto-approve

.PHONY: terraform-mart-red-destroy
terraform-mart-red-destroy: ## [mart_red] terraform destroy
	terraform -chdir="./deployments/mart_red/dev" destroy

.PHONY: sakila-load
sakila-load: require-env-file ## Sakila テーブルを BigQuery に作成する
	bash ./sakila/load.sh --env-file "$(ENV_FILE)"
