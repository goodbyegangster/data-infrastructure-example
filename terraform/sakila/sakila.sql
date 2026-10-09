-- クエリパラメータで指定されたprojectとdatasetを既定の書き込み先に設定する。
SET @@dataset_project_id = @project_id;
SET @@dataset_id = @dataset_id;

-- 国テーブルを作成。
CREATE OR REPLACE TABLE country (
    country_id INT64 OPTIONS (description = "国ID"),
    country STRING OPTIONS (description = "国名"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (country_id) NOT ENFORCED
)
OPTIONS (description = "国")
AS
SELECT * FROM UNNEST([
    STRUCT(1 AS country_id, "Japan" AS country, DATETIME '2006-02-15 04:44:00' AS last_update),
    (2, "Canada", DATETIME '2006-02-15 04:44:00'),
    (3, "Australia", DATETIME '2006-02-15 04:44:00')
]);

-- 都市テーブルを作成。
CREATE OR REPLACE TABLE city (
    city_id INT64 OPTIONS (description = "都市ID"),
    city STRING OPTIONS (description = "都市名"),
    country_id INT64 OPTIONS (description = "国ID"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (city_id) NOT ENFORCED
)
OPTIONS (description = "都市")
AS
SELECT * FROM UNNEST([
    STRUCT(1 AS city_id, "Tokyo" AS city, 1 AS country_id, DATETIME '2006-02-15 04:45:25' AS last_update),
    (2, "Vancouver", 2, DATETIME '2006-02-15 04:45:25'),
    (3, "Brisbane", 3, DATETIME '2006-02-15 04:45:25')
]);

-- 顧客・スタッフ・店舗から参照する住所テーブルを作成。
CREATE OR REPLACE TABLE address (
    address_id INT64 OPTIONS (description = "住所ID"),
    address STRING OPTIONS (description = "住所"),
    address2 STRING OPTIONS (description = "住所の補足"),
    district STRING OPTIONS (description = "地域"),
    city_id INT64 OPTIONS (description = "都市ID"),
    postal_code STRING OPTIONS (description = "郵便番号"),
    phone STRING OPTIONS (description = "電話番号"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (address_id) NOT ENFORCED
)
OPTIONS (description = "住所")
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS address_id, "1 Sample Street" AS address, CAST(NULL AS STRING) AS address2,
        "British Columbia" AS district, 2 AS city_id, "V6B 1A1" AS postal_code,
        "16045550101" AS phone, DATETIME '2006-02-15 04:45:30' AS last_update
    ),
    (2, "2 Sample Street", NULL, "Queensland", 3, "4000", "61755550102", DATETIME '2006-02-15 04:45:30'),
    (3, "3 Sample Street", NULL, "British Columbia", 2, "V6B 1A2", "16045550103", DATETIME '2006-02-15 04:45:30'),
    (4, "4 Sample Street", NULL, "Queensland", 3, "4001", "61755550104", DATETIME '2006-02-15 04:45:30'),
    (5, "5 Sample Street", NULL, "Tokyo", 1, "1000001", "81355550105", DATETIME '2006-02-15 04:45:30'),
    (6, "6 Sample Street", NULL, "Tokyo", 1, "1000002", "81355550106", DATETIME '2006-02-15 04:45:30'),
    (7, "7 Sample Street", NULL, "Tokyo", 1, "1000003", "81355550107", DATETIME '2006-02-15 04:45:30'),
    (8, "8 Sample Street", NULL, "Queensland", 3, "4002", "61755550108", DATETIME '2006-02-15 04:45:30'),
    (9, "9 Sample Street", NULL, "Tokyo", 1, "1000004", "81355550109", DATETIME '2006-02-15 04:45:30'),
    (10, "10 Sample Street", NULL, "Queensland", 3, "4003", "61755550110", DATETIME '2006-02-15 04:45:30'),
    (11, "11 Sample Street", NULL, "Tokyo", 1, "1000005", "81355550111", DATETIME '2006-02-15 04:45:30'),
    (12, "12 Sample Street", NULL, "Queensland", 3, "4004", "61755550112", DATETIME '2006-02-15 04:45:30'),
    (13, "13 Sample Street", NULL, "Tokyo", 1, "1000006", "81355550113", DATETIME '2006-02-15 04:45:30'),
    (14, "14 Sample Street", NULL, "Queensland", 3, "4005", "61755550114", DATETIME '2006-02-15 04:45:30')
]);

