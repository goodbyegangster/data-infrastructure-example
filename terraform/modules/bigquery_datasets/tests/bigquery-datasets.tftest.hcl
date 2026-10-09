# Google Cloud へ接続せず、Google Provider の schema を使って BigQuery Dataset の plan を検証する。
mock_provider "google" {}

variables {
  project_id             = "example-project"
  location               = "asia-northeast1"
  environment            = "dev"
  suffix                 = "sample"
  owner_email            = "data-platform-admin-dev@example-project.iam.gserviceaccount.com"
  dataform_runtime_email = "dataform-runtime-dev@example-project.iam.gserviceaccount.com"
  datasets = {
    raw_sakila = {
      description  = "Sakila raw data."
      runtime_role = "READER"
    }
    stg_sakila = {
      description  = "Sakila staging data."
      runtime_role = "WRITER"
    }
  }
}

# 複数の BigQuery Dataset に共通ポリシーが適用されることを検証する。
run "configures_datasets_with_common_policy" {
  command = plan

  # 入力した用途ごとに BigQuery Dataset が作成されることを保証する。
  assert {
    condition = toset(keys(google_bigquery_dataset.managed)) == toset([
      "raw_sakila",
      "stg_sakila",
    ])
    error_message = "A BigQuery Dataset must be created for each datasets entry."
  }

  # Datasetが指定した Project と Location に作成されることを保証する。
  assert {
    condition = alltrue([
      for dataset in google_bigquery_dataset.managed :
      dataset.project == var.project_id && dataset.location == var.location
    ])
    error_message = "BigQuery Datasets must use the configured project and location."
  }

  # Dataset 名と表示名に共通の命名規則が適用されることを保証する。
  assert {
    condition = alltrue([
      for dataset in google_bigquery_dataset.managed :
      dataset.friendly_name == dataset.dataset_id
    ])
    error_message = "Each BigQuery Dataset friendly name must match its dataset ID."
  }

  # Dataset で大文字小文字を区別し、論理バイト課金を使用することを保証する。
  assert {
    condition = alltrue([
      for dataset in google_bigquery_dataset.managed :
      !dataset.is_case_insensitive && dataset.storage_billing_model == "LOGICAL"
    ])
    error_message = "BigQuery Datasets must use case-sensitive names and logical storage billing."
  }

  # Terraform destroy で Dataset 内の table や view を含めて削除できることを保証する。
  assert {
    condition = alltrue([
      for dataset in google_bigquery_dataset.managed :
      dataset.delete_contents_on_destroy && dataset.deletion_policy == "DELETE"
    ])
    error_message = "BigQuery Datasets and their contents must be deleted by Terraform destroy."
  }

  # 各 Dataset の Owner と runtime 権限を指定した Service Account だけに限定することを保証する。
  assert {
    condition = alltrue([
      for name, dataset in google_bigquery_dataset.managed :
      toset([
        for grant in dataset.access : "${grant.role}:${grant.user_by_email}"
        ]) == toset([
        "OWNER:${var.owner_email}",
        "${var.datasets[name].runtime_role}:${var.dataform_runtime_email}",
      ])
    ])
    error_message = "Each BigQuery Dataset must have only the configured owner and runtime access."
  }
}

# 別 Project の runtime に staging だけの読み取り権限を付与することを検証する。
run "grants_additional_reader_only_to_staging" {
  command = plan

  variables {
    datasets = {
      raw_sakila = {
        description  = "Sakila raw data."
        runtime_role = "READER"
      }
      stg_sakila = {
        description   = "Sakila staging data."
        runtime_role  = "WRITER"
        reader_emails = ["dataform-runtime-dev@example-red-project.iam.gserviceaccount.com"]
      }
    }
  }

  # Mart runtime には staging の READER 権限だけが追加されることを保証する。
  assert {
    condition = (
      length(google_bigquery_dataset.managed["raw_sakila"].access) == 2 &&
      length(google_bigquery_dataset.managed["stg_sakila"].access) == 3 &&
      length([
        for grant in google_bigquery_dataset.managed["stg_sakila"].access : grant
        if grant.role == "READER" && grant.user_by_email == "dataform-runtime-dev@example-red-project.iam.gserviceaccount.com"
      ]) == 1
    )
    error_message = "The additional runtime must receive only READER access to staging."
  }
}
