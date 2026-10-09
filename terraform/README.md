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

#### (2) mart_red プロジェクト向けの実行

```sh
make terraform-mart-red-init
make terraform-mart-red-plan
make terraform-mart-red-apply
```

#### (3) raw_data プロジェクト向けの実行

```sh
make terraform-raw-data-init
make terraform-raw-data-plan
make terraform-raw-data-apply
```

### 9. cleanup

#### (1) terraform destroy

```sh
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
