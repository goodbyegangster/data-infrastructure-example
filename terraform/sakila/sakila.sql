-- クエリパラメータで指定されたprojectとdatasetを既定の書き込み先に設定する。
SET @@dataset_project_id = @project_id;
SET @@dataset_id = @dataset_id;

-- 出演者テーブルを作成。
CREATE OR REPLACE TABLE actor (
    actor_id INT64 OPTIONS (description = "出演者ID"),
    first_name STRING OPTIONS (description = "名"),
    last_name STRING OPTIONS (description = "姓"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (actor_id) NOT ENFORCED
)
OPTIONS (
    description = "出演者"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS actor_id,
        "PENELOPE" AS first_name,
        "GUINESS" AS last_name,
        DATETIME '2006-02-15 04:34:33' AS last_update
    ),
    (2, "NICK", "WAHLBERG", DATETIME '2006-02-15 04:34:33'),
    (3, "ED", "CHASE", DATETIME '2006-02-15 04:34:33'),
    (4, "JENNIFER", "DAVIS", DATETIME '2006-02-15 04:34:33'),
    (5, "JOHNNY", "LOLLOBRIGIDA", DATETIME '2006-02-15 04:34:33'),
    (6, "BETTE", "NICHOLSON", DATETIME '2006-02-15 04:34:33'),
    (7, "GRACE", "MOSTEL", DATETIME '2006-02-15 04:34:33'),
    (8, "MATTHEW", "JOHANSSON", DATETIME '2006-02-15 04:34:33'),
    (9, "JOE", "SWANK", DATETIME '2006-02-15 04:34:33'),
    (10, "CHRISTIAN", "GABLE", DATETIME '2006-02-15 04:34:33'),
    (11, "ZERO", "CAGE", DATETIME '2006-02-15 04:34:33'),
    (12, "KARL", "BERRY", DATETIME '2006-02-15 04:34:33'),
    (13, "UMA", "WOOD", DATETIME '2006-02-15 04:34:33'),
    (14, "VIVIEN", "BERGEN", DATETIME '2006-02-15 04:34:33'),
    (15, "CUBA", "OLIVIER", DATETIME '2006-02-15 04:34:33'),
    (16, "FRED", "COSTNER", DATETIME '2006-02-15 04:34:33'),
    (17, "HELEN", "VOIGHT", DATETIME '2006-02-15 04:34:33'),
    (18, "DAN", "TORN", DATETIME '2006-02-15 04:34:33'),
    (19, "BOB", "FAWCETT", DATETIME '2006-02-15 04:34:33'),
    (20, "LUCILLE", "TRACY", DATETIME '2006-02-15 04:34:33')
]);

-- カテゴリテーブルを作成。
CREATE OR REPLACE TABLE category (
    category_id INT64 OPTIONS (description = "カテゴリID"),
    name STRING OPTIONS (description = "カテゴリ名"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (category_id) NOT ENFORCED
)
OPTIONS (
    description = "カテゴリ"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS category_id,
        "Action" AS name,
        DATETIME '2006-02-15 04:46:27' AS last_update
    ),
    (2, "Animation", DATETIME '2006-02-15 04:46:27'),
    (3, "Children", DATETIME '2006-02-15 04:46:27'),
    (4, "Classics", DATETIME '2006-02-15 04:46:27'),
    (5, "Comedy", DATETIME '2006-02-15 04:46:27')
]);