-- 映画の言語テーブルを作成。
CREATE OR REPLACE TABLE language (
    language_id INT64 OPTIONS (description = "言語ID"),
    name STRING OPTIONS (description = "言語名"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (language_id) NOT ENFORCED
)
OPTIONS (description = "言語")
AS
SELECT * FROM UNNEST([
    STRUCT(1 AS language_id, "English" AS name, DATETIME '2006-02-15 05:02:19' AS last_update),
    (2, "Italian", DATETIME '2006-02-15 05:02:19'),
    (3, "Japanese", DATETIME '2006-02-15 05:02:19'),
    (4, "Mandarin", DATETIME '2006-02-15 05:02:19'),
    (5, "French", DATETIME '2006-02-15 05:02:19'),
    (6, "German", DATETIME '2006-02-15 05:02:19')
]);

-- 店舗テーブルを作成。staff との循環参照は全テーブル作成後に設定する。
CREATE OR REPLACE TABLE store (
    store_id INT64 OPTIONS (description = "店舗ID"),
    manager_staff_id INT64 OPTIONS (description = "店長のスタッフID"),
    address_id INT64 OPTIONS (description = "住所ID"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (store_id) NOT ENFORCED
)
OPTIONS (description = "店舗")
AS
SELECT * FROM UNNEST([
    STRUCT(1 AS store_id, 1 AS manager_staff_id, 1 AS address_id, DATETIME '2006-02-15 04:57:12' AS last_update),
    (2, 2, 2, DATETIME '2006-02-15 04:57:12')
]);

-- スタッフテーブルを作成。
CREATE OR REPLACE TABLE staff (
    staff_id INT64 OPTIONS (description = "スタッフID"),
    first_name STRING OPTIONS (description = "名"),
    last_name STRING OPTIONS (description = "姓"),
    address_id INT64 OPTIONS (description = "住所ID"),
    picture BYTES OPTIONS (description = "写真"),
    email STRING OPTIONS (description = "メールアドレス"),
    store_id INT64 OPTIONS (description = "所属店舗ID"),
    active BOOL OPTIONS (description = "有効状態"),
    username STRING OPTIONS (description = "ユーザー名"),
    password STRING OPTIONS (description = "パスワードハッシュ"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (staff_id) NOT ENFORCED
)
OPTIONS (description = "スタッフ")
AS
SELECT * FROM UNNEST([
    STRUCT(
        1 AS staff_id, "Mike" AS first_name, "Hillyer" AS last_name, 3 AS address_id,
        CAST(NULL AS BYTES) AS picture, "mike@example.org" AS email, 1 AS store_id,
        TRUE AS active, "Mike" AS username, CAST(NULL AS STRING) AS password,
        DATETIME '2006-02-15 04:57:16' AS last_update
    ),
    (2, "Jon", "Stephens", 4, NULL, "jon@example.org", 2, TRUE, "Jon", NULL, DATETIME '2006-02-15 04:57:16')
]);

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

-- 映画から全文検索用テーブルを再作成し、ロード時点の内容を同期する。
CREATE OR REPLACE TABLE film_text (
    film_id INT64 OPTIONS (description = "映画ID"),
    title STRING OPTIONS (description = "タイトル"),
    description STRING OPTIONS (description = "説明"),
    PRIMARY KEY (film_id) NOT ENFORCED
)
OPTIONS (description = "映画のタイトルと説明")
AS
SELECT film_id, title, description FROM film;

-- 映画出演者テーブルを作成。
CREATE OR REPLACE TABLE film_actor (
    actor_id INT64 OPTIONS (description = "出演者ID"),
    film_id INT64 OPTIONS (description = "映画ID"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (actor_id, film_id) NOT ENFORCED
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
    PRIMARY KEY (film_id, category_id) NOT ENFORCED
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
    create_date DATETIME OPTIONS (description = "登録日"),
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
        DATETIME '2006-02-14 00:00:00' AS create_date,
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
        DATETIME '2006-02-14 00:00:00',
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
        DATETIME '2006-02-14 00:00:00',
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
        DATETIME '2006-02-14 00:00:00',
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
        DATETIME '2006-02-14 00:00:00',
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
        DATETIME '2006-02-14 00:00:00',
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
        DATETIME '2006-02-14 00:00:00',
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
        DATETIME '2006-02-14 00:00:00',
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
        DATETIME '2006-02-14 00:00:00',
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
        DATETIME '2006-02-14 00:00:00',
        DATETIME '2006-02-15 04:57:20'
    )
]);

-- 在庫テーブルを作成。
CREATE OR REPLACE TABLE inventory (
    inventory_id INT64 OPTIONS (description = "在庫ID"),
    film_id INT64 OPTIONS (description = "映画ID"),
    store_id INT64 OPTIONS (description = "店舗ID"),
    last_update DATETIME OPTIONS (description = "最終更新日時"),
    PRIMARY KEY (inventory_id) NOT ENFORCED
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
    PRIMARY KEY (rental_id) NOT ENFORCED
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
    PRIMARY KEY (payment_id) NOT ENFORCED
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

-- 循環参照を含め、全テーブルが存在する状態で外部キーを設定する。
ALTER TABLE city
ADD CONSTRAINT fk_city_country_id FOREIGN KEY (country_id)
    REFERENCES country (country_id) NOT ENFORCED;

ALTER TABLE address
ADD CONSTRAINT fk_address_city_id FOREIGN KEY (city_id)
    REFERENCES city (city_id) NOT ENFORCED;

ALTER TABLE staff
ADD CONSTRAINT fk_staff_address_id FOREIGN KEY (address_id)
    REFERENCES address (address_id) NOT ENFORCED;

ALTER TABLE staff
ADD CONSTRAINT fk_staff_store_id FOREIGN KEY (store_id)
    REFERENCES store (store_id) NOT ENFORCED;

ALTER TABLE store
ADD CONSTRAINT fk_store_address_id FOREIGN KEY (address_id)
    REFERENCES address (address_id) NOT ENFORCED;

ALTER TABLE store
ADD CONSTRAINT fk_store_manager_staff_id FOREIGN KEY (manager_staff_id)
    REFERENCES staff (staff_id) NOT ENFORCED;

ALTER TABLE customer
ADD CONSTRAINT fk_customer_address_id FOREIGN KEY (address_id)
    REFERENCES address (address_id) NOT ENFORCED;

ALTER TABLE customer
ADD CONSTRAINT fk_customer_store_id FOREIGN KEY (store_id)
    REFERENCES store (store_id) NOT ENFORCED;

ALTER TABLE film
ADD CONSTRAINT fk_film_language_id FOREIGN KEY (language_id)
    REFERENCES language (language_id) NOT ENFORCED;

ALTER TABLE film
ADD CONSTRAINT fk_film_original_language_id FOREIGN KEY (original_language_id)
    REFERENCES language (language_id) NOT ENFORCED;

ALTER TABLE film_actor
ADD CONSTRAINT fk_film_actor_actor_id FOREIGN KEY (actor_id)
    REFERENCES actor (actor_id) NOT ENFORCED;

ALTER TABLE film_actor
ADD CONSTRAINT fk_film_actor_film_id FOREIGN KEY (film_id)
    REFERENCES film (film_id) NOT ENFORCED;

ALTER TABLE film_category
ADD CONSTRAINT fk_film_category_film_id FOREIGN KEY (film_id)
    REFERENCES film (film_id) NOT ENFORCED;

ALTER TABLE film_category
ADD CONSTRAINT fk_film_category_category_id FOREIGN KEY (category_id)
    REFERENCES category (category_id) NOT ENFORCED;

ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_film_id FOREIGN KEY (film_id)
    REFERENCES film (film_id) NOT ENFORCED;

ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_store_id FOREIGN KEY (store_id)
    REFERENCES store (store_id) NOT ENFORCED;

ALTER TABLE rental
ADD CONSTRAINT fk_rental_inventory_id FOREIGN KEY (inventory_id)
    REFERENCES inventory (inventory_id) NOT ENFORCED;

ALTER TABLE rental
ADD CONSTRAINT fk_rental_customer_id FOREIGN KEY (customer_id)
    REFERENCES customer (customer_id) NOT ENFORCED;

ALTER TABLE rental
ADD CONSTRAINT fk_rental_staff_id FOREIGN KEY (staff_id)
    REFERENCES staff (staff_id) NOT ENFORCED;

ALTER TABLE payment
ADD CONSTRAINT fk_payment_customer_id FOREIGN KEY (customer_id)
    REFERENCES customer (customer_id) NOT ENFORCED;

ALTER TABLE payment
ADD CONSTRAINT fk_payment_rental_id FOREIGN KEY (rental_id)
    REFERENCES rental (rental_id) NOT ENFORCED;

ALTER TABLE payment
ADD CONSTRAINT fk_payment_staff_id FOREIGN KEY (staff_id)
    REFERENCES staff (staff_id) NOT ENFORCED;

-- BigQuery の外部キーは強制されないため、全参照先の存在を検証する。
-- city.country_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM city AS child
    LEFT JOIN country AS parent ON child.country_id = parent.country_id
    WHERE child.country_id IS NOT NULL AND parent.country_id IS NULL
) AS "city contains an orphan country_id";

-- address.city_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM address AS child
    LEFT JOIN city AS parent ON child.city_id = parent.city_id
    WHERE child.city_id IS NOT NULL AND parent.city_id IS NULL
) AS "address contains an orphan city_id";

-- staff.address_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM staff AS child
    LEFT JOIN address AS parent ON child.address_id = parent.address_id
    WHERE child.address_id IS NOT NULL AND parent.address_id IS NULL
) AS "staff contains an orphan address_id";

