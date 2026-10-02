# sakila

Dataform の検証に使う Sakila の主要エンティティを BigQuery へ投入する。

投入先は Terraform が作成する `sakila_<suffix>_<environment>` データセットとなる。
同名の既存テーブルは検証用データで置き換える。

## Requirements

- Terraform による Sakila データセットの作成が完了していること
- `terraform`、`gcloud`、`bq` を利用できること
- Google Cloud CLI と Application Default Credentials で認証していること

## Usage

```bash
make sakila-load
```

既定では `config/dev.env.local` を使用する。別の設定を使う場合は、
`make sakila-load ENV_FILE=config/another.env.local` のように指定する。

## ER 図

```mermaid
erDiagram
    actor ||--o{ film_actor : "actor_id"
    film ||--o{ film_actor : "film_id"
    film ||--o{ film_category : "film_id"
    category ||--o{ film_category : "category_id"
    film ||--o{ inventory : "film_id"
    inventory ||--o{ rental : "inventory_id"
    customer ||--o{ rental : "customer_id"
    customer ||--o{ payment : "customer_id"
    rental ||--o{ payment : "rental_id"

    actor {
        INT64 actor_id PK "出演者ID"
        STRING first_name "名"
        STRING last_name "姓"
        DATETIME last_update "最終更新日時"
    }

    category {
        INT64 category_id PK "カテゴリID"
        STRING name "カテゴリ名"
        DATETIME last_update "最終更新日時"
    }

    film {
        INT64 film_id PK "映画ID"
        STRING title "タイトル"
        STRING description "説明"
        INT64 release_year "公開年"
        INT64 language_id "言語ID"
        INT64 original_language_id "オリジナル言語ID"
        INT64 rental_duration "レンタル期間（日数）"
        NUMERIC rental_rate "レンタル料金"
        INT64 length "上映時間（分）"
        NUMERIC replacement_cost "弁償金額"
        STRING rating "レーティング"
        STRING special_features "特典映像"
        DATETIME last_update "最終更新日時"
    }

    film_actor {
        INT64 actor_id PK,FK "出演者ID"
        INT64 film_id PK,FK "映画ID"
        DATETIME last_update "最終更新日時"
    }

    film_category {
        INT64 film_id PK,FK "映画ID"
        INT64 category_id PK,FK "カテゴリID"
        DATETIME last_update "最終更新日時"
    }

    customer {
        INT64 customer_id PK "顧客ID"
        INT64 store_id "店舗ID"
        STRING first_name "名"
        STRING last_name "姓"
        STRING email "メールアドレス"
        INT64 address_id "住所ID"
        BOOL active "有効状態"
        DATE create_date "登録日"
        DATETIME last_update "最終更新日時"
    }

    inventory {
        INT64 inventory_id PK "在庫ID"
        INT64 film_id FK "映画ID"
        INT64 store_id "店舗ID"
        DATETIME last_update "最終更新日時"
    }

    rental {
        INT64 rental_id PK "レンタルID"
        DATETIME rental_date "レンタル日時"
        INT64 inventory_id FK "在庫ID"
        INT64 customer_id FK "顧客ID"
        DATETIME return_date "返却日時"
        INT64 staff_id "スタッフID"
        DATETIME last_update "最終更新日時"
    }

    payment {
        INT64 payment_id PK "支払いID"
        INT64 customer_id FK "顧客ID"
        INT64 staff_id "スタッフID"
        INT64 rental_id FK "レンタルID"
        NUMERIC amount "支払金額"
        DATETIME payment_date "支払日時"
        DATETIME last_update "最終更新日時"
    }
```

## References

- [sakila](https://github.com/ivanceras/sakila)
