#!/usr/bin/env bash
#
# Terraform remote state 用の Cloud Storage bucket を作成する。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
readonly SCRIPT_DIR

# shellcheck source-path=SCRIPTDIR
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

# bootstrap 処理で必要となる API 一覧
declare -ar REQUIRED_APIS=(
	"serviceusage.googleapis.com"
	"cloudresourcemanager.googleapis.com"
	"storage.googleapis.com"
)
REQUIRED_APIS_READY="true"

# 使用方法を表示する。
usage() {
	cat <<'EOF'
Usage:
  bootstrap.sh \
    --env-file ENV_FILE \
    [--dry-run]

Options:
  --env-file  Read project IDs, locations, ENVIRONMENT, and SUFFIX from this file.
  --dry-run   Show the planned actions without changing Google Cloud.
  --help, -h  Show this help.

Env file format:
  PROJECT_ID_RAW_DATA=example-raw-project
  PROJECT_ID_MART_RED=example-mart-red-project
  PROJECT_ID_MART_BLUE=example-mart-blue-project
  LOCATION_RAW_DATA=asia-northeast1
  LOCATION_MART_RED=asia-northeast1
  LOCATION_MART_BLUE=asia-northeast1
  ENVIRONMENT=dev
  SUFFIX=sample

Exit status:
  0  Success or no changes required.
  1  Authentication, authorization, or Google Cloud operation failed.
  2  Command-line input is invalid.
EOF
}

# API が有効になるまで待機する。
wait_for_api() {
	local api="$1"
	local attempt
	local enabled_api

	for ((attempt = 1; attempt <= 10; attempt++)); do
		enabled_api="$(
			gcloud services list \
				--enabled \
				--filter="config.name=${api}" \
				--format='value(config.name)' \
				--project="${PROJECT_ID_RAW_DATA}"
		)" || die "Failed to check API status: ${api}"
		if [[ "${enabled_api}" == "${api}" ]]; then
			return 0
		fi
		sleep 3
	done
	die "Timed out waiting for API enablement: ${api}"
}

# Google Cloud の API を有効化する。
enable_required_apis() {
	local api
	local enabled_api
	local -a missing_apis=()

	for api in "${REQUIRED_APIS[@]}"; do
		enabled_api="$(
			gcloud services list \
				--enabled \
				--filter="config.name=${api}" \
				--format='value(config.name)' \
				--project="${PROJECT_ID_RAW_DATA}"
		)" || die "Failed to check API status: ${api}"
		if [[ "${enabled_api}" != "${api}" ]]; then
			missing_apis+=("${api}")
		fi
	done

	if ((${#missing_apis[@]} == 0)); then
		log success "Required APIs: already enabled"
		return 0
	fi

	log warning "APIs to enable:"
	for api in "${missing_apis[@]}"; do
		log warning "  ${api}"
	done
	if [[ "${DRY_RUN}" == "true" ]]; then
		REQUIRED_APIS_READY="false"
		return 0
	fi

	# API を有効化する。
	gcloud services enable "${missing_apis[@]}" \
		--project="${PROJECT_ID_RAW_DATA}" \
		--quiet
	for api in "${missing_apis[@]}"; do
		wait_for_api "${api}"
	done
}

# Terraform remote state 向け GCS Bucket を作成する。
create_bucket() {
	local labels

	labels="managed_by=${LABEL_MANAGED_BY},purpose=${LABEL_PURPOSE}"
	labels+=",environment=${ENVIRONMENT}"

	log warning "Bucket to create: ${BUCKET_URL}"
	if [[ "${DRY_RUN}" == "true" ]]; then
		return 0
	fi

	# GCS Bucket を作成する。
	gcloud storage buckets create "${BUCKET_URL}" \
		--default-storage-class="STANDARD" \
		--location="${LOCATION_RAW_DATA}" \
		--project="${PROJECT_ID_RAW_DATA}" \
		--public-access-prevention \
		--soft-delete-duration="0" \
		--uniform-bucket-level-access \
		--quiet

	# 作成した GCS Bucket の versioning と識別用ラベルを設定する。
	gcloud storage buckets update "${BUCKET_URL}" \
		--project="${PROJECT_ID_RAW_DATA}" \
		--update-labels="${labels}" \
		--versioning \
		--quiet

	verify_bucket_configuration || die "Created bucket did not pass configuration checks."
}

# bootstrap 処理を実行する。
main() {
	parse_common_args "bootstrap" "$@"
	if [[ "${HELP_REQUESTED}" == "true" ]]; then
		usage
		return 0
	fi

	load_env_file
	validate_inputs
	derive_values
	verify_tool_versions
	verify_authentication_and_project
	print_execution_context
	enable_required_apis

	if [[ "${DRY_RUN}" == "true" && "${REQUIRED_APIS_READY}" == "false" ]]; then
		create_bucket
		log success "Result: dry-run completed; no changes were made"
		return 0
	fi

	if has_state_bucket; then
		verify_bucket_configuration || die "Existing bucket configuration does not match."
		log success "State bucket: already configured"
		log success "Result: no changes required"
		return 0
	fi

	create_bucket
	if [[ "${DRY_RUN}" == "true" ]]; then
		log success "Result: dry-run completed; no changes were made"
	else
		log success "Result: state bucket created and configured"
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
