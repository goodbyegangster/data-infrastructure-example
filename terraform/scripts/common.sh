#!/usr/bin/env bash
#
# bootstrap、destroy、および Terraform 設定で共通利用する入力検証と Google Cloud 確認処理。
#
# Requirement Bash Version
#   GNU Bash 4.4 or later
#
set -Eeuo pipefail

readonly MIN_GCLOUD_VERSION="500.0.0"
readonly TERRAFORM_STATE_NAMESPACE="data-infra"
readonly LABEL_SYSTEM="data-infrastructure-example"
readonly LABEL_MANAGED_BY="bootstrap-script"
readonly LABEL_PURPOSE="terraform-state"
readonly ANSI_GREEN=$'\033[32m'
readonly ANSI_ORANGE=$'\033[38;5;208m'
readonly ANSI_RED=$'\033[31m'
readonly ANSI_RESET=$'\033[0m'

# env ファイルから入力される値
PROJECT_ID_RAW_DATA=""
PROJECT_ID_MART_RED=""
PROJECT_ID_MART_BLUE=""
LOCATION_RAW_DATA=""
LOCATION_MART_RED=""
LOCATION_MART_BLUE=""
ENVIRONMENT=""
SUFFIX=""

# env ファイルの project ID / location 変数名
readonly PROJECT_ID_VARS=(PROJECT_ID_RAW_DATA PROJECT_ID_MART_RED PROJECT_ID_MART_BLUE)
readonly LOCATION_VARS=(LOCATION_RAW_DATA LOCATION_MART_RED LOCATION_MART_BLUE)

# env ファイルの値から自動生成される値
BUCKET_NAME=""
BUCKET_URL=""
ACTIVE_ACCOUNT=""
PROJECT_NUMBER=""
ENV_FILE=""

DRY_RUN="false"
HELP_REQUESTED="false"

# エラーメッセージを表示して終了する。
die() {
	local message="$1"
	local status="${2:-1}"

	log error "ERROR: ${message}"
	exit "${status}"
}

# レベルに応じてメッセージを表示する。
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

# CLI 実行時の引数に、オプションの値が指定されていることを確認する。
assert_option_value() {
	local option="$1"
	local value="${2:-}"

	if [[ -z "${value}" || "${value}" == --* ]]; then
		die "${option} requires a value." 2
	fi
}

# CLI 実行時の必須オプションで重複指定を拒否する。
assert_option_not_set() {
	local option="$1"
	local current_value="$2"

	if [[ -n "${current_value}" ]]; then
		die "${option} must not be specified more than once." 2
	fi
}

# 共通 CLI オプションを解析する。
parse_common_args() {
	local mode="$1"
	shift

	while (($# > 0)); do
		case "$1" in
			--env-file)
				assert_option_value "$1" "${2:-}"
				assert_option_not_set "$1" "${ENV_FILE}"
				ENV_FILE="$2"
				shift 2
				;;
			--dry-run)
				[[ "${mode}" == "bootstrap" || "${mode}" == "destroy" ]] || die "Unknown option: $1" 2
				# shellcheck disable=SC2034 # エントリーポイントの script から参照される。
				DRY_RUN="true"
				shift
				;;
			--help | -h)
				# shellcheck disable=SC2034 # エントリーポイントの script から参照される。
				HELP_REQUESTED="true"
				shift
				;;
			*)
				die "Unknown option: $1" 2
				;;
		esac
	done
}

