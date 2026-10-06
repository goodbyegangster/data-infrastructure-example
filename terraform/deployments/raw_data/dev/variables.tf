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
