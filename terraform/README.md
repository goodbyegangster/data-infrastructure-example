# terraform

## `config/dev.env` 作成

[config/dev.env.example](config/dev.env.example) を参考に `config/dev.env` を作成。

## bootstrap

作成した env ファイルを基に、Terraform 実行の準備を行う。

- Google Cloud API の有効化
- Terraform remote state 向けの GCS Bucket 作成

### (1) dry run

```sh
make bootstrap-dry-run
```

### (2) run

```sh
make bootstrap-run
```

## Terraform

hogehoge。

### (1)

作成した env ファイルを基に、Terraform backend と tfvars ファイルを作成する。

```sh
make terraform-configure
```

## cleanup

### (X) Terraform remote state 向け GCS Bucket 削除

```sh
make bootstrap-destroy-dry-run
```

```sh
make bootstrap-destroy-run
```