# env ファイルから入力値を読み込む。
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

		# 空行・コメント行をスキップ。
		if [[ "${line}" =~ ^[[:space:]]*$ || "${line}" =~ ^[[:space:]]*# ]]; then
			continue
		fi

		# KEY=VALUE 形式であるか確認して、それぞれ変数に取り出す。
		if [[ ! "${line}" =~ ^([A-Z][A-Z0-9_]*)=([^[:space:]]*)$ ]]; then
			die "Invalid entry at ${ENV_FILE}:${line_number}; expected KEY=VALUE." 2
		fi
		key="${BASH_REMATCH[1]}"
		value="${BASH_REMATCH[2]}"

		# KEY の重複確認。
		if [[ -n "${loaded_keys[${key}]:-}" ]]; then
			die "Duplicate key at ${ENV_FILE}:${line_number}: ${key}" 2
		fi
		loaded_keys["${key}"]="true"

		case "${key}" in
			PROJECT_ID_RAW_DATA)
				PROJECT_ID_RAW_DATA="${value}"
				;;
			PROJECT_ID_MART_RED)
				# shellcheck disable=SC2034 # エントリーポイントの script から参照される。
				PROJECT_ID_MART_RED="${value}"
				;;
			PROJECT_ID_MART_BLUE)
				# shellcheck disable=SC2034 # エントリーポイントの script から参照される。
				PROJECT_ID_MART_BLUE="${value}"
				;;
			LOCATION_RAW_DATA)
				LOCATION_RAW_DATA="${value}"
				;;
			LOCATION_MART_RED)
				# shellcheck disable=SC2034 # エントリーポイントの script から参照される。
				LOCATION_MART_RED="${value}"
				;;
			LOCATION_MART_BLUE)
				# shellcheck disable=SC2034 # エントリーポイントの script から参照される。
				LOCATION_MART_BLUE="${value}"
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

