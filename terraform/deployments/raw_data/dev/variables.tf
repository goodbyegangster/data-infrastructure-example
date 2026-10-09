variable "project_id" {
  description = "Google Cloud の project ID"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid Google Cloud project ID."
  }
}

variable "location" {
  description = "Google Cloud の location"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.location))
    error_message = "location must be a lowercase Google Cloud location."
  }
}

variable "environment" {
  description = "環境名"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.environment))
    error_message = "environment must contain lowercase letters, digits, or hyphens."
  }

  validation {
    condition     = length("dataform-runtime-${var.environment}") <= 30
    error_message = "environment must be 13 characters or fewer for the Dataform runtime service account ID."
  }

  validation {
    condition     = length("data-platform-admin-${var.environment}") <= 30
    error_message = "environment must be 10 characters or fewer for the data platform admin service account ID."
  }
}

variable "suffix" {
  description = "リソース作成時に採用される suffix 名"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.suffix))
    error_message = "suffix must contain lowercase letters, digits, or hyphens."
  }
}

variable "mart_red_runtime_service_account_email" {
  description = "staging の読み取りを許可する Mart Red runtime Service Account。初回作成時は null または空文字で権限付与を省略する。"
  type        = string
  default     = null

  validation {
    condition = var.mart_red_runtime_service_account_email == null || var.mart_red_runtime_service_account_email == "" ? true : can(regex(
      "^[a-z][a-z0-9-]{4,28}[a-z0-9]@[a-z][a-z0-9-]{4,28}[a-z0-9]\\.iam\\.gserviceaccount\\.com$",
      var.mart_red_runtime_service_account_email
    ))
    error_message = "mart_red_runtime_service_account_email must be a service account email, null, or an empty string."
  }
}

variable "mart_blue_runtime_service_account_email" {
  description = "staging の読み取りを許可する Mart Blue runtime Service Account。初回作成時は null または空文字で権限付与を省略する。"
  type        = string
  default     = null

  validation {
    condition = var.mart_blue_runtime_service_account_email == null || var.mart_blue_runtime_service_account_email == "" ? true : can(regex(
      "^[a-z][a-z0-9-]{4,28}[a-z0-9]@[a-z][a-z0-9-]{4,28}[a-z0-9]\\.iam\\.gserviceaccount\\.com$",
      var.mart_blue_runtime_service_account_email
    ))
    error_message = "mart_blue_runtime_service_account_email must be a service account email, null, or an empty string."
  }
}
