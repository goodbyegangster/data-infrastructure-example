# 指定された BigQuery Dataset を共通ポリシーで作成する。
resource "google_bigquery_dataset" "managed" {
  for_each = var.datasets

  project               = var.project_id
  dataset_id            = "${each.key}_${replace(var.suffix, "-", "_")}_${replace(var.environment, "-", "_")}"
  friendly_name         = "${each.key}_${replace(var.suffix, "-", "_")}_${replace(var.environment, "-", "_")}"
  description           = each.value.description
  location              = var.location
  is_case_insensitive   = false
  default_collation     = ""
  storage_billing_model = "LOGICAL"

  delete_contents_on_destroy = true
  deletion_policy            = "DELETE"

  access {
    role          = "OWNER"
    user_by_email = var.owner_email
  }

  access {
    role          = each.value.runtime_role
    user_by_email = var.dataform_runtime_email
  }
}