-- 映画テーブルを作成。
CREATE OR REPLACE TABLE film (
    film_id INT64 OPTIONS (description = "映画ID"),
    title STRING OPTIONS (description = "タイトル"),
    description STRING OPTIONS (description = "説明"),
    release_year INT64 OPTIONS (description = "公開年"),
    language_id INT64 OPTIONS (description = "言語ID"),
    original_language_id INT64 OPTIONS (description = "オリジナル言語ID"),
    rental_duration INT64 OPTIONS (description = "レンタル期間（日数）"),
    rental_rate NUMERIC OPTIONS (description = "レンタル料金"),
    length INT64 OPTIONS (description = "上映時間（分）"),
    replacement_cost NUMERIC OPTIONS (description = "弁償金額"),
    rating STRING OPTIONS (description = "レーティング"),
    special_features STRING OPTIONS (description = "特典映像"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (film_id) NOT ENFORCED
)
OPTIONS (
    description = "映画"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS film_id, "ACADEMY DINOSAUR" AS title,
        "A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies"
            AS description,
        2006 AS release_year,
        1 AS language_id,
        CAST(NULL AS INT64) AS original_language_id,
        6 AS rental_duration, NUMERIC "0.99" AS rental_rate, 86 AS length,
        NUMERIC "20.99" AS replacement_cost, "PG" AS rating,
        "Deleted Scenes,Behind the Scenes" AS special_features,
        DATETIME '2006-02-15 05:03:42' AS last_update
    ),
    (
        2, "ACE GOLDFINGER",
        "A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China",
        2006, 1, NULL, 3, NUMERIC "4.99", 48, NUMERIC "12.99", "G",
        "Trailers,Deleted Scenes", DATETIME '2006-02-15 05:03:42'
    ),
    (
        3, "ADAPTATION HOLES",
        "A Astounding Reflection of a Lumberjack And a Car who must Sink a Lumberjack in A Baloon Factory",
        2006, 1, NULL, 7, NUMERIC "2.99", 50, NUMERIC "18.99", "NC-17",
        "Trailers,Deleted Scenes", DATETIME '2006-02-15 05:03:42'
    ),
    (
        4, "AFFAIR PREJUDICE",
        "A Fanciful Documentary of a Frisbee And a Lumberjack who must Chase a Monkey in A Shark Tank",
        2006, 1, NULL, 5, NUMERIC "2.99", 117, NUMERIC "26.99", "G",
        "Commentaries,Behind the Scenes", DATETIME '2006-02-15 05:03:42'
    ),
    (
        5, "AFRICAN EGG",
        "A Fast-Paced Documentary of a Pastry Chef And a Dentist who must Pursue a Forensic Psychologist in The Gulf of Mexico",
        2006, 1, NULL, 6, NUMERIC "2.99", 130, NUMERIC "22.99", "G",
        "Deleted Scenes", DATETIME '2006-02-15 05:03:42'
    ),
    (
        6, "AGENT TRUMAN",
        "A Intrepid Panorama of a Robot And a Boy who must Escape a Sumo Wrestler in Ancient China",
        2006, 1, NULL, 3, NUMERIC "2.99", 169, NUMERIC "17.99", "PG",
        "Deleted Scenes", DATETIME '2006-02-15 05:03:42'
    ),
    (
        7, "AIRPLANE SIERRA",
        "A Touching Saga of a Hunter And a Butler who must Discover a Butler in A Jet Boat",
        2006, 1, NULL, 6, NUMERIC "4.99", 62, NUMERIC "28.99", "PG-13",
        "Trailers,Deleted Scenes", DATETIME '2006-02-15 05:03:42'
    ),
    (
        8, "AIRPORT POLLOCK",
        "A Epic Tale of a Moose And a Girl who must Confront a Monkey in Ancient India",
        2006, 1, NULL, 6, NUMERIC "4.99", 54, NUMERIC "15.99", "R",
        "Trailers", DATETIME '2006-02-15 05:03:42'
    ),
    (
        9, "ALABAMA DEVIL",
        "A Thoughtful Panorama of a Database Administrator And a Mad Scientist who must Outgun a Mad Scientist",
        2006, 1, NULL, 3, NUMERIC "2.99", 114, NUMERIC "21.99", "PG-13",
        "Trailers,Deleted Scenes", DATETIME '2006-02-15 05:03:42'
    ),
    (
        10, "ALADDIN CALENDAR",
        "A Action-Packed Tale of a Man And a Lumberjack who must Reach a Feminist in Ancient China",
        2006, 1, NULL, 6, NUMERIC "4.99", 63, NUMERIC "24.99", "NC-17",
        "Trailers,Deleted Scenes", DATETIME '2006-02-15 05:03:42'
    )
]);