-- staff.store_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM staff AS child
    LEFT JOIN store AS parent ON child.store_id = parent.store_id
    WHERE child.store_id IS NOT NULL AND parent.store_id IS NULL
) AS "staff contains an orphan store_id";

-- store.address_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM store AS child
    LEFT JOIN address AS parent ON child.address_id = parent.address_id
    WHERE child.address_id IS NOT NULL AND parent.address_id IS NULL
) AS "store contains an orphan address_id";

-- store.manager_staff_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM store AS child
    LEFT JOIN staff AS parent ON child.manager_staff_id = parent.staff_id
    WHERE child.manager_staff_id IS NOT NULL AND parent.staff_id IS NULL
) AS "store contains an orphan manager_staff_id";

-- customer.address_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM customer AS child
    LEFT JOIN address AS parent ON child.address_id = parent.address_id
    WHERE child.address_id IS NOT NULL AND parent.address_id IS NULL
) AS "customer contains an orphan address_id";

-- customer.store_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM customer AS child
    LEFT JOIN store AS parent ON child.store_id = parent.store_id
    WHERE child.store_id IS NOT NULL AND parent.store_id IS NULL
) AS "customer contains an orphan store_id";

-- film.language_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM film AS child
    LEFT JOIN language AS parent ON child.language_id = parent.language_id
    WHERE child.language_id IS NOT NULL AND parent.language_id IS NULL
) AS "film contains an orphan language_id";

