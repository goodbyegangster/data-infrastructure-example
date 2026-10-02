#!/usr/bin/env bash
#
# env fileから対象を特定し、Dataform検証用のSakilaテーブルをBigQueryへ投入する。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
readonly SCRIPT_DIR
SQL_FILE="${SCRIPT_DIR}/sakila.sql"
readonly SQL_FILE

# shellcheck source-path=SCRIPTDIR
# shellcheck source=../bootstrap/scripts/common.sh
source "${SCRIPT_DIR}/../scripts/common.sh"

# 使用方法を表示する。
usage() {
	cat <<'USAGE'
Usage:
  load.sh --env-file ENV_FILE

Required option:
  --env-file ENV_FILE  Project IDs, locations, ENVIRONMENT, and SUFFIX input file

Other option:
  -h, --help            Show this help

Example:
  ./sakila/load.sh --env-file config/dev.env.local

Exit status:
  0  Sakila tables loaded successfully
  1  Authentication, authorization, or BigQuery operation failed
  2  Invalid command-line option or input
USAGE
}

# Sakilaテーブルを既存の検証用datasetへ投入する。
main() {
	local dataset_id
	local query_location
	local terraform_root

	parse_common_args "load-sakila" "$@"
	if [[ "${HELP_REQUESTED}" == "true" ]]; then
		usage
		return 0
	fi

	load_env_file
	validate_inputs
	derive_values
	verify_tool_versions
	command -v bq >/dev/null 2>&1 || die "bq is required."
	command -v terraform >/dev/null 2>&1 || die "terraform is required."
	verify_authentication_and_project

	terraform_root="${SCRIPT_DIR}/../terraform/environments/${ENVIRONMENT}"
	[[ -d "${terraform_root}" ]] || die "Terraform root was not found: ${terraform_root}"
	dataset_id="$(terraform -chdir="${terraform_root}" output -raw sakila_dataset_id)" \
		|| die "Failed to read sakila_dataset_id from Terraform state."
	[[ "${dataset_id}" =~ ^[A-Za-z0-9_]+$ ]] \
		|| die "Terraform returned an invalid Sakila dataset ID: ${dataset_id}"
	query_location="${LOCATION_RAW_DATA,,}"

	log success "Env file: ${ENV_FILE}"
	log success "Active account: ${ACTIVE_ACCOUNT}"
	log success "Project ID: ${PROJECT_ID_RAW_DATA}"
	log success "Location: ${query_location}"
	log warning "Sakila dataset: ${PROJECT_ID_RAW_DATA}.${dataset_id}"

	bq --project_id="${PROJECT_ID_RAW_DATA}" show \
		--dataset \
		"${PROJECT_ID_RAW_DATA}:${dataset_id}" \
		>/dev/null || die "Sakila dataset was not found: ${PROJECT_ID_RAW_DATA}.${dataset_id}"

	log warning "Existing Sakila tables will be replaced."
	# 副作用: 対象datasetにある同名テーブルを検証用データで置き換える。
	bq --project_id="${PROJECT_ID_RAW_DATA}" --location="${query_location}" query \
		--parameter="project_id:STRING:${PROJECT_ID_RAW_DATA}" \
		--parameter="dataset_id:STRING:${dataset_id}" \
		--use_legacy_sql=false \
		<"${SQL_FILE}"

	log success "Result: Sakila tables loaded successfully"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