-- 映画出演者テーブルを作成。
CREATE OR REPLACE TABLE film_actor (
    actor_id INT64 OPTIONS (description = "出演者ID"),
    film_id INT64 OPTIONS (description = "映画ID"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (actor_id, film_id) NOT ENFORCED,
    CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id)
        REFERENCES actor (actor_id)
        NOT ENFORCED,
    CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id)
        REFERENCES film (film_id)
        NOT ENFORCED
)
OPTIONS (
    description = "映画出演者"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS actor_id,
        1 AS film_id,
        DATETIME '2006-02-15 05:05:03' AS last_update
    ),
    (10, 1, DATETIME '2006-02-15 05:05:03'),
    (2, 2, DATETIME '2006-02-15 05:05:03'),
    (7, 2, DATETIME '2006-02-15 05:05:03'),
    (3, 3, DATETIME '2006-02-15 05:05:03'),
    (12, 3, DATETIME '2006-02-15 05:05:03'),
    (4, 4, DATETIME '2006-02-15 05:05:03'),
    (13, 4, DATETIME '2006-02-15 05:05:03'),
    (5, 5, DATETIME '2006-02-15 05:05:03'),
    (14, 5, DATETIME '2006-02-15 05:05:03'),
    (6, 6, DATETIME '2006-02-15 05:05:03'),
    (15, 6, DATETIME '2006-02-15 05:05:03'),
    (7, 7, DATETIME '2006-02-15 05:05:03'),
    (16, 7, DATETIME '2006-02-15 05:05:03'),
    (8, 8, DATETIME '2006-02-15 05:05:03'),
    (17, 8, DATETIME '2006-02-15 05:05:03'),
    (9, 9, DATETIME '2006-02-15 05:05:03'),
    (18, 9, DATETIME '2006-02-15 05:05:03'),
    (10, 10, DATETIME '2006-02-15 05:05:03'),
    (20, 10, DATETIME '2006-02-15 05:05:03')
]);

-- 映画カテゴリテーブルを作成。
CREATE OR REPLACE TABLE film_category (
    film_id INT64 OPTIONS (description = "映画ID"),
    category_id INT64 OPTIONS (description = "カテゴリID"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (film_id, category_id) NOT ENFORCED,
    CONSTRAINT fk_film_category_film FOREIGN KEY (film_id)
        REFERENCES film (film_id)
        NOT ENFORCED,
    CONSTRAINT fk_film_category_category FOREIGN KEY (category_id)
        REFERENCES category (category_id)
        NOT ENFORCED
)
OPTIONS (
    description = "映画カテゴリ"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS film_id,
        1 AS category_id,
        DATETIME '2006-02-15 05:07:09' AS last_update
    ),
    (2, 2, DATETIME '2006-02-15 05:07:09'),
    (3, 3, DATETIME '2006-02-15 05:07:09'),
    (4, 4, DATETIME '2006-02-15 05:07:09'),
    (5, 5, DATETIME '2006-02-15 05:07:09'),
    (6, 1, DATETIME '2006-02-15 05:07:09'),
    (7, 2, DATETIME '2006-02-15 05:07:09'),
    (8, 3, DATETIME '2006-02-15 05:07:09'),
    (9, 4, DATETIME '2006-02-15 05:07:09'),
    (10, 5, DATETIME '2006-02-15 05:07:09')
]);

