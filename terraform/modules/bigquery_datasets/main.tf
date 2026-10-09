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

  # Dataset が属する Google Project の全 Owner に管理権限を付与する。
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "OWNER"
    user_by_email = var.owner_email
  }

  # Dataform runtime に指定した権限を付与する。
  access {
    role          = each.value.runtime_role
    user_by_email = var.dataform_runtime_email
  }

  # 別 Project の Dataform runtime などに追加の読み取り権限を付与する。
  dynamic "access" {
    for_each = each.value.reader_emails

    content {
      role          = "READER"
      user_by_email = access.value
    }
  }
}
