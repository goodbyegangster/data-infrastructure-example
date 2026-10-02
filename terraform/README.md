# terraform

## bootstrap

Terraform 実行のための準備。

- Google Cloud API の有効化
- Terraform remote state 向けの GCS Bucket 作成

### (1) `config/dev.env` 作成

[config/dev.env.example](config/dev.env.example) を参考に `config/dev.env` を作成。

### (2) dry run

```sh
make bootstrap-dry-run
```

### (3) run

```sh
make bootstrap-run
```

## cleanup

### (X) Terraform remote state 向け GCS Bucket 削除

```sh
make bootstrap-destroy-dry-run
```

```sh
make bootstrap-destroy-run
```