-- 顧客テーブルを作成。
CREATE OR REPLACE TABLE customer (
    customer_id INT64 OPTIONS (description = "顧客ID"),
    store_id INT64 OPTIONS (description = "店舗ID"),
    first_name STRING OPTIONS (description = "名"),
    last_name STRING OPTIONS (description = "姓"),
    email STRING OPTIONS (description = "メールアドレス"),
    address_id INT64 OPTIONS (description = "住所ID"),
    active BOOL OPTIONS (description = "有効状態"),
    create_date DATE OPTIONS (description = "登録日"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (customer_id) NOT ENFORCED
)
OPTIONS (
    description = "顧客"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS customer_id,
        1 AS store_id,
        "MARY" AS first_name,
        "SMITH" AS last_name,
        "MARY.SMITH@example.org" AS email, 5 AS address_id, TRUE AS active,
        DATE '2006-02-14' AS create_date,
        DATETIME '2006-02-15 04:57:20' AS last_update
    ),
    (
        2,
        1,
        "PATRICIA",
        "JOHNSON",
        "PATRICIA.JOHNSON@example.org",
        6,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    ),
    (
        3,
        1,
        "LINDA",
        "WILLIAMS",
        "LINDA.WILLIAMS@example.org",
        7,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    ),
    (
        4,
        2,
        "BARBARA",
        "JONES",
        "BARBARA.JONES@example.org",
        8,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    ),
    (
        5,
        1,
        "ELIZABETH",
        "BROWN",
        "ELIZABETH.BROWN@example.org",
        9,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    ),
    (
        6,
        2,
        "JENNIFER",
        "DAVIS",
        "JENNIFER.DAVIS@example.org",
        10,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    ),
    (
        7,
        1,
        "MARIA",
        "MILLER",
        "MARIA.MILLER@example.org",
        11,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    ),
    (
        8,
        2,
        "SUSAN",
        "WILSON",
        "SUSAN.WILSON@example.org",
        12,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    ),
    (
        9,
        1,
        "MARGARET",
        "MOORE",
        "MARGARET.MOORE@example.org",
        13,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    ),
    (
        10,
        2,
        "DOROTHY",
        "TAYLOR",
        "DOROTHY.TAYLOR@example.org",
        14,
        TRUE,
        DATE '2006-02-14',
        DATETIME '2006-02-15 04:57:20'
    )
]);

-- 在庫テーブルを作成。
CREATE OR REPLACE TABLE inventory (
    inventory_id INT64 OPTIONS (description = "在庫ID"),
    film_id INT64 OPTIONS (description = "映画ID"),
    store_id INT64 OPTIONS (description = "店舗ID"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (inventory_id) NOT ENFORCED,
    CONSTRAINT fk_inventory_film FOREIGN KEY (film_id)
        REFERENCES film (film_id)
        NOT ENFORCED
)
OPTIONS (
    description = "在庫"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS inventory_id,
        1 AS film_id,
        1 AS store_id,
        DATETIME '2006-02-15 05:09:17' AS last_update
    ),
    (2, 1, 2, DATETIME '2006-02-15 05:09:17'),
    (3, 2, 1, DATETIME '2006-02-15 05:09:17'),
    (4, 3, 1, DATETIME '2006-02-15 05:09:17'),
    (5, 4, 2, DATETIME '2006-02-15 05:09:17'),
    (6, 5, 1, DATETIME '2006-02-15 05:09:17'),
    (7, 6, 2, DATETIME '2006-02-15 05:09:17'),
    (8, 7, 1, DATETIME '2006-02-15 05:09:17'),
    (9, 8, 2, DATETIME '2006-02-15 05:09:17'),
    (10, 9, 1, DATETIME '2006-02-15 05:09:17'),
    (11, 10, 2, DATETIME '2006-02-15 05:09:17'),
    (12, 2, 2, DATETIME '2006-02-15 05:09:17')
]);