-- film.original_language_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM film AS child
    LEFT JOIN language AS parent ON child.original_language_id = parent.language_id
    WHERE child.original_language_id IS NOT NULL AND parent.language_id IS NULL
) AS "film contains an orphan original_language_id";

-- film_actor.actor_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM film_actor AS child
    LEFT JOIN actor AS parent ON child.actor_id = parent.actor_id
    WHERE child.actor_id IS NOT NULL AND parent.actor_id IS NULL
) AS "film_actor contains an orphan actor_id";

-- film_actor.film_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM film_actor AS child
    LEFT JOIN film AS parent ON child.film_id = parent.film_id
    WHERE child.film_id IS NOT NULL AND parent.film_id IS NULL
) AS "film_actor contains an orphan film_id";

-- film_category.film_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM film_category AS child
    LEFT JOIN film AS parent ON child.film_id = parent.film_id
    WHERE child.film_id IS NOT NULL AND parent.film_id IS NULL
) AS "film_category contains an orphan film_id";

-- film_category.category_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM film_category AS child
    LEFT JOIN category AS parent ON child.category_id = parent.category_id
    WHERE child.category_id IS NOT NULL AND parent.category_id IS NULL
) AS "film_category contains an orphan category_id";

-- inventory.film_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM inventory AS child
    LEFT JOIN film AS parent ON child.film_id = parent.film_id
    WHERE child.film_id IS NOT NULL AND parent.film_id IS NULL
) AS "inventory contains an orphan film_id";

