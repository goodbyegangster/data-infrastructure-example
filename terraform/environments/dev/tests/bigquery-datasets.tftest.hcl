# Google Cloudへ接続せず、Google Providerのschemaを使ってBigQuery datasetのplanを検証する。
mock_provider "google" {
  override_during = plan

  # DataformサービスエージェントのIDを組み立てるproject numberを固定する。
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }

  # root module内のIAMをplanできるようにService Accountのcomputed値を固定する。
  mock_resource "google_service_account" {
    defaults = {
      email  = "dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      member = "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      name   = "projects/example-project/serviceAccounts/dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    }
  }
}

variables {
  project_id  = "example-project"
  location    = "asia-northeast1"
  environment = "dev"
  suffix      = "sample"
}

# Sakila入力用、Dataform出力用、assertion用のBigQuery datasetが作成されることを検証する。
run "configures_dataform_datasets" {
  command = plan

  # 用途ごとに固定した3つのdataset IDが使われることを保証する。
  assert {
    condition = toset([
      google_bigquery_dataset.sakila.dataset_id,
      google_bigquery_dataset.dataform.dataset_id,
      google_bigquery_dataset.dataform_assertions.dataset_id,
      ]) == toset([
      "sakila_sample_dev",
      "dataform_sample_dev",
      "dataform_assertions_sample_dev",
    ])
    error_message = "The Sakila input, Dataform output, and assertion datasets must be created."
  }

  # 3つのdatasetが指定したprojectとlocationに作成されることを保証する。
  assert {
    condition = alltrue([
      for dataset in [
        google_bigquery_dataset.sakila,
        google_bigquery_dataset.dataform,
        google_bigquery_dataset.dataform_assertions,
      ] : dataset.project == var.project_id && dataset.location == var.location
    ])
    error_message = "The Dataform datasets must be created in the target project and location."
  }

  # コンソール上の表示名がそれぞれのdataset IDと一致することを保証する。
  assert {
    condition = alltrue([
      google_bigquery_dataset.sakila.friendly_name == google_bigquery_dataset.sakila.dataset_id,
      google_bigquery_dataset.dataform.friendly_name == google_bigquery_dataset.dataform.dataset_id,
      google_bigquery_dataset.dataform_assertions.friendly_name == google_bigquery_dataset.dataform_assertions.dataset_id,
    ])
    error_message = "Each BigQuery dataset friendly name must match its dataset ID."
  }

  # Terraform destroyでdataset内のtableやviewを含めて削除できることを保証する。
  assert {
    condition = alltrue([
      for dataset in [
        google_bigquery_dataset.sakila,
        google_bigquery_dataset.dataform,
        google_bigquery_dataset.dataform_assertions,
      ] : dataset.delete_contents_on_destroy && dataset.deletion_policy == "DELETE"
    ])
    error_message = "The validation datasets and their contents must be deleted by Terraform destroy."
  }
}

# BigQueryで使用できないハイフンがdataset IDではアンダースコアへ変換されることを検証する。
run "normalizes_dataset_name_components" {
  command = plan

  variables {
    environment = "dev-env"
    suffix      = "sample-a"
  }

  # suffixと環境名のハイフンが全dataset IDで変換されることを保証する。
  assert {
    condition = toset([
      google_bigquery_dataset.sakila.dataset_id,
      google_bigquery_dataset.dataform.dataset_id,
      google_bigquery_dataset.dataform_assertions.dataset_id,
      ]) == toset([
      "sakila_sample_a_dev_env",
      "dataform_sample_a_dev_env",
      "dataform_assertions_sample_a_dev_env",
    ])
    error_message = "Hyphens in dataset name components must be normalized to underscores."
  }
}
