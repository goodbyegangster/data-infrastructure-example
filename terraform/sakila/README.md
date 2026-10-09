# sakila

## ER 図

```mermaid
erDiagram
    country ||--o{ city : "country_id"
    city ||--o{ address : "city_id"
    address ||--o{ store : "address_id"
    address ||--o{ staff : "address_id"
    address ||--o{ customer : "address_id"
    store ||--o{ staff : "store_id"
    staff ||--o| store : "manager_staff_id"
    store ||--o{ customer : "store_id"
    store ||--o{ inventory : "store_id"
    language ||--o{ film : "language_id"
    language |o--o{ film : "original_language_id"
    film ||--|| film_text : "ロード時に同期"
    actor ||--o{ film_actor : "actor_id"
    film ||--o{ film_actor : "film_id"
    film ||--o{ film_category : "film_id"
    category ||--o{ film_category : "category_id"
    film ||--o{ inventory : "film_id"
    inventory ||--o{ rental : "inventory_id"
    customer ||--o{ rental : "customer_id"
    staff ||--o{ rental : "staff_id"
    customer ||--o{ payment : "customer_id"
    staff ||--o{ payment : "staff_id"
    rental |o--o{ payment : "rental_id"
```

## References

- [Sakila の公式テーブル一覧](https://dev.mysql.com/doc/sakila/en/sakila-structure-tables.html)
- [参照元の MySQL スキーマ](https://github.com/ivanceras/sakila/blob/master/mysql-sakila-db/sakila-schema.sql)
- [参照元の著作権表示と利用条件](LICENSE.sakila)
