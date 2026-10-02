variable "project_id_raw_data" {
  description = "Google Cloud project ID for raw data resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id_raw_data))
    error_message = "project_id_raw_data must be a valid Google Cloud project ID."
  }
}

variable "project_id_mart_red" {
  description = "Google Cloud project ID for the red mart (currently unused)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id_mart_red))
    error_message = "project_id_mart_red must be a valid Google Cloud project ID."
  }
}

variable "project_id_mart_blue" {
  description = "Google Cloud project ID for the blue mart (currently unused)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id_mart_blue))
    error_message = "project_id_mart_blue must be a valid Google Cloud project ID."
  }
}

variable "location_raw_data" {
  description = "Google Cloud location for raw data regional resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.location_raw_data))
    error_message = "location_raw_data must be a lowercase Google Cloud location."
  }
}

variable "location_mart_red" {
  description = "Google Cloud location for the red mart (currently unused)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.location_mart_red))
    error_message = "location_mart_red must be a lowercase Google Cloud location."
  }
}

variable "location_mart_blue" {
  description = "Google Cloud location for the blue mart (currently unused)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.location_mart_blue))
    error_message = "location_mart_blue must be a lowercase Google Cloud location."
  }
}

variable "environment" {
  description = "Deployment environment name"
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
  description = "Resource name suffix used to distinguish deployments"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.suffix))
    error_message = "suffix must contain lowercase letters, digits, or hyphens."
  }
}
