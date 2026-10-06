variable "project_id" {
  description = "BigQuery Dataset を作成する Google Cloud Project ID"
  type        = string
}

variable "location" {
  description = "BigQuery Dataset を作成する Location"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
}

variable "suffix" {
  description = "リソース名を識別する Suffix"
  type        = string
}

variable "owner_email" {
  description = "BigQuery Dataset の Owner とする Service Account のメールアドレス"
  type        = string
}

variable "dataform_runtime_email" {
  description = "BigQuery Dataset を利用する dataform runtime Service Account のメールアドレス"
  type        = string
}

variable "datasets" {
  description = "作成する BigQuery Dataset 名"
  type = map(object({
    description  = string
    runtime_role = string
  }))

  validation {
    condition     = length(var.datasets) > 0
    error_message = "datasets must contain at least one BigQuery Dataset."
  }

  validation {
    condition = alltrue([
      for name in keys(var.datasets) :
      can(regex("^[a-z_][a-z0-9_]*$", name))
    ])
    error_message = "Each datasets key must be a valid BigQuery Dataset name component."
  }

  validation {
    condition = alltrue([
      for dataset in values(var.datasets) :
      contains(["READER", "WRITER"], dataset.runtime_role)
    ])
    error_message = "Each runtime_role must be READER or WRITER."
  }
}
