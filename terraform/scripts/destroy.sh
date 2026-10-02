#!/usr/bin/env bash
#
# bootstrap で作成した Terraform remote state 用 Bucket を削除する。
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

# 使用方法を表示する。
usage() {
	cat <<'EOF'
Usage:
  destroy.sh \
    --env-file ENV_FILE \
    [--dry-run]

Options:
  --env-file  Read project IDs, locations, ENVIRONMENT, and SUFFIX from this file.
  --dry-run   List the resources that would be deleted without changing Google Cloud.
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

Without --dry-run, the bucket is deleted after interactive confirmation.

Exit status:
  0  Success, dry-run completed, or the bucket does not exist.
  1  Authentication, authorization, confirmation, or deletion failed.
  2  Command-line input is invalid.
EOF
}

# Bucket 内のオブジェクトを一覧表示する。
list_bucket_contents() {
	local object_list

	if ! object_list="$(
		gcloud storage ls "${BUCKET_URL}/" \
			--all-versions \
			--recursive \
			--project="${PROJECT_ID_RAW_DATA}"
	)"; then
		die "Failed to list objects and versions in bucket: ${BUCKET_NAME}"
	fi

	log warning "Objects and versions to delete:"
	if [[ -n "${object_list}" ]]; then
		log warning "${object_list}"
	else
		log warning "  <none>"
	fi
}

# Bucket 名の再入力による削除確認を行う。
confirm_deletion() {
	local confirmation

	[[ -t 0 ]] || die "Interactive input is required unless --dry-run is specified."
	log warning "Type the bucket name to confirm permanent deletion: ${BUCKET_NAME}"
	printf '> '
	read -r confirmation
	[[ "${confirmation}" == "${BUCKET_NAME}" ]] || die "Confirmation did not match."
}

# Bucketを削除する。
delete_bucket() {
	# 全 object version を削除した後に Bucket を削除する。
	gcloud storage rm "${BUCKET_URL}/" \
		--project="${PROJECT_ID_RAW_DATA}" \
		--recursive \
		--quiet
}

# destroy 処理を実行する。
main() {
	parse_common_args "destroy" "$@"
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

	if ! has_state_bucket; then
		log success "State bucket: not found"
		log success "Result: no resources to delete"
		return 0
	fi

	verify_bucket_configuration || die "Bucket is not managed by this bootstrap configuration."
	list_bucket_contents

	if [[ "${DRY_RUN}" == "true" ]]; then
		log success "Result: dry-run completed; no changes were made"
		return 0
	fi

	confirm_deletion
	delete_bucket

	if has_state_bucket; then
		die "Bucket still exists after the deletion command: ${BUCKET_NAME}"
	fi
	log success "Deleted bucket: ${BUCKET_NAME}"
	log success "Result: bootstrap resources deleted"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