-- inventory.store_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM inventory AS child
    LEFT JOIN store AS parent ON child.store_id = parent.store_id
    WHERE child.store_id IS NOT NULL AND parent.store_id IS NULL
) AS "inventory contains an orphan store_id";

-- rental.inventory_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM rental AS child
    LEFT JOIN inventory AS parent ON child.inventory_id = parent.inventory_id
    WHERE child.inventory_id IS NOT NULL AND parent.inventory_id IS NULL
) AS "rental contains an orphan inventory_id";

-- rental.customer_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM rental AS child
    LEFT JOIN customer AS parent ON child.customer_id = parent.customer_id
    WHERE child.customer_id IS NOT NULL AND parent.customer_id IS NULL
) AS "rental contains an orphan customer_id";

-- rental.staff_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM rental AS child
    LEFT JOIN staff AS parent ON child.staff_id = parent.staff_id
    WHERE child.staff_id IS NOT NULL AND parent.staff_id IS NULL
) AS "rental contains an orphan staff_id";

-- payment.customer_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM payment AS child
    LEFT JOIN customer AS parent ON child.customer_id = parent.customer_id
    WHERE child.customer_id IS NOT NULL AND parent.customer_id IS NULL
) AS "payment contains an orphan customer_id";

-- payment.rental_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM payment AS child
    LEFT JOIN rental AS parent ON child.rental_id = parent.rental_id
    WHERE child.rental_id IS NOT NULL AND parent.rental_id IS NULL
) AS "payment contains an orphan rental_id";

-- payment.staff_id に、参照先の欠けた孤立キーがないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM payment AS child
    LEFT JOIN staff AS parent ON child.staff_id = parent.staff_id
    WHERE child.staff_id IS NOT NULL AND parent.staff_id IS NULL
) AS "payment contains an orphan staff_id";

-- 全テーブルの主キーに NULL または重複がないことを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM (
        SELECT 1 AS invalid_key
        FROM country
        GROUP BY country_id
        HAVING country_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM city
        GROUP BY city_id
        HAVING city_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM address
        GROUP BY address_id
        HAVING address_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM language
        GROUP BY language_id
        HAVING language_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM store
        GROUP BY store_id
        HAVING store_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM staff
        GROUP BY staff_id
        HAVING staff_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM actor
        GROUP BY actor_id
        HAVING actor_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM category
        GROUP BY category_id
        HAVING category_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM film
        GROUP BY film_id
        HAVING film_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM film_text
        GROUP BY film_id
        HAVING film_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM film_actor
        GROUP BY actor_id, film_id
        HAVING actor_id IS NULL OR film_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM film_category
        GROUP BY film_id, category_id
        HAVING film_id IS NULL OR category_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM customer
        GROUP BY customer_id
        HAVING customer_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM inventory
        GROUP BY inventory_id
        HAVING inventory_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM rental
        GROUP BY rental_id
        HAVING rental_id IS NULL OR COUNT(*) > 1

        UNION ALL

        SELECT 1 AS invalid_key
        FROM payment
        GROUP BY payment_id
        HAVING payment_id IS NULL OR COUNT(*) > 1
    )
) AS "a primary key contains NULL or duplicate values";

-- film_text がロード時点の film と一致することを検証する。
ASSERT (
    SELECT COUNT(*) = 0
    FROM (
        (SELECT film_id, title, description FROM film
         EXCEPT DISTINCT SELECT film_id, title, description FROM film_text)
        UNION ALL
        (SELECT film_id, title, description FROM film_text
         EXCEPT DISTINCT SELECT film_id, title, description FROM film)
    )
) AS "film_text differs from film";