-- レンタルテーブルを作成。
CREATE OR REPLACE TABLE rental (
    rental_id INT64 OPTIONS (description = "レンタルID"),
    rental_date DATETIME OPTIONS (description = "レンタル日時"),
    inventory_id INT64 OPTIONS (description = "在庫ID"),
    customer_id INT64 OPTIONS (description = "顧客ID"),
    return_date DATETIME OPTIONS (description = "返却日時"),
    staff_id INT64 OPTIONS (description = "スタッフID"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (rental_id) NOT ENFORCED,
    CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id)
        REFERENCES inventory (inventory_id)
        NOT ENFORCED,
    CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        NOT ENFORCED
)
OPTIONS (
    description = "レンタル"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS rental_id,
        DATETIME '2005-05-24 22:53:30' AS rental_date,
        1 AS inventory_id,
        1 AS customer_id,
        DATETIME '2005-05-26 22:04:30' AS return_date,
        1 AS staff_id,
        DATETIME '2006-02-15 21:30:53' AS last_update
    ),
    (
        2,
        DATETIME '2005-05-25 00:04:30',
        3,
        2,
        DATETIME '2005-05-28 00:10:30',
        1,
        DATETIME '2006-02-15 21:30:53'
    ),
    (
        3,
        DATETIME '2005-05-25 00:17:30',
        4,
        3,
        DATETIME '2005-05-29 21:35:30',
        2,
        DATETIME '2006-02-15 21:30:53'
    ),
    (
        4,
        DATETIME '2005-05-25 00:43:30',
        5,
        4,
        DATETIME '2005-05-27 10:12:30',
        1,
        DATETIME '2006-02-15 21:30:53'
    ),
    (
        5,
        DATETIME '2005-05-25 01:06:30',
        6,
        5,
        DATETIME '2005-05-28 14:32:30',
        2,
        DATETIME '2006-02-15 21:30:53'
    ),
    (
        6,
        DATETIME '2005-05-25 01:10:30',
        7,
        6,
        DATETIME '2005-05-30 09:44:30',
        1,
        DATETIME '2006-02-15 21:30:53'
    ),
    (
        7,
        DATETIME '2005-05-25 01:17:30',
        8,
        7,
        DATETIME '2005-05-28 16:40:30',
        2,
        DATETIME '2006-02-15 21:30:53'
    ),
    (
        8,
        DATETIME '2005-05-25 01:48:30',
        9,
        8,
        DATETIME '2005-05-27 17:20:30',
        1,
        DATETIME '2006-02-15 21:30:53'
    ),
    (
        9,
        DATETIME '2005-05-25 02:21:30',
        10,
        9,
        DATETIME '2005-05-31 08:12:30',
        2,
        DATETIME '2006-02-15 21:30:53'
    ),
    (
        10,
        DATETIME '2005-05-25 02:53:30',
        11,
        10,
        CAST(NULL AS DATETIME),
        1,
        DATETIME '2006-02-15 21:30:53'
    )
]);

