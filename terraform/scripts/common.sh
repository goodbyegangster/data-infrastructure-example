#!/usr/bin/env bash
#
# bootstrap、destroy、および Terraform 設定で共通利用する入力検証と Google Cloud 確認処理。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

readonly MIN_GCLOUD_VERSION="500.0.0"
readonly BUCKET_PREFIX="dataform-tfstate"
readonly BACKEND_PREFIX_BASE="dataform"
readonly LABEL_MANAGED_BY="dataform-bootstrap"
readonly LABEL_PURPOSE="terraform-state"
readonly ANSI_GREEN=$'\033[32m'
readonly ANSI_ORANGE=$'\033[38;5;208m'
readonly ANSI_RED=$'\033[31m'
readonly ANSI_RESET=$'\033[0m'

PROJECT_ID=""
LOCATION=""
ENVIRONMENT=""
SUFFIX=""
BUCKET_NAME=""
BUCKET_URL=""
BACKEND_PREFIX=""
ACTIVE_ACCOUNT=""
PROJECT_NUMBER=""
ENV_FILE=""

DRY_RUN="false"
EXECUTE="false"
HELP_REQUESTED="false"

# エラーメッセージを表示して終了する。
die() {
	local message="$1"
	local status="${2:-1}"

	log error "ERROR: ${message}"
	exit "${status}"
}

# levelに応じて色分けしたメッセージを表示する。
log() {
	local level="$1"
	local color
	local output_fd
	local use_color="false"
	shift

	case "${level}" in
		success)
			color="${ANSI_GREEN}"
			output_fd=1
			;;
		warning)
			color="${ANSI_ORANGE}"
			output_fd=1
			;;
		error)
			color="${ANSI_RED}"
			output_fd=2
			;;
		*)
			printf 'ERROR: Unknown log level: %s\n' "${level}" >&2
			return 2
			;;
	esac

	if [[ -z "${NO_COLOR:-}" && -t "${output_fd}" ]]; then
		use_color="true"
	fi

	if [[ "${use_color}" == "true" ]]; then
		printf '%s%s%s\n' "${color}" "$*" "${ANSI_RESET}" >&"${output_fd}"
	else
		printf '%s\n' "$*" >&"${output_fd}"
	fi
}

# オプションに値が指定されていることを確認する。
require_option_value() {
	local option="$1"
	local value="${2:-}"

	if [[ -z "${value}" || "${value}" == --* ]]; then
		die "${option} requires a value." 2
	fi
}

# 必須オプションの重複指定を拒否する。
set_option_once() {
	local option="$1"
	local current_value="$2"

	if [[ -n "${current_value}" ]]; then
		die "${option} must not be specified more than once." 2
	fi
}

# 共通CLIオプションを解析する。
parse_common_args() {
	local mode="$1"
	shift

	while (($# > 0)); do
		case "$1" in
			--env-file)
				require_option_value "$1" "${2:-}"
				set_option_once "$1" "${ENV_FILE}"
				ENV_FILE="$2"
				shift 2
				;;
			--dry-run)
				[[ "${mode}" == "bootstrap" ]] || die "Unknown option: $1" 2
				# shellcheck disable=SC2034 # エントリーポイントのscriptから参照される変数となる。
				DRY_RUN="true"
				shift
				;;
			--execute)
				[[ "${mode}" == "destroy" ]] || die "Unknown option: $1" 2
				# shellcheck disable=SC2034 # エントリーポイントのscriptから参照される変数となる。
				EXECUTE="true"
				shift
				;;
			--help | -h)
				# shellcheck disable=SC2034 # エントリーポイントのscriptから参照される変数となる。
				HELP_REQUESTED="true"
				shift
				;;
			*)
				die "Unknown option: $1" 2
				;;
		esac
	done
}

# env fileから許可した入力値だけを読み込む。
load_env_file() {
	local line=""
	local line_number=0
	local key
	local value
	local -A loaded_keys=()

	[[ -n "${ENV_FILE}" ]] || die "--env-file is required." 2
	[[ -f "${ENV_FILE}" ]] || die "Env file was not found: ${ENV_FILE}" 2
	[[ -r "${ENV_FILE}" ]] || die "Env file is not readable: ${ENV_FILE}" 2

	while IFS= read -r line || [[ -n "${line}" ]]; do
		((line_number += 1))
		line="${line%$'\r'}"
		if [[ "${line}" =~ ^[[:space:]]*$ || "${line}" =~ ^[[:space:]]*# ]]; then
			continue
		fi
		if [[ ! "${line}" =~ ^([A-Z][A-Z0-9_]*)=([^[:space:]]*)$ ]]; then
			die "Invalid entry at ${ENV_FILE}:${line_number}; expected KEY=VALUE." 2
		fi

		key="${BASH_REMATCH[1]}"
		value="${BASH_REMATCH[2]}"
		if [[ -n "${loaded_keys[${key}]:-}" ]]; then
			die "Duplicate key at ${ENV_FILE}:${line_number}: ${key}" 2
		fi
		loaded_keys["${key}"]="true"

		case "${key}" in
			PROJECT_ID)
				PROJECT_ID="${value}"
				;;
			LOCATION)
				LOCATION="${value}"
				;;
			ENVIRONMENT)
				ENVIRONMENT="${value}"
				;;
			SUFFIX)
				SUFFIX="${value}"
				;;
			*)
				die "Unknown key at ${ENV_FILE}:${line_number}: ${key}" 2
				;;
		esac
	done <"${ENV_FILE}"
}

