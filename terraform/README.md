# terraform

## 利用方法

### 1. `config/dev.env` 作成

[config/dev.env.example](config/dev.env.example) を参考に `config/dev.env` を作成。

### 2. bootstrap

作成した env ファイルを基に、Terraform 実行の準備を行う。

- Google Cloud API の有効化
- Terraform remote state 向けの GCS Bucket 作成

#### (1) dry run

```sh
make bootstrap-dry-run
```

#### (2) run

```sh
make bootstrap-run
```

### 3. Terraform

Terraform の実行。

#### (1) 設定ファイルを作成

作成した env ファイルを基に、Terraform backend と tfvars ファイルを作成する。

```sh
make terraform-configure
```

#### (2) raw_data プロジェクト向けの実行

```sh
make terraform-raw-data-init
make terraform-raw-data-plan
make terraform-raw-data-apply
```

#### (3) mart_red プロジェクト向けの実行

```sh
make terraform-mart-red-init
make terraform-mart-red-plan
make terraform-mart-red-apply
```

#### (4) mart_blue プロジェクト向けの実行

```sh
make terraform-mart-blue-init
make terraform-mart-blue-plan
make terraform-mart-blue-apply
```

#### (5) raw_data プロジェクト向けに再実行

各 mart で作成された dataform サービスアカウントを、staging データセットの参照権限に追加する。

```sh
make terraform-raw-data-plan
make terraform-raw-data-apply
```

### 9. cleanup

#### (1) terraform destroy

空文字の指定で raw_data を適用し、Mart runtime の読み取り権限を外す。
その後、各 Mart と raw_data を削除する。
Dataset 内のテーブルと Dataform Repository も削除される。

```sh
make terraform-mart-blue-destroy
make terraform-mart-red-destroy
make terraform-raw-data-destroy
```

#### (2) Terraform remote state 向け GCS Bucket 削除

```sh
make bootstrap-destroy-dry-run
```

```sh
make bootstrap-destroy-run
```