# 必須入力の存在と形式を検証する。
validate_inputs() {
	local name
	local value

	for name in "${PROJECT_ID_VARS[@]}" "${LOCATION_VARS[@]}" ENVIRONMENT SUFFIX; do
		[[ -n "${!name}" ]] || die "${name} is required in ${ENV_FILE}." 2
	done

	for name in "${PROJECT_ID_VARS[@]}"; do
		value="${!name}"
		if [[ ! "${value}" =~ ^[a-z][a-z0-9-]{4,28}[a-z0-9]$ ]]; then
			die "Invalid Google Cloud project ID in ${name}: ${value}" 2
		fi
	done

	for name in "${LOCATION_VARS[@]}"; do
		value="${!name}"
		if [[ ! "${value}" =~ ^[A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9]$ ]]; then
			die "Invalid Cloud Storage location in ${name}: ${value}" 2
		fi
	done

	if [[ ! "${ENVIRONMENT}" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
		die "Invalid environment: ${ENVIRONMENT}" 2
	fi

	if [[ ! "${SUFFIX}" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
		die "Invalid suffix: ${SUFFIX}" 2
	fi
}

# 検証済みの入力値から派生値を作成する。
derive_values() {
	local name

	BUCKET_NAME="${TERRAFORM_STATE_NAMESPACE}-tfstate-${SUFFIX}-${PROJECT_ID_RAW_DATA}-${ENVIRONMENT}"
	if ((${#BUCKET_NAME} < 3 || ${#BUCKET_NAME} > 63)); then
		die "Generated bucket name must contain 3 to 63 characters: ${BUCKET_NAME}" 2
	fi
	if [[ ! "${BUCKET_NAME}" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
		die "Generated bucket name is invalid: ${BUCKET_NAME}" 2
	fi

	for name in "${LOCATION_VARS[@]}"; do
		printf -v "${name}" '%s' "${!name^^}"
	done
	BUCKET_URL="gs://${BUCKET_NAME}"
}

# ドット区切りのバージョンが最低バージョン以上か確認する。
is_version_at_least() {
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

# Bash と gcloud の最低バージョンを確認する。
verify_tool_versions() {
	local gcloud_version_output
	local gcloud_version

	if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4))); then
		die "GNU Bash 4.4 or later is required."
	fi

	command -v gcloud >/dev/null 2>&1 || die "gcloud is required."
	gcloud_version_output="$(gcloud version 2>/dev/null)" || die "Failed to run gcloud version."
	if [[ ! "${gcloud_version_output}" =~ Google\ Cloud\ SDK\ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
		die "Failed to determine the gcloud version."
	fi
	gcloud_version="${BASH_REMATCH[1]}"

	if ! is_version_at_least "${gcloud_version}" "${MIN_GCLOUD_VERSION}"; then
		die "gcloud ${MIN_GCLOUD_VERSION} or later is required; found ${gcloud_version}."
	fi
}

# Google Cloud CLI、ADC、および対象 project へのアクセス可否を確認する。
verify_authentication_and_project() {
	ACTIVE_ACCOUNT="$(
		gcloud auth list \
			--filter='status:ACTIVE' \
			--format='value(account)' \
			--project="${PROJECT_ID_RAW_DATA}" \
			2>/dev/null
	)"
	[[ -n "${ACTIVE_ACCOUNT}" ]] || die "No active gcloud account was found."
	if [[ "${ACTIVE_ACCOUNT}" == *$'\n'* ]]; then
		die "Multiple active gcloud accounts were found."
	fi

	gcloud auth print-access-token \
		--account="${ACTIVE_ACCOUNT}" \
		--project="${PROJECT_ID_RAW_DATA}" \
		>/dev/null 2>&1 || die "Google Cloud CLI authentication failed."

	gcloud auth application-default print-access-token \
		--project="${PROJECT_ID_RAW_DATA}" \
		>/dev/null 2>&1 || die "ADC authentication failed. Run gcloud auth application-default login."

	PROJECT_NUMBER="$(
		gcloud projects describe "${PROJECT_ID_RAW_DATA}" \
			--format='value(projectNumber)' \
			--project="${PROJECT_ID_RAW_DATA}" \
			2>/dev/null
	)" || die "Failed to access project: ${PROJECT_ID_RAW_DATA}"
	[[ "${PROJECT_NUMBER}" =~ ^[0-9]+$ ]] || die "Failed to determine the project number."
}

# 処理対象となる情報を表示する。
print_execution_context() {
	log success "Env file: ${ENV_FILE}"
	log success "Active account: ${ACTIVE_ACCOUNT}"
	log success "Project ID (raw data): ${PROJECT_ID_RAW_DATA}"
	log success "Project number: ${PROJECT_NUMBER}"
	log success "Location: ${LOCATION_RAW_DATA}"
	log success "Environment: ${ENVIRONMENT}"
	log success "State bucket: ${BUCKET_NAME}"
}

# 対象 Google Cloud Project に同名 Bucket が存在するか確認する。
has_state_bucket() {
	local bucket
	local bucket_list

	bucket_list="$(
		gcloud storage buckets list \
			--format='value(name)' \
			--project="${PROJECT_ID_RAW_DATA}"
	)" || die "Failed to list buckets in project: ${PROJECT_ID_RAW_DATA}"

	while IFS= read -r bucket; do
		if [[ "${bucket}" == "${BUCKET_NAME}" ]]; then
			return 0
		fi
	done <<<"${bucket_list}"

	return 1
}

# 指定したフィールドの GCS Bucket 属性を取得する。
get_bucket_attribute() {
	local field="$1"

	gcloud storage buckets describe "${BUCKET_URL}" \
		--raw \
		--format="value(${field})" \
		--project="${PROJECT_ID_RAW_DATA}"
}

# GCS Bucket の属性が期待値と一致することを確認する。
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
	local actual_system
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
	actual_system="$(get_bucket_attribute 'labels.system')"
	actual_managed_by="$(get_bucket_attribute 'labels.managed_by')"
	actual_purpose="$(get_bucket_attribute 'labels.purpose')"
	actual_environment="$(get_bucket_attribute 'labels.environment')"
	actual_retention="$(get_bucket_attribute 'retentionPolicy.retentionPeriod')"
	actual_soft_delete="$(get_bucket_attribute 'softDeletePolicy.retentionDurationSeconds')"
	actual_lifecycle="$(get_bucket_attribute 'lifecycle.rule')"

	assert_bucket_attribute \
		"project number" "${PROJECT_NUMBER}" "${actual_project_number}" || valid="false"
	assert_bucket_attribute "location" "${LOCATION_RAW_DATA}" "${actual_location^^}" || valid="false"
	assert_bucket_attribute \
		"storage class" "STANDARD" "${actual_storage_class^^}" || valid="false"
	assert_bucket_attribute \
		"uniform access" "true" "${actual_uniform_access,,}" || valid="false"
	assert_bucket_attribute \
		"public access prevention" "enforced" \
		"${actual_public_access_prevention,,}" || valid="false"
	assert_bucket_attribute "versioning" "true" "${actual_versioning,,}" || valid="false"
	assert_bucket_attribute \
		"system label" "${LABEL_SYSTEM}" "${actual_system}" || valid="false"
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
