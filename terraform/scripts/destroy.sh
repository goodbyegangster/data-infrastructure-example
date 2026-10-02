#!/usr/bin/env bash
#
# bootstrapで作成したTerraform remote state用bucketと全object versionを削除する。
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
    [--execute]

Options:
  --env-file  Read PROJECT_ID, LOCATION, ENVIRONMENT, and SUFFIX from this file.
  --execute   Delete the bucket after interactive confirmation.
  --help, -h  Show this help.

Env file format:
  PROJECT_ID=example-project
  LOCATION=asia-northeast1
  ENVIRONMENT=dev
  SUFFIX=sample

Without --execute, this command only lists the resources that would be deleted.

Exit status:
  0  Success, preview completed, or the bucket does not exist.
  1  Authentication, authorization, confirmation, or deletion failed.
  2  Command-line input is invalid.
EOF
}

# bucket内のlive objectとnoncurrent versionを一覧表示する。
list_bucket_contents() {
	local object_list

	if ! object_list="$(
		gcloud storage ls "${BUCKET_URL}/" \
			--all-versions \
			--recursive \
			--project="${PROJECT_ID}"
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

# bucket名の再入力による削除確認を行う。
confirm_deletion() {
	local confirmation

	[[ -t 0 ]] || die "Interactive input is required when --execute is specified."
	log warning "Type the bucket name to confirm permanent deletion: ${BUCKET_NAME}"
	printf '> '
	read -r confirmation
	[[ "${confirmation}" == "${BUCKET_NAME}" ]] || die "Confirmation did not match."
}

# bucketと全object versionを削除する。
delete_bucket() {
	# 副作用: 全object versionを削除した後にbucket自体を削除する。
	gcloud storage rm "${BUCKET_URL}/" \
		--project="${PROJECT_ID}" \
		--recursive \
		--quiet
}

# destroy処理を実行する。
main() {
	parse_common_args "destroy" "$@"
	if [[ "${HELP_REQUESTED}" == "true" ]]; then
		usage
		return 0
	fi

	load_env_file
	validate_and_derive_inputs
	check_tool_versions
	check_authentication_and_project
	print_execution_context

	if ! bucket_exists_in_project; then
		log success "State bucket: not found"
		log success "Result: no resources to delete"
		return 0
	fi

	verify_bucket_configuration || die "Bucket is not managed by this bootstrap configuration."
	list_bucket_contents

	if [[ "${EXECUTE}" != "true" ]]; then
		log warning "Result: preview completed; rerun with --execute to delete the bucket"
		return 0
	fi

	confirm_deletion
	delete_bucket

	if bucket_exists_in_project; then
		die "Bucket still exists after the deletion command: ${BUCKET_NAME}"
	fi
	log success "Deleted bucket: ${BUCKET_NAME}"
	log success "Result: bootstrap resources deleted"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