# 必須入力を検証してbucket名などの派生値を設定する。
validate_and_derive_inputs() {
	[[ -n "${PROJECT_ID}" ]] || die "PROJECT_ID is required in ${ENV_FILE}." 2
	[[ -n "${LOCATION}" ]] || die "LOCATION is required in ${ENV_FILE}." 2
	[[ -n "${ENVIRONMENT}" ]] || die "ENVIRONMENT is required in ${ENV_FILE}." 2
	[[ -n "${SUFFIX}" ]] || die "SUFFIX is required in ${ENV_FILE}." 2

	if [[ ! "${PROJECT_ID}" =~ ^[a-z][a-z0-9-]{4,28}[a-z0-9]$ ]]; then
		die "Invalid Google Cloud project ID: ${PROJECT_ID}" 2
	fi
	if [[ ! "${LOCATION}" =~ ^[A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9]$ ]]; then
		die "Invalid Cloud Storage location: ${LOCATION}" 2
	fi
	if [[ ! "${ENVIRONMENT}" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
		die "Invalid environment: ${ENVIRONMENT}" 2
	fi
	if [[ ! "${SUFFIX}" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
		die "Invalid suffix: ${SUFFIX}" 2
	fi

	BUCKET_NAME="${BUCKET_PREFIX}-${SUFFIX}-${PROJECT_ID}-${ENVIRONMENT}"
	if ((${#BUCKET_NAME} < 3 || ${#BUCKET_NAME} > 63)); then
		die "Generated bucket name must contain 3 to 63 characters: ${BUCKET_NAME}" 2
	fi
	if [[ ! "${BUCKET_NAME}" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
		die "Generated bucket name is invalid: ${BUCKET_NAME}" 2
	fi

	LOCATION="${LOCATION^^}"
	BUCKET_URL="gs://${BUCKET_NAME}"
	BACKEND_PREFIX="${BACKEND_PREFIX_BASE}/${ENVIRONMENT}"
}

# ドット区切りのバージョンが最低バージョン以上か確認する。
version_is_at_least() {
	local current="$1"
	local minimum="$2"
	local -a current_parts=()
	local -a minimum_parts=()
	local index

	IFS='.' read -r -a current_parts <<<"${current}"
	IFS='.' read -r -a minimum_parts <<<"${minimum}"

	for index in 0 1 2; do
		if ((10#${current_parts[index]:-0} > 10#${minimum_parts[index]:-0})); then
			return 0
		fi
		if ((10#${current_parts[index]:-0} < 10#${minimum_parts[index]:-0})); then
			return 1
		fi
	done
	return 0
}

# Bashとgcloudの最低バージョンを確認する。
check_tool_versions() {
	local version_output
	local gcloud_version

	if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4))); then
		die "GNU Bash 4.4 or later is required."
	fi
	command -v gcloud >/dev/null 2>&1 || die "gcloud is required."

	version_output="$(gcloud version 2>/dev/null)" || die "Failed to run gcloud version."
	if [[ ! "${version_output}" =~ Google\ Cloud\ SDK\ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
		die "Failed to determine the gcloud version."
	fi
	gcloud_version="${BASH_REMATCH[1]}"

	if ! version_is_at_least "${gcloud_version}" "${MIN_GCLOUD_VERSION}"; then
		die "gcloud ${MIN_GCLOUD_VERSION} or later is required; found ${gcloud_version}."
	fi
}

# Google Cloud CLI、ADC、および対象projectへのアクセスを確認する。
check_authentication_and_project() {
	ACTIVE_ACCOUNT="$(
		gcloud auth list \
			--filter='status:ACTIVE' \
			--format='value(account)' \
			--project="${PROJECT_ID}" \
			2>/dev/null
	)"
	[[ -n "${ACTIVE_ACCOUNT}" ]] || die "No active gcloud account was found."
	if [[ "${ACTIVE_ACCOUNT}" == *$'\n'* ]]; then
		die "Multiple active gcloud accounts were found."
	fi

	gcloud auth print-access-token \
		--account="${ACTIVE_ACCOUNT}" \
		--project="${PROJECT_ID}" \
		>/dev/null 2>&1 || die "Google Cloud CLI authentication failed."

	gcloud auth application-default print-access-token \
		--project="${PROJECT_ID}" \
		>/dev/null 2>&1 || die "ADC authentication failed. Run gcloud auth application-default login."

	PROJECT_NUMBER="$(
		gcloud projects describe "${PROJECT_ID}" \
			--format='value(projectNumber)' \
			--project="${PROJECT_ID}" \
			2>/dev/null
	)" || die "Failed to access project: ${PROJECT_ID}"
	[[ "${PROJECT_NUMBER}" =~ ^[0-9]+$ ]] || die "Failed to determine the project number."
}

# 対象project、実行主体、および派生値を表示する。
print_execution_context() {
	log success "Env file: ${ENV_FILE}"
	log success "Active account: ${ACTIVE_ACCOUNT}"
	log success "Project ID: ${PROJECT_ID}"
	log success "Project number: ${PROJECT_NUMBER}"
	log success "Location: ${LOCATION}"
	log success "Environment: ${ENVIRONMENT}"
	log success "State bucket: ${BUCKET_NAME}"
	log success "Backend prefix: ${BACKEND_PREFIX}"
}

# 対象projectに同名bucketが存在するか確認する。
bucket_exists_in_project() {
	local bucket
	local bucket_list

	bucket_list="$(
		gcloud storage buckets list \
			--format='value(name)' \
			--project="${PROJECT_ID}"
	)" || die "Failed to list buckets in project: ${PROJECT_ID}"

	while IFS= read -r bucket; do
		if [[ "${bucket}" == "${BUCKET_NAME}" ]]; then
			return 0
		fi
	done <<<"${bucket_list}"

	return 1
}

# bucket属性を1つ取得する。
get_bucket_attribute() {
	local field="$1"

	gcloud storage buckets describe "${BUCKET_URL}" \
		--raw \
		--format="value(${field})" \
		--project="${PROJECT_ID}"
}

# bucket属性が期待値と一致することを確認する。
assert_bucket_attribute() {
	local description="$1"
	local expected="$2"
	local actual="$3"

	if [[ "${actual}" != "${expected}" ]]; then
		log error \
			"ERROR: Bucket ${description} mismatch: expected ${expected}, found ${actual:-<empty>}."
		return 1
	fi
}

# 既存bucketがbootstrap仕様と完全に一致することを確認する。
verify_bucket_configuration() {
	local valid="true"
	local actual_project_number
	local actual_location
	local actual_storage_class
	local actual_uniform_access
	local actual_public_access_prevention
	local actual_versioning
	local actual_managed_by
	local actual_purpose
	local actual_environment
	local actual_retention
	local actual_soft_delete
	local actual_lifecycle

	actual_project_number="$(get_bucket_attribute 'projectNumber')"
	actual_location="$(get_bucket_attribute 'location')"
	actual_storage_class="$(get_bucket_attribute 'storageClass')"
	actual_uniform_access="$(
		get_bucket_attribute 'iamConfiguration.uniformBucketLevelAccess.enabled'
	)"
	actual_public_access_prevention="$(
		get_bucket_attribute 'iamConfiguration.publicAccessPrevention'
	)"
	actual_versioning="$(get_bucket_attribute 'versioning.enabled')"
	actual_managed_by="$(get_bucket_attribute 'labels.managed_by')"
	actual_purpose="$(get_bucket_attribute 'labels.purpose')"
	actual_environment="$(get_bucket_attribute 'labels.environment')"
	actual_retention="$(get_bucket_attribute 'retentionPolicy.retentionPeriod')"
	actual_soft_delete="$(get_bucket_attribute 'softDeletePolicy.retentionDurationSeconds')"
	actual_lifecycle="$(get_bucket_attribute 'lifecycle.rule')"

	assert_bucket_attribute \
		"project number" "${PROJECT_NUMBER}" "${actual_project_number}" || valid="false"
	assert_bucket_attribute "location" "${LOCATION}" "${actual_location^^}" || valid="false"
	assert_bucket_attribute \
		"storage class" "STANDARD" "${actual_storage_class^^}" || valid="false"
	assert_bucket_attribute \
		"uniform access" "true" "${actual_uniform_access,,}" || valid="false"
	assert_bucket_attribute \
		"public access prevention" "enforced" \
		"${actual_public_access_prevention,,}" || valid="false"
	assert_bucket_attribute "versioning" "true" "${actual_versioning,,}" || valid="false"
	assert_bucket_attribute \
		"managed_by label" "${LABEL_MANAGED_BY}" "${actual_managed_by}" || valid="false"
	assert_bucket_attribute \
		"purpose label" "${LABEL_PURPOSE}" "${actual_purpose}" || valid="false"
	assert_bucket_attribute \
		"environment label" "${ENVIRONMENT}" "${actual_environment}" || valid="false"

	if [[ -n "${actual_retention}" && "${actual_retention}" != "0" ]]; then
		log error \
			"ERROR: Bucket retention policy must not be configured; found ${actual_retention}."
		valid="false"
	fi
	if [[ -n "${actual_soft_delete}" && "${actual_soft_delete}" != "0" ]]; then
		log error "ERROR: Bucket soft delete must be disabled; found ${actual_soft_delete}."
		valid="false"
	fi
	if [[ -n "${actual_lifecycle}" ]]; then
		log error "ERROR: Bucket lifecycle rules must not be configured."
		valid="false"
	fi

	[[ "${valid}" == "true" ]]
}