-- 支払いテーブルを作成。
CREATE OR REPLACE TABLE payment (
    payment_id INT64 OPTIONS (description = "支払いID"),
    customer_id INT64 OPTIONS (description = "顧客ID"),
    staff_id INT64 OPTIONS (description = "スタッフID"),
    rental_id INT64 OPTIONS (description = "レンタルID"),
    amount NUMERIC OPTIONS (description = "支払金額"),
    payment_date DATETIME OPTIONS (description = "支払日時"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (payment_id) NOT ENFORCED,
    CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        NOT ENFORCED,
    CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id)
        REFERENCES rental (rental_id)
        NOT ENFORCED
)
OPTIONS (
    description = "支払い"
)
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS payment_id,
        1 AS customer_id,
        1 AS staff_id,
        1 AS rental_id,
        NUMERIC "2.99" AS amount,
        DATETIME '2005-05-24 23:10:00' AS payment_date,
        DATETIME '2006-02-15 22:12:30' AS last_update
    ),
    (
        2,
        2,
        1,
        2,
        NUMERIC "4.99",
        DATETIME '2005-05-25 00:20:00',
        DATETIME '2006-02-15 22:12:30'
    ),
    (
        3,
        3,
        2,
        3,
        NUMERIC "2.99",
        DATETIME '2005-05-25 00:30:00',
        DATETIME '2006-02-15 22:12:30'
    ),
    (
        4,
        4,
        1,
        4,
        NUMERIC "3.99",
        DATETIME '2005-05-25 00:55:00',
        DATETIME '2006-02-15 22:12:30'
    ),
    (
        5,
        5,
        2,
        5,
        NUMERIC "1.99",
        DATETIME '2005-05-25 01:20:00',
        DATETIME '2006-02-15 22:12:30'
    ),
    (
        6,
        6,
        1,
        6,
        NUMERIC "5.99",
        DATETIME '2005-05-25 01:30:00',
        DATETIME '2006-02-15 22:12:30'
    ),
    (
        7,
        7,
        2,
        7,
        NUMERIC "2.99",
        DATETIME '2005-05-25 01:40:00',
        DATETIME '2006-02-15 22:12:30'
    ),
    (
        8,
        8,
        1,
        8,
        NUMERIC "4.99",
        DATETIME '2005-05-25 02:00:00',
        DATETIME '2006-02-15 22:12:30'
    ),
    (
        9,
        9,
        2,
        9,
        NUMERIC "6.99",
        DATETIME '2005-05-25 02:40:00',
        DATETIME '2006-02-15 22:12:30'
    ),
    (
        10,
        10,
        1,
        10,
        NUMERIC "4.99",
        DATETIME '2005-05-25 03:10:00',
        DATETIME '2006-02-15 22:12:30'
    )
]);

-- film_actor が参照する actor_id / film_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM film_actor AS fa
    LEFT JOIN actor AS a ON fa.actor_id = a.actor_id
    LEFT JOIN film AS f ON fa.film_id = f.film_id
    WHERE a.actor_id IS NULL OR f.film_id IS NULL
) AS "film_actor contains an orphan key"
;

-- film_category が参照する film_id / category_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM film_category AS fc
    LEFT JOIN film AS f ON fc.film_id = f.film_id
    LEFT JOIN category AS c ON fc.category_id = c.category_id
    WHERE f.film_id IS NULL OR c.category_id IS NULL
) AS "film_category contains an orphan key"
;

-- inventory が参照する film_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM inventory AS i
    LEFT JOIN film AS f ON i.film_id = f.film_id
    WHERE f.film_id IS NULL
) AS "inventory contains an orphan film_id"
;

-- rental が参照する inventory_id / customer_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM rental AS r
    LEFT JOIN inventory AS i ON r.inventory_id = i.inventory_id
    LEFT JOIN customer AS c ON r.customer_id = c.customer_id
    WHERE i.inventory_id IS NULL OR c.customer_id IS NULL
) AS "rental contains an orphan key"
;

-- payment が参照する customer_id / rental_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM payment AS p
    LEFT JOIN customer AS c ON p.customer_id = c.customer_id
    LEFT JOIN rental AS r ON p.rental_id = r.rental_id
    WHERE c.customer_id IS NULL OR r.rental_id IS NULL
) AS "payment contains an orphan key"
;

-- PRIMARY KEYとして宣言した列にNULLまたは重複がないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM (
        SELECT 1 AS invalid_key
        FROM actor
        GROUP BY actor_id
        HAVING actor_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1
        FROM category
        GROUP BY category_id
        HAVING category_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1
        FROM film
        GROUP BY film_id
        HAVING film_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1
        FROM film_actor
        GROUP BY actor_id, film_id
        HAVING actor_id IS NULL OR film_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1
        FROM film_category
        GROUP BY film_id, category_id
        HAVING film_id IS NULL OR category_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1
        FROM customer
        GROUP BY customer_id
        HAVING customer_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1
        FROM inventory
        GROUP BY inventory_id
        HAVING inventory_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1
        FROM rental
        GROUP BY rental_id
        HAVING rental_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1
        FROM payment
        GROUP BY payment_id
        HAVING payment_id IS NULL OR COUNT(*) > 1
    )
) AS "a primary key contains NULL or duplicate values"
;
