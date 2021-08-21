CREATE
DATABASE USER;

USE
USER;

CREATE TABLE users
(
  user_id  VARCHAR(10) NOT NULL,
  name     VARCHAR(50) NOT NULL,
  email    VARCHAR(50) NOT NULL,
  password VARCHAR(60) NOT NULL,
  PRIMARY KEY (user_id),
  UNIQUE uq_users(email)
);

CREATE TABLE group_names
(
  id         INT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
  group_name VARCHAR(20) NOT NULL
);

CREATE TABLE group_users
(
  id         INT         NOT NULL AUTO_INCREMENT,
  group_id   INT         NOT NULL,
  user_id    VARCHAR(10) NOT NULL,
  color_code VARCHAR(7)  NOT NULL,
  PRIMARY KEY (id),
  UNIQUE uq_group_users(group_id, user_id),
  FOREIGN KEY fk_group_id(group_id)
    REFERENCES group_names(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_user_id(user_id)
    REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE group_unapproved_users
(
  id       INT         NOT NULL AUTO_INCREMENT,
  group_id INT         NOT NULL,
  user_id  VARCHAR(10) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE uq_group_unapproved_users(group_id, user_id),
  FOREIGN KEY fk_group_id(group_id)
    REFERENCES group_names(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_user_id(user_id)
    REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE
DATABASE account;

USE
account;

CREATE TABLE big_categories
(
  id               INT         NOT NULL AUTO_INCREMENT,
  category_name    VARCHAR(10) NOT NULL,
  transaction_type ENUM('expense', 'income') NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE medium_categories
(
  id              INT         NOT NULL AUTO_INCREMENT,
  category_name   VARCHAR(10) NOT NULL,
  big_category_id INT         NOT NULL,
  PRIMARY KEY (id),
  UNIQUE uq_medium_category(category_name, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE custom_categories
(
  id              INT         NOT NULL AUTO_INCREMENT,
  category_name   VARCHAR(50) NOT NULL,
  big_category_id INT         NOT NULL,
  user_id         VARCHAR(10) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE uq_custom_category(category_name, big_category_id, user_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  index           idx_user_id(user_id, id)
);

CREATE TABLE transactions
(
  id                 INT         NOT NULL AUTO_INCREMENT,
  transaction_type   ENUM('expense', 'income') NOT NULL,
  posted_date        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date       DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  transaction_date   DATE        NOT NULL,
  shop               VARCHAR(20)          DEFAULT NULL,
  memo               VARCHAR(50)          DEFAULT NULL,
  amount             INT         NOT NULL,
  user_id            VARCHAR(10) NOT NULL,
  big_category_id    INT         NOT NULL,
  medium_category_id INT                  DEFAULT NULL,
  custom_category_id INT                  DEFAULT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_medium_category_id(medium_category_id)
    REFERENCES medium_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_custom_category_id(custom_category_id)
    REFERENCES custom_categories(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  index              idx_user_id(user_id)
);

CREATE TABLE standard_budgets
(
  user_id         VARCHAR(10) NOT NULL,
  big_category_id INT         NOT NULL,
  budget          INT         NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE custom_budgets
(
  user_id         VARCHAR(10) NOT NULL,
  years_months    DATE        NOT NULL,
  big_category_id INT         NOT NULL,
  budget          INT         NOT NULL,
  PRIMARY KEY (user_id, years_months, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE group_custom_categories
(
  id              INT         NOT NULL AUTO_INCREMENT,
  category_name   VARCHAR(50) NOT NULL,
  big_category_id INT         NOT NULL,
  group_id        INT         NOT NULL,
  PRIMARY KEY (id),
  UNIQUE uq_group_custom_category(category_name, big_category_id, group_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  index           idx_group_id(group_id, id)
);

CREATE TABLE group_transactions
(
  id                 INT         NOT NULL AUTO_INCREMENT,
  transaction_type   ENUM('expense', 'income') NOT NULL,
  posted_date        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date       DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  transaction_date   DATE        NOT NULL,
  shop               VARCHAR(20)          DEFAULT NULL,
  memo               VARCHAR(50)          DEFAULT NULL,
  amount             INT         NOT NULL,
  group_id           INT         NOT NULL,
  posted_user_id     VARCHAR(10) NOT NULL,
  updated_user_id    VARCHAR(10)          DEFAULT NULL,
  payment_user_id    VARCHAR(10) NOT NULL,
  big_category_id    INT         NOT NULL,
  medium_category_id INT                  DEFAULT NULL,
  custom_category_id INT                  DEFAULT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_medium_category_id(medium_category_id)
    REFERENCES medium_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_custom_category_id(custom_category_id)
    REFERENCES group_custom_categories(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  index              idx_group_id(group_id)
);

CREATE TABLE group_standard_budgets
(
  group_id        INT NOT NULL,
  big_category_id INT NOT NULL,
  budget          INT NOT NULL DEFAULT 0,
  PRIMARY KEY (group_id, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE group_custom_budgets
(
  group_id        INT  NOT NULL,
  years_months    DATE NOT NULL,
  big_category_id INT  NOT NULL,
  budget          INT  NOT NULL,
  PRIMARY KEY (group_id, years_months, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE group_accounts
(
  id                   INT    NOT NULL AUTO_INCREMENT,
  years_months         DATE   NOT NULL,
  payer_user_id        VARCHAR(10)     DEFAULT NULL,
  recipient_user_id    VARCHAR(10)     DEFAULT NULL,
  payment_amount       INT             DEFAULT NULL,
  payment_confirmation BIT(1) NOT NULL DEFAULT b'0',
  receipt_confirmation BIT(1) NOT NULL DEFAULT b'0',
  group_id             INT    NOT NULL,
  PRIMARY KEY (id),
  UNIQUE uq_group_accounts(years_months, payer_user_id, recipient_user_id, group_id),
  index                idx_group_id(group_id)
);

CREATE
DATABASE todo;

USE
todo;

CREATE TABLE todo_list
(
  id                  INT          NOT NULL AUTO_INCREMENT,
  posted_date         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  implementation_date DATE         NOT NULL,
  due_date            DATE         NOT NULL,
  todo_content        VARCHAR(100) NOT NULL,
  complete_flag       BIT(1)       NOT NULL DEFAULT b'0',
  user_id             VARCHAR(10)  NOT NULL,
  PRIMARY KEY (id),
  index               idx_user_id(user_id)
);

CREATE TABLE regular_shopping_list
(
  id                     INT         NOT NULL AUTO_INCREMENT,
  posted_date            DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date           DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expected_purchase_date DATE        NOT NULL,
  cycle_type             ENUM('daily', 'weekly', 'monthly', 'custom') NOT NULL,
  cycle                  INT                  DEFAULT NULL,
  purchase               VARCHAR(50) NOT NULL,
  shop                   VARCHAR(20)          DEFAULT NULL,
  amount                 INT                  DEFAULT NULL,
  big_category_id        INT         NOT NULL,
  medium_category_id     INT                  DEFAULT NULL,
  custom_category_id     INT                  DEFAULT NULL,
  user_id                VARCHAR(10) NOT NULL,
  transaction_auto_add   BIT(1)      NOT NULL DEFAULT b'0',
  PRIMARY KEY (id)
);

CREATE TABLE shopping_list
(
  id                       INT         NOT NULL AUTO_INCREMENT,
  posted_date              DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date             DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expected_purchase_date   DATE        NOT NULL,
  complete_flag            BIT(1)      NOT NULL DEFAULT b'0',
  purchase                 VARCHAR(50) NOT NULL,
  shop                     VARCHAR(20)          DEFAULT NULL,
  amount                   INT                  DEFAULT NULL,
  big_category_id          INT         NOT NULL,
  medium_category_id       INT                  DEFAULT NULL,
  custom_category_id       INT                  DEFAULT NULL,
  regular_shopping_list_id INT                  DEFAULT NULL,
  user_id                  VARCHAR(10) NOT NULL,
  transaction_auto_add     BIT(1)      NOT NULL DEFAULT b'0',
  transaction_id           INT                  DEFAULT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY fk_shopping_list_id(regular_shopping_list_id)
    REFERENCES regular_shopping_list(id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE group_todo_list
(
  id                  INT          NOT NULL AUTO_INCREMENT,
  posted_date         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  implementation_date DATE         NOT NULL,
  due_date            DATE         NOT NULL,
  todo_content        VARCHAR(100) NOT NULL,
  complete_flag       BIT(1)       NOT NULL DEFAULT b'0',
  user_id             VARCHAR(10)  NOT NULL,
  group_id            INT          NOT NULL,
  PRIMARY KEY (id),
  index               idx_group_id(group_id)
);

CREATE TABLE group_regular_shopping_list
(
  id                     INT         NOT NULL AUTO_INCREMENT,
  posted_date            DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date           DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expected_purchase_date DATE        NOT NULL,
  cycle_type             ENUM('daily', 'weekly', 'monthly', 'custom') NOT NULL,
  cycle                  INT                  DEFAULT NULL,
  purchase               VARCHAR(50) NOT NULL,
  shop                   VARCHAR(20)          DEFAULT NULL,
  amount                 INT                  DEFAULT NULL,
  big_category_id        INT         NOT NULL,
  medium_category_id     INT                  DEFAULT NULL,
  custom_category_id     INT                  DEFAULT NULL,
  payment_user_id        VARCHAR(10)          DEFAULT NULL,
  group_id               INT         NOT NULL,
  transaction_auto_add   BIT(1)      NOT NULL DEFAULT b'0',
  PRIMARY KEY (id)
);

CREATE TABLE group_shopping_list
(
  id                       INT         NOT NULL AUTO_INCREMENT,
  posted_date              DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date             DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expected_purchase_date   DATE        NOT NULL,
  complete_flag            BIT(1)      NOT NULL DEFAULT b'0',
  purchase                 VARCHAR(50) NOT NULL,
  shop                     VARCHAR(20)          DEFAULT NULL,
  amount                   INT                  DEFAULT NULL,
  big_category_id          INT         NOT NULL,
  medium_category_id       INT                  DEFAULT NULL,
  custom_category_id       INT                  DEFAULT NULL,
  regular_shopping_list_id INT                  DEFAULT NULL,
  payment_user_id          VARCHAR(10)          DEFAULT NULL,
  group_id                 INT         NOT NULL,
  transaction_auto_add     BIT(1)      NOT NULL DEFAULT b'0',
  transaction_id           INT                  DEFAULT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY fk_group_shopping_list_id(regular_shopping_list_id)
    REFERENCES group_regular_shopping_list(id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE group_tasks_users
(
  id       INT         NOT NULL AUTO_INCREMENT,
  user_id  VARCHAR(10) NOT NULL,
  group_id INT         NOT NULL,
  PRIMARY KEY (id),
  UNIQUE uq_group_tasks_users(user_id, group_id),
  index    idx_group_id(group_id)
);

CREATE TABLE group_tasks
(
  id                   INT         NOT NULL AUTO_INCREMENT,
  base_date            DATETIME DEFAULT NULL,
  cycle_type           ENUM('every', 'consecutive', 'none') DEFAULT NULL,
  cycle                INT      DEFAULT NULL,
  task_name            VARCHAR(20) NOT NULL,
  group_id             INT         NOT NULL,
  group_tasks_users_id INT      DEFAULT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY fk_group_tasks_users_id(group_tasks_users_id)
    REFERENCES group_tasks_users(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  index                idx_group_id(group_id)
);

USE
USER;

-- users table init data
INSERT INTO
  `users`
VALUES
  ('gohiromi', '郷ひろみ', 'kakeibo@gmail.com', '$2a$10$t2mJ8/chozn4QjVEF4RLy.HkPZUqi3snAvJbRCUTWenkEPlfyFuWi'),
  ('saigo', '西郷隆盛', 'saigo@gmail.com', '$2a$10$t2mJ8/chozn4QjVEF4RLy.HkPZUqi3snAvJbRCUTWenkEPlfyFuWi'),
  ('tati', '舘ひろし', 'tati@gmail.com', '$2a$10$t2mJ8/chozn4QjVEF4RLy.HkPZUqi3snAvJbRCUTWenkEPlfyFuWi'),
  ('tendo', '天童よしみ', 'tendo@gmail.com', '$2a$10$t2mJ8/chozn4QjVEF4RLy.HkPZUqi3snAvJbRCUTWenkEPlfyFuWi');

-- group_names table init data
INSERT INTO
  `group_names`
VALUES
  (1, 'テラスハウス');

-- group_users table init data
INSERT INTO
  `group_users`
VALUES
  (1, 1, 'gohiromi', '#FF0000'),
  (2, 1, 'tati', '#00FFFF'),
  (3, 1, 'tendo', '#80FF00');

-- group_unapproved_users table init data
INSERT INTO
  `group_unapproved_users`
VALUES
  (1, 1, 'saigo');

USE
account;

-- big_categories table default data
INSERT INTO
  `big_categories`
VALUES
  (1, '収入', 'income'),
  (2, '食費', 'expense'),
  (3, '日用品', 'expense'),
  (4, '趣味・娯楽', 'expense'),
  (5, '交際費', 'expense'),
  (6, '交通費', 'expense'),
  (7, '衣服・美容', 'expense'),
  (8, '健康・医療', 'expense'),
  (9, '通信費', 'expense'),
  (10, '教養・教育', 'expense'),
  (11, '住宅', 'expense'),
  (12, '水道・光熱費', 'expense'),
  (13, '自動車', 'expense'),
  (14, '保険', 'expense'),
  (15, '税金・社会保険', 'expense'),
  (16, '現金・カード', 'expense'),
  (17, 'その他', 'expense');

-- medium_categories table default data
INSERT INTO
  `medium_categories`
VALUES
  (1, '給与', 1),
  (2, '賞与', 1),
  (3, '一時所得', 1),
  (4, '事業所得', 1),
  (5, 'その他収入', 1),
  (6, '食料品', 2),
  (7, '朝食', 2),
  (8, '昼食', 2),
  (9, '夕食', 2),
  (10, '外食', 2),
  (11, 'カフェ', 2),
  (12, 'その他食費', 2),
  (13, '消耗品', 3),
  (14, '子育て用品', 3),
  (15, 'ペット用品', 3),
  (16, '家具', 3),
  (17, '家電', 3),
  (18, 'その他日用品', 3),
  (19, 'アウトドア', 4),
  (20, '旅行', 4),
  (21, 'イベント', 4),
  (22, 'スポーツ', 4),
  (23, '映画・動画', 4),
  (24, '音楽', 4),
  (25, '漫画', 4),
  (26, '書籍', 4),
  (27, 'ゲーム', 4),
  (28, 'その他趣味・娯楽', 4),
  (29, '飲み会', 5),
  (30, 'プレゼント', 5),
  (31, '冠婚葬祭', 5),
  (32, 'その他交際費', 5),
  (33, '電車', 6),
  (34, 'バス', 6),
  (35, 'タクシー', 6),
  (36, '新幹線', 6),
  (37, '飛行機', 6),
  (38, 'その他交通費', 6),
  (39, '衣服', 7),
  (40, 'アクセサリー', 7),
  (41, 'クリーニング', 7),
  (42, '美容院・理髪', 7),
  (43, '化粧品', 7),
  (44, 'エステ・ネイル', 7),
  (45, 'その他衣服・美容', 7),
  (46, '病院', 8),
  (47, '薬', 8),
  (48, 'ボディケア', 8),
  (49, 'フィットネス', 8),
  (50, 'その他健康・医療', 8),
  (51, '携帯電話', 9),
  (52, '固定電話', 9),
  (53, 'インターネット', 9),
  (54, '放送サービス', 9),
  (55, '情報サービス', 9),
  (56, '宅配・運送', 9),
  (57, '切手・はがき', 9),
  (58, 'その他通信費', 9),
  (59, '新聞', 10),
  (60, '参考書', 10),
  (61, '受験料', 10),
  (62, '学費', 10),
  (63, '習い事', 10),
  (64, '塾', 10),
  (65, 'その他教養・教育', 10),
  (66, '家賃', 11),
  (67, '住宅ローン', 11),
  (68, 'リフォーム', 11),
  (69, 'その他住宅', 11),
  (70, '水道', 12),
  (71, '電気', 12),
  (72, 'ガス', 12),
  (73, 'その他水道・光熱費', 12),
  (74, '自動車ローン', 13),
  (75, 'ガソリン', 13),
  (76, '駐車場', 13),
  (77, '高速料金', 13),
  (78, '車検・整備', 13),
  (79, 'その他自動車', 13),
  (80, '生命保険', 14),
  (81, '医療保険', 14),
  (82, '自動車保険', 14),
  (83, '住宅保険', 14),
  (84, '学資保険', 14),
  (85, 'その他保険', 14),
  (86, '所得税', 15),
  (87, '住民税', 15),
  (88, '年金保険料', 15),
  (89, '自動車税', 15),
  (90, 'その他税金・社会保険', 15),
  (91, '現金引き出し', 16),
  (92, 'カード引き落とし', 16),
  (93, '電子マネー', 16),
  (94, '立替金', 16),
  (95, 'その他現金・カード', 16),
  (96, '仕送り', 17),
  (97, 'お小遣い', 17),
  (98, '使途不明金', 17),
  (99, '雑費', 17);

-- custom_categories table init data
INSERT INTO
  `custom_categories`
VALUES
  (2, 'お酒', 2, 'gohiromi'),
  (1, '調味料', 2, 'gohiromi');

-- transactions table init data
INSERT INTO
  `transactions`
VALUES
  (1, 'expense', '2021-01-12 22:44:40', '2021-01-12 22:44:40', '2021-01-01', 'コメダ', 'コーヒー', 550, 'gohiromi', 2, 11, NULL),
  (2, 'expense', '2021-01-12 22:48:55', '2021-01-12 23:52:20', '2021-01-03', 'コストコ', '醤油', 410, 'gohiromi', 2, NULL, 1),
  (3, 'expense', '2021-01-12 22:58:58', '2021-01-12 22:58:58', '2021-01-01', 'エニタイムフィットネス', 'ジム会費', 6000, 'gohiromi', 8, 49, NULL),
  (4, 'expense', '2021-01-12 23:00:14', '2021-01-12 23:52:37', '2021-01-05', 'クリエイト', 'トイレットペーパー', 140, 'gohiromi', 3, 13, NULL),
  (5, 'expense', '2021-01-12 23:01:26', '2021-01-12 23:52:45', '2021-01-05', 'クリエイト', '食器用洗剤', 120, 'gohiromi', 3, 13, NULL),
  (6, 'expense', '2021-01-12 23:05:38', '2021-01-12 23:16:24', '2021-01-01', NULL, 'WiFi代', 4500, 'gohiromi', 9, 53, NULL),
  (7, 'expense', '2021-01-12 23:08:05', '2021-01-12 23:53:33', '2021-01-10', 'クリエイト', 'ティッシュ', 210, 'gohiromi', 3, 13, NULL),
  (8, 'expense', '2021-01-12 23:14:23', '2021-01-12 23:53:49', '2021-01-11', 'ビッグヨーサン', '鶏胸肉', 670, 'gohiromi', 2, 6, NULL),
  (9, 'expense', '2021-01-12 23:14:32', '2021-01-12 23:53:05', '2021-01-06', '紀伊國書店', 'リーダブルコード', 2500, 'gohiromi', 10, 60, NULL),
  (10, 'expense', '2021-01-12 23:15:44', '2021-01-12 23:53:55', '2021-01-11', 'ビッグヨーサン', '豚ロース切身メガパック', 818, 'gohiromi', 2, 6, NULL),
  (11, 'expense', '2021-01-12 23:15:47', '2021-01-12 23:53:23', '2021-01-08', NULL, 'ビール', 490, 'gohiromi', 2, NULL, 2),
  (12, 'expense', '2021-01-12 23:17:48', '2021-01-12 23:17:48', '2021-01-02', 'イオン座間', 'えんとつ町のプペル', 1500, 'gohiromi', 4, 23, NULL),
  (13, 'expense', '2021-01-12 23:19:32', '2021-01-12 23:53:40', '2021-01-10', 'au', '携帯代', 3900, 'gohiromi', 9, 51, NULL),
  (14, 'expense', '2021-01-12 23:27:42', '2021-01-12 23:53:16', '2021-01-06', 'ビッグヨーサン', '野菜', 2100, 'gohiromi', 2, 6, NULL),
  (15, 'expense', '2021-01-12 23:29:34', '2021-01-12 23:54:11', '2021-01-12', '第一生命', NULL, 9800, 'gohiromi', 14, 80, NULL),
  (16, 'expense', '2021-01-12 23:30:57', '2021-01-12 23:54:18', '2021-01-13', 'クリエイト', 'シャンプー', 840, 'gohiromi', 3, 13, NULL),
  (17, 'expense', '2021-01-12 23:32:52', '2021-01-12 23:32:52', '2020-12-01', NULL, '米', 3000, 'gohiromi', 2, 6, NULL),
  (18, 'expense', '2021-01-12 23:33:46', '2021-01-12 23:33:46', '2020-12-02', 'マルエツ', '野菜', 2000, 'gohiromi', 2, 6, NULL),
  (19, 'expense', '2021-01-12 23:34:19', '2021-01-12 23:34:19', '2020-12-05', 'クリエイト', 'ボディーソープ', 500, 'gohiromi', 3, 13, NULL),
  (20, 'expense', '2021-01-12 23:35:18', '2021-01-12 23:35:18', '2020-12-09', 'クリエイト', '柔軟剤', 400, 'gohiromi', 3, 13, NULL),
  (21, 'expense', '2021-01-12 23:36:20', '2021-01-12 23:36:20', '2020-12-10', NULL, 'マスタリングTCP/IP', 4000, 'gohiromi', 10, 60, NULL),
  (22, 'expense', '2021-01-12 23:36:55', '2021-01-12 23:36:55', '2020-12-15', NULL, 'コンサート衣装購入', 3600, 'gohiromi', 7, 39, NULL),
  (23, 'expense', '2021-01-12 23:36:57', '2021-01-12 23:36:57', '2020-12-11', 'セブンイレブン', NULL, 200, 'gohiromi', 2, NULL, 2),
  (24, 'expense', '2021-01-12 23:38:18', '2021-01-12 23:38:18', '2020-12-14', 'コストコ', 'チーズケーキ', 1200, 'gohiromi', 2, 6, NULL),
  (25, 'expense', '2021-01-12 23:39:04', '2021-01-12 23:39:04', '2020-12-16', NULL, '耳鼻科', 3000, 'gohiromi', 8, 46, NULL),
  (26, 'expense', '2021-01-12 23:41:57', '2021-01-12 23:41:57', '2020-12-18', 'コメダ', 'アイスコーヒー', 500, 'gohiromi', 2, 11, NULL),
  (27, 'expense', '2021-01-12 23:43:47', '2021-01-12 23:43:47', '2020-12-19', 'Mr.Brothers', NULL, 6000, 'gohiromi', 7, 42, NULL),
  (28, 'expense', '2021-01-12 23:45:25', '2021-01-12 23:45:25', '2020-12-22', 'クリエイト', 'トイレットペーパー', 300, 'gohiromi', 3, 13, NULL),
  (29, 'expense', '2021-01-12 23:46:17', '2021-01-12 23:46:17', '2020-12-24', 'KFC', 'フライドチキン', 1200, 'gohiromi', 2, 9, NULL),
  (30, 'expense', '2021-01-12 23:46:52', '2021-01-12 23:46:52', '2020-12-26', 'UNIQLO', 'ヒートテック', 1500, 'gohiromi', 7, 39, NULL),
  (31, 'expense', '2021-01-18 11:32:52', '2021-01-18 11:32:52', '2021-01-17', 'イオン', 'えんとつ町のプペル', 1600, 'gohiromi', 4, 23, NULL),
  (32, 'expense', '2021-01-18 11:33:56', '2021-01-18 11:33:56', '2021-01-18', 'コメダ', 'コーヒー', 550, 'gohiromi', 2, 7, NULL),
  (35, 'expense', '2021-03-04 11:18:45', '2021-03-04 11:18:57', '2021-03-04', 'スタバ', 'アイスコーヒー', 550, 'aaa', 2, 11, NULL),
  (37, 'expense', '2021-03-04 11:25:04', '2021-03-04 11:25:04', '2021-01-18', 'ヨーサン', '【買い物リスト】豆腐', 110, 'gohiromi', 2, 6, NULL),
  (43, 'expense', '2021-03-04 11:57:03', '2021-03-04 15:31:13', '2021-03-01', 'タリーズ', NULL, 700, 'gohiromi', 2, 7, NULL),
  (44, 'expense', '2021-03-04 11:57:42', '2021-03-04 11:57:42', '2021-03-01', 'マイバスケット', '卵', 220, 'gohiromi', 2, 6, NULL),
  (45, 'expense', '2021-03-04 11:59:45', '2021-03-04 12:14:46', '2021-03-02', '紀伊國屋書店', 'リーダブルコード', 2300, 'gohiromi', 10, 60, NULL),
  (46, 'expense', '2021-03-04 12:00:41', '2021-03-04 12:00:41', '2021-03-03', 'クリエイト', 'ティッシュ', 250, 'gohiromi', 3, 13, NULL),
  (47, 'expense', '2021-03-04 12:01:15', '2021-03-04 12:01:15', '2021-03-03', 'クリエイト', 'トイレットペーパー', 350, 'gohiromi', 3, 13, NULL),
  (48, 'expense', '2021-03-04 12:02:18', '2021-03-04 12:02:18', '2021-03-01', 'ドンキホーテ', '洗顔', 800, 'gohiromi', 7, 43, NULL),
  (49, 'expense', '2021-03-04 12:03:19', '2021-03-04 12:03:19', '2021-03-04', 'ファミリーマート', '缶コーヒー', 120, 'gohiromi', 2, 12, NULL),
  (50, 'expense', '2021-03-04 12:04:06', '2021-03-04 12:04:06', '2021-03-04', NULL, 'フットサルコート代', 400, 'gohiromi', 4, 22, NULL),
  (51, 'expense', '2021-03-04 12:04:52', '2021-03-04 12:04:52', '2021-03-04', 'バーミヤン', NULL, 1200, 'gohiromi', 2, 9, NULL),
  (52, 'expense', '2021-04-12 12:48:32', '2021-04-12 12:48:32', '2021-04-01', 'クリエイト', 'サランラップ', 800, 'gohiromi', 3, 13, NULL),
  (53, 'expense', '2021-04-12 12:49:31', '2021-04-12 12:49:31', '2021-04-03', 'TOHOシネマ', NULL, 1700, 'gohiromi', 4, 23, NULL),
  (54, 'expense', '2021-04-12 12:50:09', '2021-04-12 12:50:09', '2021-04-04', NULL, '米', 7000, 'gohiromi', 2, 6, NULL),
  (55, 'expense', '2021-04-12 12:50:15', '2021-04-12 12:50:15', '2021-01-15', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (56, 'expense', '2021-04-12 12:50:16', '2021-04-12 12:50:16', '2021-01-18', 'ザバス', '【買い物リスト】プロテイン', 4200, 'gohiromi', 8, 49, NULL),
  (57, 'expense', '2021-04-12 12:50:17', '2021-04-12 12:50:17', '2021-01-18', NULL, '【買い物リスト】美顔ローラー', 1600, 'gohiromi', 8, 48, NULL),
  (58, 'expense', '2021-04-12 12:50:20', '2021-04-12 12:50:20', '2021-01-22', 'コストコ', '【買い物リスト】醤油', 340, 'gohiromi', 2, NULL, 1),
  (59, 'expense', '2021-04-12 12:50:31', '2021-04-12 12:50:31', '2021-01-22', NULL, '【買い物リスト】サランラップ', 230, 'gohiromi', 3, 13, NULL),
  (60, 'expense', '2021-04-12 12:50:34', '2021-04-12 12:50:34', '2021-01-22', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (61, 'expense', '2021-04-12 12:50:35', '2021-04-12 12:50:35', '2021-01-27', 'コメヒロ', '【買い物リスト】米', 5300, 'gohiromi', 2, 6, NULL),
  (62, 'expense', '2021-04-12 12:50:36', '2021-04-12 12:50:36', '2021-01-29', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (63, 'expense', '2021-04-12 12:50:37', '2021-04-12 12:50:37', '2021-02-05', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (64, 'expense', '2021-04-12 12:50:38', '2021-04-12 12:50:38', '2021-02-12', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (65, 'expense', '2021-04-12 12:50:39', '2021-04-12 12:50:39', '2021-02-19', 'スカイチケット', '【買い物リスト】航空券', 12000, 'gohiromi', 6, 37, NULL),
  (66, 'expense', '2021-04-12 12:50:40', '2021-04-12 12:50:40', '2021-02-19', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (67, 'expense', '2021-04-12 12:50:41', '2021-04-12 12:50:41', '2021-02-26', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (68, 'expense', '2021-04-12 12:50:42', '2021-04-12 12:50:42', '2021-02-27', 'コメヒロ', '【買い物リスト】米', 5300, 'gohiromi', 2, 6, NULL),
  (69, 'expense', '2021-04-12 12:50:43', '2021-04-12 12:50:43', '2021-03-04', NULL, '【買い物リスト】たまご', 110, 'gohiromi', 2, 6, NULL),
  (70, 'expense', '2021-04-12 12:50:52', '2021-04-12 12:50:52', '2021-03-04', NULL, '【買い物リスト】鍋の食材', 1200, 'gohiromi', 2, 6, NULL),
  (71, 'expense', '2021-04-12 12:50:54', '2021-04-12 12:50:54', '2021-03-05', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (72, 'expense', '2021-04-12 12:50:55', '2021-04-12 12:50:55', '2021-03-12', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (73, 'expense', '2021-04-12 12:50:56', '2021-04-12 12:50:56', '2021-03-19', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (74, 'expense', '2021-04-12 12:50:56', '2021-04-12 12:50:56', '2021-03-26', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (75, 'expense', '2021-04-12 12:50:57', '2021-04-12 12:50:57', '2021-03-27', 'コメヒロ', '【買い物リスト】米', 5300, 'gohiromi', 2, 6, NULL),
  (76, 'expense', '2021-04-12 12:51:08', '2021-04-12 12:51:08', '2021-04-06', NULL, '初めてのGraphQL', 2000, 'gohiromi', 10, 60, NULL),
  (77, 'expense', '2021-04-12 12:51:15', '2021-04-12 12:51:15', '2021-04-02', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (78, 'expense', '2021-04-12 12:51:39', '2021-04-12 12:51:39', '2021-04-09', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 'gohiromi', 3, 13, NULL),
  (79, 'expense', '2021-04-12 12:52:34', '2021-04-12 12:52:34', '2021-04-08', 'スタバ', NULL, 500, 'gohiromi', 2, 11, NULL),
  (80, 'expense', '2021-04-12 12:53:33', '2021-04-12 12:53:33', '2021-04-10', 'Nike', 'ランニングウェア', 3000, 'gohiromi', 4, 22, NULL),
  (81, 'expense', '2021-04-12 12:54:34', '2021-04-12 12:54:34', '2021-04-11', NULL, NULL, 3000, 'gohiromi', 7, 42, NULL),
  (82, 'expense', '2021-04-12 12:55:41', '2021-04-12 12:55:41', '2021-04-11', 'クリエイト', 'シャンプー', 500, 'gohiromi', 3, 13, NULL);

-- standard_budgets table init data
INSERT INTO
  `standard_budgets`
VALUES
  ('gohiromi', 2, 20000),
  ('gohiromi', 3, 5000),
  ('gohiromi', 4, 3000),
  ('gohiromi', 5, 0),
  ('gohiromi', 6, 7000),
  ('gohiromi', 7, 0),
  ('gohiromi', 8, 6000),
  ('gohiromi', 9, 10000),
  ('gohiromi', 10, 0),
  ('gohiromi', 11, 0),
  ('gohiromi', 12, 10000),
  ('gohiromi', 13, 0),
  ('gohiromi', 14, 0),
  ('gohiromi', 15, 0),
  ('gohiromi', 16, 0),
  ('gohiromi', 17, 0),
  ('saigo', 2, 0),
  ('saigo', 3, 0),
  ('saigo', 4, 0),
  ('saigo', 5, 0),
  ('saigo', 6, 0),
  ('saigo', 7, 0),
  ('saigo', 8, 0),
  ('saigo', 9, 0),
  ('saigo', 10, 0),
  ('saigo', 11, 0),
  ('saigo', 12, 0),
  ('saigo', 13, 0),
  ('saigo', 14, 0),
  ('saigo', 15, 0),
  ('saigo', 16, 0),
  ('saigo', 17, 0),
  ('tati', 2, 0),
  ('tati', 3, 0),
  ('tati', 4, 0),
  ('tati', 5, 0),
  ('tati', 6, 0),
  ('tati', 7, 0),
  ('tati', 8, 0),
  ('tati', 9, 0),
  ('tati', 10, 0),
  ('tati', 11, 0),
  ('tati', 12, 0),
  ('tati', 13, 0),
  ('tati', 14, 0),
  ('tati', 15, 0),
  ('tati', 16, 0),
  ('tati', 17, 0),
  ('tendo', 2, 0),
  ('tendo', 3, 0),
  ('tendo', 4, 0),
  ('tendo', 5, 0),
  ('tendo', 6, 0),
  ('tendo', 7, 0),
  ('tendo', 8, 0),
  ('tendo', 9, 0),
  ('tendo', 10, 0),
  ('tendo', 11, 0),
  ('tendo', 12, 0),
  ('tendo', 13, 0),
  ('tendo', 14, 0),
  ('tendo', 15, 0),
  ('tendo', 16, 0),
  ('tendo', 17, 0);

-- custom_budgets table init data
INSERT INTO
  `custom_budgets`
VALUES
  ('gohiromi', '2020-12-01', 2, 20000),
  ('gohiromi', '2020-12-01', 3, 5000),
  ('gohiromi', '2020-12-01', 4, 3000),
  ('gohiromi', '2020-12-01', 5, 0),
  ('gohiromi', '2020-12-01', 6, 7000),
  ('gohiromi', '2020-12-01', 7, 5000),
  ('gohiromi', '2020-12-01', 8, 6000),
  ('gohiromi', '2020-12-01', 9, 10000),
  ('gohiromi', '2020-12-01', 10, 0),
  ('gohiromi', '2020-12-01', 11, 0),
  ('gohiromi', '2020-12-01', 12, 10000),
  ('gohiromi', '2020-12-01', 13, 0),
  ('gohiromi', '2020-12-01', 14, 10000),
  ('gohiromi', '2020-12-01', 15, 0),
  ('gohiromi', '2020-12-01', 16, 0),
  ('gohiromi', '2020-12-01', 17, 0),
  ('gohiromi', '2021-04-01', 2, 25000),
  ('gohiromi', '2021-04-01', 3, 5000),
  ('gohiromi', '2021-04-01', 4, 3000),
  ('gohiromi', '2021-04-01', 5, 0),
  ('gohiromi', '2021-04-01', 6, 7000),
  ('gohiromi', '2021-04-01', 7, 0),
  ('gohiromi', '2021-04-01', 8, 6000),
  ('gohiromi', '2021-04-01', 9, 10000),
  ('gohiromi', '2021-04-01', 10, 0),
  ('gohiromi', '2021-04-01', 11, 0),
  ('gohiromi', '2021-04-01', 12, 12000),
  ('gohiromi', '2021-04-01', 13, 0),
  ('gohiromi', '2021-04-01', 14, 0),
  ('gohiromi', '2021-04-01', 15, 0),
  ('gohiromi', '2021-04-01', 16, 0),
  ('gohiromi', '2021-04-01', 17, 0);

-- group_custom_categories table init data
INSERT INTO
  `group_custom_categories`
VALUES
  (2, '米', 2, 1),
  (3, '調味料', 2, 1),
  (1, '野菜', 2, 1);

-- group_transactions table init data
INSERT INTO
  `group_transactions`
VALUES
  (1, 'expense', '2021-01-13 00:32:01', '2021-01-13 00:32:01', '2021-01-01', NULL, '松坂牛', 10000, 1, 'gohiromi', NULL, 'tati', 2, 6, NULL),
  (2, 'expense', '2021-01-13 00:33:52', '2021-01-13 00:33:52', '2021-01-02', 'クリエイト', 'ティッシュ', 200, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (3, 'expense', '2021-01-13 00:35:50', '2021-01-13 00:35:50', '2021-01-02', NULL, '金柑のど飴', 500, 1, 'gohiromi', NULL, 'tendo', 2, 6, NULL),
  (4, 'expense', '2021-01-13 00:37:42', '2021-01-13 00:42:25', '2021-01-04', 'ビッグヨーサン', '鶏胸肉3つ', 3000, 1, 'gohiromi', 'gohiromi', 'tati', 2, 6, NULL),
  (5, 'expense', '2021-01-13 00:39:31', '2021-01-13 00:39:31', '2021-01-06', NULL, 'シャンプー', 900, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (6, 'expense', '2021-01-13 00:40:25', '2021-01-13 00:40:25', '2021-01-08', '鳥貴族', NULL, 12000, 1, 'gohiromi', NULL, 'tendo', 5, 29, NULL),
  (7, 'expense', '2021-01-13 00:41:57', '2021-01-13 00:41:57', '2021-01-10', 'ニトリ', 'こたつ', 5000, 1, 'gohiromi', NULL, 'tendo', 3, 16, NULL),
  (8, 'expense', '2021-01-13 00:42:59', '2021-01-13 00:45:29', '2021-01-10', 'イオン', '冷凍餃子5袋', 2100, 1, 'gohiromi', 'gohiromi', 'tendo', 2, 6, NULL),
  (9, 'expense', '2021-01-13 00:43:07', '2021-01-13 00:43:07', '2021-01-07', NULL, NULL, 5000, 1, 'gohiromi', NULL, 'gohiromi', 12, 70, NULL),
  (10, 'expense', '2021-01-13 00:43:40', '2021-01-13 00:43:40', '2021-01-07', NULL, NULL, 8000, 1, 'gohiromi', NULL, 'gohiromi', 12, 71, NULL),
  (11, 'expense', '2021-01-13 00:45:58', '2021-01-13 00:45:58', '2021-01-07', NULL, NULL, 6000, 1, 'gohiromi', NULL, 'gohiromi', 12, 72, NULL),
  (12, 'expense', '2021-01-13 00:46:44', '2021-01-13 00:49:19', '2021-01-13', NULL, '仁義なき戦いDVD', 2500, 1, 'gohiromi', 'gohiromi', 'tati', 4, 23, NULL),
  (13, 'expense', '2021-01-13 00:48:52', '2021-01-13 00:48:52', '2021-01-11', NULL, 'レンタカー', 5000, 1, 'gohiromi', NULL, 'gohiromi', 13, 79, NULL),
  (14, 'expense', '2021-01-13 00:48:59', '2021-01-13 00:49:25', '2021-01-13', '叙々苑', NULL, 15000, 1, 'gohiromi', 'gohiromi', 'tendo', 2, 9, NULL),
  (15, 'expense', '2021-01-13 00:51:13', '2021-01-13 00:51:13', '2020-12-01', 'コストコ', 'チーズケーキ', 1400, 1, 'gohiromi', NULL, 'tendo', 2, 6, NULL),
  (16, 'expense', '2021-01-13 00:51:48', '2021-01-13 00:51:48', '2021-01-02', 'ビッグヨーサン', '宮崎牛', 3200, 1, 'gohiromi', NULL, 'tendo', 2, 9, NULL),
  (17, 'expense', '2021-01-13 00:52:37', '2021-01-13 00:52:37', '2020-12-03', NULL, 'ビールジョッキ', 3000, 1, 'gohiromi', NULL, 'tati', 3, 18, NULL),
  (18, 'expense', '2021-01-13 00:55:29', '2021-01-13 00:55:29', '2020-12-04', NULL, '宮崎牛', 5000, 1, 'gohiromi', NULL, 'gohiromi', 2, 6, NULL),
  (19, 'expense', '2021-01-13 00:56:09', '2021-01-13 00:56:09', '2020-12-04', '餃子の王将', NULL, 3000, 1, 'gohiromi', NULL, 'tendo', 2, 10, NULL),
  (20, 'expense', '2021-01-13 00:56:20', '2021-01-13 00:56:20', '2020-12-04', NULL, 'ダイソン', 48000, 1, 'gohiromi', NULL, 'gohiromi', 3, 17, NULL),
  (21, 'expense', '2021-01-13 00:59:44', '2021-01-13 00:59:44', '2020-12-20', 'イオン座間', '鬼滅', 3600, 1, 'tendo', NULL, 'tendo', 4, 23, NULL),
  (22, 'expense', '2021-01-13 01:00:42', '2021-01-13 01:00:42', '2020-12-06', 'ビッグカメラ', 'PS5', 50000, 1, 'gohiromi', NULL, 'tati', 4, 27, NULL),
  (23, 'expense', '2021-01-13 01:01:00', '2021-01-13 01:01:00', '2020-12-07', NULL, 'ダンベル', 1300, 1, 'gohiromi', NULL, 'gohiromi', 8, 49, NULL),
  (24, 'expense', '2021-01-13 01:01:42', '2021-01-13 01:01:42', '2020-12-09', 'クリエイト', '綿棒', 200, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (25, 'expense', '2021-01-13 01:01:49', '2021-01-13 01:01:49', '2020-12-08', NULL, NULL, 6000, 1, 'gohiromi', NULL, 'gohiromi', 12, 70, NULL),
  (26, 'expense', '2021-01-13 01:02:05', '2021-01-13 01:02:05', '2020-12-08', NULL, NULL, 6450, 1, 'gohiromi', NULL, 'gohiromi', 12, 71, NULL),
  (27, 'expense', '2021-01-13 01:02:27', '2021-01-13 01:02:27', '2020-12-08', NULL, NULL, 8363, 1, 'gohiromi', NULL, 'gohiromi', 12, 72, NULL),
  (28, 'expense', '2021-01-13 01:02:50', '2021-01-13 01:02:50', '2020-12-26', '塚田農場', NULL, 9500, 1, 'tendo', NULL, 'tendo', 5, 29, NULL),
  (29, 'expense', '2021-01-13 01:03:08', '2021-01-13 01:03:08', '2020-12-10', 'マルエツ', 'みかん', 800, 1, 'gohiromi', NULL, 'tati', 2, 6, NULL),
  (30, 'expense', '2021-01-13 01:03:29', '2021-01-13 01:03:29', '2020-12-24', 'ケンタッキー', 'フライドチキン', 2300, 1, 'gohiromi', NULL, 'gohiromi', 2, 9, NULL),
  (31, 'expense', '2021-01-13 01:03:54', '2021-01-13 01:03:54', '2020-12-11', '鳥貴族', NULL, 10000, 1, 'gohiromi', NULL, 'tati', 5, 29, NULL),
  (32, 'expense', '2021-01-13 01:04:13', '2021-01-13 01:04:13', '2020-12-26', 'コメヒロ', '米', 6000, 1, 'gohiromi', NULL, 'gohiromi', 2, 6, NULL),
  (33, 'expense', '2021-01-13 01:04:31', '2021-01-13 01:04:31', '2020-12-27', NULL, NULL, 60000, 1, 'tendo', NULL, 'tendo', 11, 66, NULL),
  (34, 'expense', '2021-01-13 01:06:09', '2021-01-13 01:06:09', '2020-12-13', 'クリエイト', 'トイレットペーパー', 210, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (35, 'expense', '2021-01-13 01:06:33', '2021-01-13 01:06:33', '2020-12-11', NULL, '呪術廻戦', 6000, 1, 'gohiromi', NULL, 'tati', 4, 25, NULL),
  (36, 'expense', '2021-01-13 01:06:35', '2021-01-13 01:06:35', '2020-12-27', 'amazon', '炊飯器', 18000, 1, 'tendo', NULL, 'tendo', 3, 17, NULL),
  (37, 'expense', '2021-01-13 01:11:48', '2021-01-13 01:11:48', '2020-11-01', 'コメヒロ', '米', 5000, 1, 'gohiromi', NULL, 'tati', 2, 6, NULL),
  (38, 'expense', '2021-01-13 01:12:10', '2021-01-13 01:12:10', '2020-12-17', 'コストコ', 'コーヒー豆', 600, 1, 'gohiromi', NULL, 'tati', 2, 12, NULL),
  (39, 'expense', '2021-01-13 01:12:29', '2021-01-13 01:12:29', '2020-11-03', 'クリエイト', 'シャンプー', 900, 1, 'gohiromi', NULL, 'tendo', 3, 13, NULL),
  (40, 'expense', '2021-01-13 01:12:30', '2021-01-13 01:12:30', '2020-10-01', 'やきまる', '焼肉', 20500, 1, 'tendo', NULL, 'tendo', 2, 10, NULL),
  (41, 'expense', '2021-01-13 01:13:46', '2021-01-13 01:13:46', '2020-11-05', 'マルエツ', '野菜', 2000, 1, 'gohiromi', NULL, 'tendo', 2, 6, NULL),
  (42, 'expense', '2021-01-13 01:13:55', '2021-01-13 01:13:55', '2020-10-03', 'クリエイト', 'トイレットペーパー', 250, 1, 'tendo', NULL, 'tati', 3, 13, NULL),
  (43, 'expense', '2021-01-13 01:14:11', '2021-01-13 01:14:11', '2020-12-16', NULL, '飲み代', 12000, 1, 'gohiromi', NULL, 'tati', 2, 10, NULL),
  (44, 'expense', '2021-01-13 01:14:56', '2021-01-13 01:14:56', '2020-11-07', 'ビッグカメラ', 'コーヒーメーカー', 15000, 1, 'gohiromi', NULL, 'gohiromi', 3, 17, NULL),
  (45, 'expense', '2021-01-13 01:15:07', '2021-01-13 01:15:07', '2020-10-02', 'sanwa', '鍋食材', 3440, 1, 'tendo', NULL, 'tati', 2, 9, NULL),
  (46, 'expense', '2021-01-13 01:16:05', '2021-01-13 01:16:05', '2020-11-10', NULL, 'みんなのGo言語', 3000, 1, 'gohiromi', NULL, 'gohiromi', 10, 60, NULL),
  (47, 'expense', '2021-01-13 01:17:13', '2021-01-13 01:17:13', '2020-10-10', '旅館', '温泉旅行', 33000, 1, 'tendo', NULL, 'gohiromi', 4, 20, NULL),
  (48, 'expense', '2021-01-13 01:17:27', '2021-01-13 01:17:27', '2020-11-14', NULL, NULL, 5000, 1, 'gohiromi', NULL, 'tati', 12, 70, NULL),
  (49, 'expense', '2021-01-13 01:17:37', '2021-01-13 01:17:37', '2020-10-27', NULL, NULL, 60000, 1, 'tendo', NULL, 'tendo', 11, 66, NULL),
  (50, 'expense', '2021-01-13 01:17:47', '2021-01-13 01:17:47', '2020-11-14', NULL, NULL, 7000, 1, 'gohiromi', NULL, 'tati', 12, 71, NULL),
  (51, 'expense', '2021-01-13 01:17:59', '2021-01-13 01:17:59', '2020-10-15', NULL, 'バスタオル', 1200, 1, 'gohiromi', NULL, 'gohiromi', 3, 18, NULL),
  (52, 'expense', '2021-01-13 01:18:08', '2021-01-13 01:18:08', '2020-11-14', NULL, NULL, 6500, 1, 'gohiromi', NULL, 'tati', 12, 72, NULL),
  (53, 'expense', '2021-01-13 01:18:35', '2021-01-13 01:18:35', '2020-10-12', 'マルエツ', NULL, 4500, 1, 'tendo', NULL, 'tendo', 2, 6, NULL),
  (54, 'expense', '2021-01-13 01:18:59', '2021-01-13 01:18:59', '2020-11-17', NULL, 'ファンヒーター', 6000, 1, 'gohiromi', NULL, 'gohiromi', 3, 17, NULL),
  (55, 'expense', '2021-01-13 01:19:31', '2021-01-13 01:19:31', '2020-10-09', NULL, 'レンタカー', 13000, 1, 'gohiromi', NULL, 'gohiromi', 13, 79, NULL),
  (56, 'expense', '2021-01-13 01:20:27', '2021-01-13 01:20:27', '2020-10-12', NULL, 'Netflix', 1200, 1, 'tendo', NULL, 'gohiromi', 4, 23, NULL),
  (57, 'expense', '2021-01-13 01:20:28', '2021-01-13 01:20:28', '2020-11-19', NULL, 'トイレットペーパー', 500, 1, 'gohiromi', NULL, 'tendo', 3, 13, NULL),
  (58, 'expense', '2021-01-13 01:21:12', '2021-01-13 01:21:12', '2020-11-20', NULL, 'ワイン', 8000, 1, 'gohiromi', NULL, 'tendo', 2, 12, NULL),
  (59, 'expense', '2021-01-13 01:22:35', '2021-01-13 01:22:35', '2020-11-22', NULL, 'SIXPAD', 23000, 1, 'gohiromi', NULL, 'tati', 8, 49, NULL),
  (60, 'expense', '2021-01-13 01:22:48', '2021-01-13 01:22:48', '2020-10-30', 'amazon', 'プロテイン', 4000, 1, 'tendo', NULL, 'tati', 8, 49, NULL),
  (61, 'expense', '2021-01-13 01:23:29', '2021-01-13 01:23:29', '2020-10-26', 'クリエイト', 'のど飴', 300, 1, 'tendo', NULL, 'tendo', 2, 6, NULL),
  (62, 'expense', '2021-01-13 01:24:20', '2021-01-13 01:24:20', '2020-10-22', '楽天', '米 30kg', 8500, 1, 'tendo', NULL, 'gohiromi', 2, 6, NULL),
  (63, 'expense', '2021-01-13 01:25:19', '2021-01-13 01:25:19', '2020-11-24', 'コストコ', '牛肉ブロック', 6500, 1, 'gohiromi', NULL, 'gohiromi', 2, 6, NULL),
  (64, 'expense', '2021-01-13 01:26:31', '2021-01-13 01:26:31', '2020-10-24', NULL, NULL, 1600, 1, 'tendo', NULL, 'tati', 6, 35, NULL),
  (65, 'expense', '2021-01-13 01:27:14', '2021-01-13 01:27:14', '2020-10-24', '焼鳥屋', NULL, 18500, 1, 'tendo', NULL, 'tati', 5, 29, NULL),
  (66, 'expense', '2021-01-13 01:27:45', '2021-01-13 01:27:45', '2020-11-27', '杉の樹', NULL, 13000, 1, 'gohiromi', NULL, 'tati', 5, 29, NULL),
  (67, 'expense', '2021-01-13 01:28:03', '2021-01-13 01:28:03', '2020-11-27', NULL, NULL, 2000, 1, 'gohiromi', NULL, 'gohiromi', 6, 34, NULL),
  (68, 'expense', '2021-01-13 01:29:26', '2021-01-13 01:29:26', '2020-11-28', 'タリーズ', NULL, 1500, 1, 'gohiromi', NULL, 'gohiromi', 2, 11, NULL),
  (69, 'expense', '2021-01-13 01:29:50', '2021-01-13 01:29:50', '2020-10-14', NULL, 'Wi-Fi', 4600, 1, 'tendo', NULL, 'tendo', 9, 53, NULL),
  (70, 'expense', '2021-01-13 01:30:55', '2021-01-13 01:30:55', '2020-10-14', NULL, 'コインランドリー', 800, 1, 'tendo', NULL, 'gohiromi', 7, 41, NULL),
  (71, 'expense', '2021-01-13 01:30:58', '2021-01-13 01:30:58', '2020-11-30', NULL, 'Wi-Fi', 5000, 1, 'gohiromi', NULL, 'tendo', 9, 53, NULL),
  (72, 'expense', '2021-01-13 01:32:04', '2021-01-13 01:32:04', '2020-10-16', 'amazon', 'コーヒーメーカー', 20000, 1, 'tendo', NULL, 'tati', 3, 17, NULL),
  (73, 'expense', '2021-01-18 11:47:16', '2021-01-18 11:47:16', '2021-01-17', 'ビッグヨーサン', '鶏胸肉2kg', 1300, 1, 'gohiromi', NULL, 'gohiromi', 2, 6, NULL),
  (74, 'expense', '2021-01-18 11:48:31', '2021-01-18 11:48:31', '2021-01-18', 'クリエイト', 'ティッシュ', 120, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (75, 'expense', '2021-03-04 11:33:05', '2021-03-04 11:33:33', '2021-03-04', 'クリエイト', 'サランラップ', 900, 1, 'gohiromi', 'gohiromi', 'gohiromi', 3, 13, NULL),
  (76, 'expense', '2021-03-04 11:34:40', '2021-03-04 11:36:22', '2021-03-01', '十字屋', '野菜', 2500, 1, 'gohiromi', 'gohiromi', 'gohiromi', 2, 6, NULL),
  (77, 'expense', '2021-03-04 11:35:20', '2021-03-04 11:35:36', '2021-03-03', NULL, '米30kg', 8500, 1, 'gohiromi', 'gohiromi', 'tendo', 2, 6, NULL),
  (79, 'expense', '2021-03-04 11:38:28', '2021-03-04 11:38:54', '2021-03-04', NULL, 'みんなのGo言語', 2500, 1, 'gohiromi', 'gohiromi', 'tati', 10, 60, NULL),
  (80, 'expense', '2021-03-04 11:39:57', '2021-03-04 11:42:30', '2021-03-02', 'クリエイト', 'トイレットペーパー', 850, 1, 'gohiromi', 'gohiromi', 'tati', 3, 13, NULL),
  (81, 'expense', '2021-03-04 11:42:08', '2021-03-04 11:42:08', '2021-03-02', NULL, NULL, 1200, 1, 'gohiromi', NULL, 'tendo', 6, 35, NULL),
  (82, 'expense', '2021-03-04 11:45:11', '2021-03-04 11:45:11', '2021-02-07', NULL, NULL, 6000, 1, 'gohiromi', NULL, 'tati', 12, 70, NULL),
  (83, 'expense', '2021-03-04 11:45:47', '2021-03-04 11:45:47', '2021-02-07', NULL, NULL, 7500, 1, 'gohiromi', NULL, 'tati', 12, 72, NULL),
  (84, 'expense', '2021-03-04 11:46:15', '2021-03-04 11:46:15', '2021-02-07', NULL, NULL, 8000, 1, 'gohiromi', NULL, 'tati', 12, 71, NULL),
  (85, 'expense', '2021-03-04 11:46:38', '2021-03-04 11:49:56', '2021-02-01', NULL, '米', 8000, 1, 'gohiromi', 'gohiromi', 'gohiromi', 2, NULL, 2),
  (86, 'expense', '2021-03-04 11:47:30', '2021-03-04 11:47:49', '2021-02-02', 'クリエイト', 'ティッシュ', 500, 1, 'gohiromi', 'gohiromi', 'tendo', 3, 13, NULL),
  (87, 'expense', '2021-03-04 11:48:14', '2021-03-04 11:48:14', '2021-02-02', 'クリエイト', 'トイレットペーパー', 900, 1, 'gohiromi', NULL, 'tendo', 3, 18, NULL),
  (88, 'expense', '2021-03-04 11:48:43', '2021-03-04 11:49:26', '2021-02-04', 'コストコ', '野菜', 2000, 1, 'gohiromi', 'gohiromi', 'gohiromi', 2, NULL, 1),
  (89, 'expense', '2021-03-04 14:18:01', '2021-03-04 14:18:01', '2021-03-02', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (90, 'expense', '2021-03-04 14:24:39', '2021-03-04 14:24:39', '2021-03-04', 'ビッグヨーサン', '【買い物リスト】鶏胸肉', 730, 1, 'gohiromi', NULL, 'gohiromi', 2, 6, NULL),
  (91, 'expense', '2021-04-12 12:56:54', '2021-04-12 12:57:12', '2021-04-01', 'クリエイト', 'サランラップ', 1200, 1, 'gohiromi', 'gohiromi', 'tendo', 3, 13, NULL),
  (92, 'expense', '2021-04-12 12:57:41', '2021-04-12 12:57:41', '2021-04-03', NULL, NULL, 8000, 1, 'gohiromi', NULL, 'gohiromi', 2, NULL, 2),
  (93, 'expense', '2021-04-12 12:58:10', '2021-04-12 12:58:10', '2021-04-03', NULL, NULL, 2500, 1, 'gohiromi', NULL, 'gohiromi', 2, NULL, 1),
  (94, 'expense', '2021-04-12 12:59:21', '2021-04-12 12:59:21', '2021-04-04', NULL, NULL, 7000, 1, 'gohiromi', NULL, 'tati', 12, 70, NULL),
  (95, 'expense', '2021-04-12 12:59:46', '2021-04-12 12:59:46', '2021-04-04', NULL, NULL, 6500, 1, 'gohiromi', NULL, 'tati', 12, 71, NULL),
  (96, 'expense', '2021-04-12 13:00:07', '2021-04-12 13:00:07', '2021-04-04', NULL, NULL, 7000, 1, 'gohiromi', NULL, 'tati', 12, 72, NULL),
  (97, 'expense', '2021-04-12 13:01:07', '2021-04-12 13:01:07', '2021-04-05', '業務スーパー', NULL, 1500, 1, 'gohiromi', NULL, 'gohiromi', 2, NULL, 3),
  (98, 'expense', '2021-04-12 13:01:19', '2021-04-12 13:01:19', '2021-01-19', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (99, 'expense', '2021-04-12 13:01:22', '2021-04-12 13:01:22', '2021-01-20', 'クリエイト', '【買い物リスト】歯磨き粉', 200, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (100, 'expense', '2021-04-12 13:01:27', '2021-04-12 13:01:27', '2021-01-26', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (101, 'expense', '2021-04-12 13:01:32', '2021-04-12 13:01:32', '2021-02-02', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (102, 'expense', '2021-04-12 13:01:33', '2021-04-12 13:01:33', '2021-02-06', 'skyticket', '【買い物リスト】航空券3人分 宮崎往復', 66000, 1, 'gohiromi', NULL, 'tendo', 6, 37, NULL),
  (103, 'expense', '2021-04-12 13:01:44', '2021-04-12 13:01:44', '2021-02-09', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (104, 'expense', '2021-04-12 13:01:50', '2021-04-12 13:01:50', '2021-02-16', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (105, 'expense', '2021-04-12 13:01:51', '2021-04-12 13:01:51', '2021-02-20', 'クリエイト', '【買い物リスト】歯磨き粉', 200, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (106, 'expense', '2021-04-12 13:01:56', '2021-04-12 13:01:56', '2021-02-23', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'tendo', 3, 13, NULL),
  (107, 'expense', '2021-04-12 13:02:05', '2021-04-12 13:02:05', '2021-03-04', NULL, '【買い物リスト】サランラップ', 110, 1, 'gohiromi', NULL, 'tendo', 3, 13, NULL),
  (108, 'expense', '2021-04-12 13:02:10', '2021-04-12 13:02:10', '2021-03-16', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (109, 'expense', '2021-04-12 13:02:10', '2021-04-12 13:02:10', '2021-04-07', 'クリエイト', 'ボディーソープ', 500, 1, 'gohiromi', NULL, 'tendo', 3, 13, NULL),
  (110, 'expense', '2021-04-12 13:02:20', '2021-04-12 13:02:20', '2021-03-18', NULL, '【買い物リスト】キャベツ', 100, 1, 'gohiromi', NULL, 'gohiromi', 2, NULL, 1),
  (111, 'expense', '2021-04-12 13:02:21', '2021-04-12 13:02:21', '2021-03-20', 'クリエイト', '【買い物リスト】歯磨き粉', 200, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (112, 'expense', '2021-04-12 13:02:25', '2021-04-12 13:02:25', '2021-03-23', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'gohiromi', 3, 13, NULL),
  (113, 'expense', '2021-04-12 13:02:35', '2021-04-12 13:02:35', '2021-03-25', NULL, '【買い物リスト】ハンドソープ', 200, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (114, 'expense', '2021-04-12 13:02:40', '2021-04-12 13:02:40', '2021-03-30', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (115, 'expense', '2021-04-12 13:02:48', '2021-04-12 13:02:48', '2021-04-06', 'クリエイト', '【買い物リスト】トイレットペーパー', 120, 1, 'gohiromi', NULL, 'tati', 3, 13, NULL),
  (116, 'expense', '2021-04-12 13:03:05', '2021-04-12 13:03:05', '2021-04-08', 'クリエイト', 'ハンドソープ', 250, 1, 'gohiromi', NULL, 'tendo', 3, 13, NULL),
  (117, 'expense', '2021-04-12 13:04:00', '2021-04-12 13:04:11', '2021-04-09', '鳥貴族', NULL, 20000, 1, 'gohiromi', 'gohiromi', 'tati', 5, 29, NULL),
  (118, 'expense', '2021-04-12 13:05:06', '2021-04-12 13:05:06', '2021-04-10', '業務スーパー', '牛肉ブロック', 2500, 1, 'gohiromi', NULL, 'gohiromi', 2, 6, NULL),
  (119, 'expense', '2021-04-12 13:06:33', '2021-04-12 13:06:33', '2021-04-10', 'エディオン', '掃除機', 20000, 1, 'gohiromi', NULL, 'tendo', 3, 17, NULL),
  (120, 'expense', '2021-04-12 13:07:38', '2021-04-12 13:07:38', '2021-04-11', NULL, '鶏胸肉', 4000, 1, 'gohiromi', NULL, 'gohiromi', 2, 6, NULL),
  (121, 'expense', '2021-04-12 13:08:56', '2021-04-12 13:08:56', '2021-04-12', 'クリエイト', 'アルミホイル', 200, 1, 'gohiromi', NULL, 'tendo', 3, 13, NULL);

-- group_standard_budgets table init data
INSERT INTO
  `group_standard_budgets`
VALUES
  (1, 2, 18000),
  (1, 3, 3000),
  (1, 4, 0),
  (1, 5, 0),
  (1, 6, 0),
  (1, 7, 0),
  (1, 8, 0),
  (1, 9, 10000),
  (1, 10, 8000),
  (1, 11, 90000),
  (1, 12, 18000),
  (1, 13, 0),
  (1, 14, 0),
  (1, 15, 0),
  (1, 16, 0),
  (1, 17, 0);

-- group_accounts table init data
INSERT INTO
  `group_accounts`
VALUES
  (1, '2020-12-01', 'tati', 'tendo', 4641, 0x00, 0x00, 1),
  (2, '2020-12-01', 'gohiromi', 'tendo', 3618, 0x00, 0x00, 1),
  (3, '2020-10-01', 'tati', 'tendo', 17340, 0x00, 0x00, 1),
  (4, '2020-10-01', 'gohiromi', 'tendo', 7430, 0x00, 0x00, 1),
  (5, '2021-01-01', 'tati', 'tendo', 11013, 0x00, 0x00, 1),
  (6, '2021-01-01', 'gohiromi', 'tendo', 33, 0x00, 0x00, 1),
  (7, '2021-02-01', 'gohiromi', 'tendo', 22873, 0x00, 0x00, 1),
  (8, '2021-02-01', 'tati', 'tendo', 11453, 0x00, 0x00, 1),
  (9, '2020-11-01', 'tendo', 'tati', 20233, 0x00, 0x00, 1),
  (10, '2020-11-01', 'gohiromi', 'tati', 2633, 0x00, 0x00, 1);

USE
todo;

-- todo_list table init data
INSERT INTO
  `todo_list`
VALUES
  (1, '2021-01-12 23:51:02', '2021-01-15 16:01:38', '2021-01-01', '2021-01-01', '初詣', 0x01, 'gohiromi'),
  (2, '2021-01-12 23:51:40', '2021-01-15 16:01:43', '2021-01-04', '2021-01-04', '病院', 0x01, 'gohiromi'),
  (3, '2021-01-12 23:52:01', '2021-01-15 16:01:45', '2021-01-05', '2021-01-05', '参考書を購入', 0x01, 'gohiromi'),
  (4, '2021-01-12 23:52:29', '2021-01-15 16:01:44', '2021-01-04', '2021-01-04', '野菜を購入', 0x01, 'gohiromi'),
  (5, '2021-01-12 23:53:05', '2021-01-15 16:01:41', '2021-01-03', '2021-01-03', '洗濯', 0x01, 'gohiromi'),
  (6, '2021-01-12 23:53:54', '2021-01-15 16:01:46', '2021-01-07', '2021-01-07', '米を購入', 0x01, 'gohiromi'),
  (7, '2021-01-12 23:54:35', '2021-01-15 16:01:49', '2021-01-11', '2021-01-11', '病院', 0x01, 'gohiromi'),
  (8, '2021-01-12 23:55:58', '2021-01-15 16:01:47', '2021-01-09', '2021-01-09', 'ジム', 0x01, 'gohiromi'),
  (9, '2021-01-12 23:57:18', '2021-04-12 12:49:14', '2021-01-16', '2021-01-16', '部屋の掃除', 0x01, 'gohiromi'),
  (10, '2021-01-13 00:01:02', '2021-04-12 12:49:15', '2021-01-17', '2021-01-17', '不動産に連絡', 0x01, 'gohiromi'),
  (11, '2021-01-13 00:01:57', '2021-04-12 12:49:20', '2021-03-05', '2021-03-05', '鍋パーティー', 0x01, 'gohiromi'),
  (12, '2021-01-13 00:07:52', '2021-03-04 14:47:26', '2021-03-04', '2021-03-04', '楽天モバイルに行く', 0x01, 'gohiromi'),
  (13, '2021-01-13 00:11:30', '2021-04-12 12:49:22', '2021-03-17', '2021-03-17', '米を購入', 0x01, 'gohiromi'),
  (14, '2021-01-13 00:11:38', '2021-04-12 12:49:26', '2021-03-26', '2021-03-26', '鍋の買い出し', 0x01, 'gohiromi'),
  (15, '2021-01-13 00:12:35', '2021-04-12 12:49:25', '2021-03-25', '2021-03-25', 'ハンドソープを買う', 0x01, 'gohiromi'),
  (16, '2021-01-13 00:13:00', '2021-04-12 12:49:13', '2021-01-14', '2021-01-14', 'サランラップを購入', 0x01, 'gohiromi'),
  (17, '2021-01-13 00:13:25', '2021-01-15 16:01:48', '2021-01-10', '2021-01-10', '洗濯', 0x01, 'gohiromi'),
  (18, '2021-01-13 00:16:39', '2021-04-12 12:49:17', '2021-01-24', '2021-01-24', '参考書を購入', 0x01, 'gohiromi'),
  (19, '2021-01-13 00:16:52', '2021-04-12 12:49:19', '2021-01-24', '2021-01-24', '映画を見にいく', 0x01, 'gohiromi'),
  (20, '2021-01-13 00:17:08', '2021-04-12 12:49:16', '2021-01-20', '2021-01-20', '洗濯', 0x01, 'gohiromi'),
  (21, '2021-01-13 00:17:34', '2021-04-12 12:49:19', '2021-01-26', '2021-01-26', '野菜と鶏肉を購入', 0x01, 'gohiromi'),
  (22, '2021-01-13 00:17:54', '2021-04-12 12:49:23', '2021-03-24', '2021-03-24', '米を購入', 0x01, 'gohiromi'),
  (23, '2021-01-13 00:39:29', '2021-04-12 12:49:11', '2021-01-13', '2021-01-14', 'マイクロサービスアーキテクチャー参考書購入', 0x01, 'gohiromi'),
  (24, '2021-01-18 11:45:40', '2021-04-12 12:49:15', '2021-01-18', '2021-01-18', '電車定期券更新', 0x01, 'gohiromi'),
  (25, '2021-03-04 14:07:19', '2021-04-12 12:49:21', '2021-03-05', '2021-03-05', '部屋の掃除', 0x01, 'gohiromi'),
  (26, '2021-03-04 14:23:02', '2021-04-12 12:49:21', '2021-03-07', '2021-03-07', '部屋の掃除', 0x01, 'gohiromi'),
  (28, '2021-04-12 12:53:43', '2021-04-12 12:53:43', '2021-04-30', '2021-04-30', '社会保険支払', 0x00, 'gohiromi');

-- regular_shopping_list table init data
INSERT INTO
  `regular_shopping_list`
VALUES
  (1, '2021-01-15 14:36:42', '2021-04-12 12:43:16', '2021-04-16', 'weekly', NULL, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 'gohiromi', 0x01),
  (2, '2021-01-15 14:42:05', '2021-04-12 12:43:16', '2021-04-27', 'monthly', NULL, '米', 'コメヒロ', 5300, 2, 6, NULL, 'gohiromi', 0x01);

-- shopping_list table init data
INSERT INTO
  `shopping_list`
VALUES
  (1, '2021-01-15 14:36:42', '2021-04-12 12:50:34', '2021-01-22', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 60),
  (2, '2021-01-15 14:36:42', '2021-04-12 12:50:15', '2021-01-15', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 55),
  (3, '2021-01-15 14:37:51', '2021-04-12 12:50:20', '2021-01-22', 0x01, '醤油', 'コストコ', 340, 2, NULL, 1, NULL, 'gohiromi', 0x01, 58),
  (4, '2021-01-15 14:40:57', '2021-04-12 12:50:31', '2021-01-22', 0x01, 'サランラップ', NULL, 230, 3, 13, NULL, NULL, 'gohiromi', 0x01, 59),
  (6, '2021-01-15 14:44:02', '2021-04-12 12:50:35', '2021-01-27', 0x01, '米', 'コメヒロ', 5300, 2, 6, NULL, 2, 'gohiromi', 0x01, 61),
  (7, '2021-01-15 14:47:57', '2021-04-12 12:50:39', '2021-02-19', 0x01, '航空券', 'スカイチケット', 12000, 6, 37, NULL, NULL, 'gohiromi', 0x01, 65),
  (8, '2021-01-18 11:35:43', '2021-04-12 12:50:16', '2021-01-18', 0x01, 'プロテイン', 'ザバス', 4200, 8, 49, NULL, NULL, 'gohiromi', 0x01, 56),
  (9, '2021-01-18 11:38:25', '2021-04-12 12:50:17', '2021-01-18', 0x01, '美顔ローラー', NULL, 1600, 8, 48, NULL, NULL, 'gohiromi', 0x01, 57),
  (10, '2021-01-18 11:42:48', '2021-03-04 11:25:04', '2021-01-18', 0x01, '豆腐', 'ヨーサン', 110, 2, 6, NULL, NULL, 'gohiromi', 0x01, 37),
  (11, '2021-03-04 11:15:25', '2021-04-12 12:50:36', '2021-01-29', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 62),
  (13, '2021-03-04 11:15:25', '2021-04-12 12:50:37', '2021-02-05', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 63),
  (16, '2021-03-04 11:15:25', '2021-04-12 12:50:38', '2021-02-12', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 64),
  (18, '2021-03-04 11:15:25', '2021-04-12 12:50:40', '2021-02-19', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 66),
  (20, '2021-03-04 11:15:25', '2021-04-12 12:50:41', '2021-02-26', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 67),
  (22, '2021-03-04 11:15:25', '2021-04-12 12:50:54', '2021-03-05', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 71),
  (23, '2021-03-04 11:15:25', '2021-04-12 12:50:42', '2021-02-27', 0x01, '米', 'コメヒロ', 5300, 2, 6, NULL, 2, 'gohiromi', 0x01, 68),
  (24, '2021-03-04 11:15:25', '2021-04-12 12:50:57', '2021-03-27', 0x01, '米', 'コメヒロ', 5300, 2, 6, NULL, 2, 'gohiromi', 0x01, 75),
  (25, '2021-03-04 11:43:34', '2021-04-12 12:50:43', '2021-03-04', 0x01, 'たまご', NULL, 110, 2, 6, NULL, NULL, 'gohiromi', 0x01, 69),
  (26, '2021-03-04 14:08:26', '2021-04-12 12:50:52', '2021-03-04', 0x01, '鍋の食材', NULL, 1200, 2, 6, NULL, NULL, 'gohiromi', 0x01, 70),
  (27, '2021-04-12 12:43:16', '2021-04-12 12:50:55', '2021-03-12', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 72),
  (28, '2021-04-12 12:43:16', '2021-04-12 12:50:56', '2021-03-19', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 73),
  (29, '2021-04-12 12:43:16', '2021-04-12 12:50:57', '2021-03-26', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 74),
  (31, '2021-04-12 12:43:16', '2021-04-12 12:51:15', '2021-04-02', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 77),
  (33, '2021-04-12 12:43:16', '2021-04-12 12:51:39', '2021-04-09', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, 78),
  (35, '2021-04-12 12:43:16', '2021-04-12 12:43:16', '2021-04-16', 0x00, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 0x01, NULL),
  (39, '2021-04-12 12:43:16', '2021-04-12 12:43:16', '2021-04-27', 0x00, '米', 'コメヒロ', 5300, 2, 6, NULL, 2, 'gohiromi', 0x01, NULL),
  (40, '2021-04-12 12:55:14', '2021-04-12 12:55:14', '2021-04-20', 0x00, '鶏胸肉3パック購入', NULL, NULL, 2, 6, NULL, NULL, 'gohiromi', 0x01, NULL),
  (41, '2021-04-12 12:57:27', '2021-04-12 12:57:27', '2021-04-12', 0x00, 'gRPC書籍', 'amazon', 2300, 10, 60, NULL, NULL, 'gohiromi', 0x01, NULL);

-- group_todo_list table init data
INSERT INTO
  `group_todo_list`
VALUES
  (1, '2021-01-13 01:32:51', '2021-01-15 15:57:18', '2021-01-01', '2021-01-01', '初詣', 0x01, 'gohiromi', 1),
  (2, '2021-01-13 01:33:24', '2021-01-15 15:57:21', '2021-01-02', '2021-01-02', '鍋パーティー', 0x01, 'gohiromi', 1),
  (3, '2021-01-13 01:34:00', '2021-04-12 13:00:28', '2021-01-31', '2021-01-31', '引越し', 0x01, 'tendo', 1),
  (4, '2021-01-13 01:34:32', '2021-04-12 13:00:25', '2021-01-27', '2021-01-27', '居酒屋', 0x01, 'tendo', 1),
  (5, '2021-01-13 01:36:05', '2021-04-12 13:00:20', '2021-01-16', '2021-01-16', '焼肉', 0x01, 'gohiromi', 1),
  (6, '2021-01-13 01:36:09', '2021-04-12 13:00:26', '2021-01-29', '2021-01-29', '部屋の大掃除', 0x01, 'tendo', 1),
  (7, '2021-01-13 01:36:26', '2021-04-12 13:00:19', '2021-01-15', '2021-01-15', '洗濯', 0x01, 'gohiromi', 1),
  (8, '2021-01-13 01:36:37', '2021-04-12 13:00:22', '2021-01-22', '2021-01-22', '宅飲み', 0x01, 'tendo', 1),
  (9, '2021-01-13 01:37:08', '2021-04-12 13:00:20', '2021-01-18', '2021-01-18', '不動産に連絡', 0x01, 'gohiromi', 1),
  (10, '2021-01-13 01:37:17', '2021-01-15 15:57:39', '2020-12-01', '2020-12-01', 'コストコチーズケーキ購入', 0x01, 'gohiromi', 1),
  (11, '2021-01-13 01:37:58', '2021-01-15 15:57:40', '2020-12-01', '2020-12-01', 'コーヒーフィルター購入', 0x01, 'gohiromi', 1),
  (12, '2021-01-13 01:39:03', '2021-01-15 15:57:41', '2020-12-03', '2020-12-06', 'ハワイ旅行計画', 0x01, 'gohiromi', 1),
  (13, '2021-01-13 01:39:12', '2021-04-12 13:00:31', '2021-03-17', '2021-03-17', '米を購入', 0x01, 'gohiromi', 1),
  (14, '2021-01-13 01:39:12', '2021-03-04 14:09:28', '2021-03-26', '2021-03-26', '鍋の買い出し', 0x00, 'tendo', 1),
  (15, '2021-01-13 01:40:45', '2021-04-12 13:00:32', '2021-03-25', '2021-03-25', 'ハンドソープを買う', 0x01, 'tendo', 1),
  (16, '2021-01-13 01:41:23', '2021-01-15 15:57:44', '2020-12-09', '2020-12-09', '天童よしみにサプライズクリスマスプレゼント購入', 0x01, 'gohiromi', 1),
  (17, '2021-01-13 01:41:34', '2021-04-12 13:00:25', '2021-01-23', '2021-01-23', '不要な家具の売り出し', 0x01, 'gohiromi', 1),
  (18, '2021-01-13 01:42:40', '2021-04-12 13:00:27', '2021-01-30', '2021-01-30', 'レンタカーを借りる', 0x01, 'gohiromi', 1),
  (19, '2021-01-13 01:42:47', '2021-01-15 15:57:47', '2020-12-20', '2020-12-20', '宮崎帰省航空券予約', 0x01, 'gohiromi', 1),
  (20, '2021-01-13 01:43:57', '2021-04-12 13:00:21', '2021-01-19', '2021-01-19', '調味料を買う', 0x01, 'gohiromi', 1),
  (21, '2021-01-13 01:45:19', '2021-01-15 15:57:56', '2021-01-08', '2021-01-08', 'シャンプー, ボディーソープ購入', 0x01, 'gohiromi', 1),
  (22, '2021-01-13 01:46:43', '2021-04-12 13:00:18', '2021-01-12', '2021-01-12', 'ブロッコリー購入', 0x01, 'gohiromi', 1),
  (23, '2021-01-13 01:46:54', '2021-01-15 15:57:24', '2021-01-04', '2021-01-04', 'トイレットペーパー購入', 0x01, 'gohiromi', 1),
  (24, '2021-01-13 01:49:00', '2021-01-15 15:57:58', '2021-01-10', '2021-01-10', '各個人部屋大掃除', 0x01, 'gohiromi', 1),
  (25, '2021-01-13 01:49:04', '2021-01-15 15:57:22', '2021-01-03', '2021-01-03', '野菜を購入', 0x01, 'gohiromi', 1),
  (26, '2021-03-04 14:23:02', '2021-04-12 13:00:29', '2021-03-07', '2021-03-07', '部屋の掃除', 0x01, 'gohiromi', 1),
  (27, '2021-04-12 13:05:16', '2021-04-12 13:05:16', '2021-04-16', '2021-04-16', '宅飲み', 0x00, 'gohiromi', 1),
  (28, '2021-04-12 13:06:28', '2021-04-12 13:06:28', '2021-04-12', '2021-04-20', 'ハワイ旅行計画立てる', 0x00, 'gohiromi', 1),
  (29, '2021-04-12 13:13:01', '2021-04-12 13:13:01', '2021-04-17', '2021-04-17', '帰省のための航空チケット確認', 0x00, 'gohiromi', 1),
  (30, '2021-04-12 13:15:00', '2021-04-12 13:15:00', '2021-04-18', '2021-04-18', '実家からの荷物受け取り', 0x00, 'gohiromi', 1),
  (31, '2021-04-12 13:15:38', '2021-04-12 13:15:38', '2021-04-23', '2021-04-23', '宅飲み', 0x00, 'gohiromi', 1);

-- group_regular_shopping_list table init data
INSERT INTO
  `group_regular_shopping_list`
VALUES
  (1, '2021-01-18 16:42:38', '2021-04-12 12:43:21', '2021-04-13', 'weekly', NULL, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, NULL, 1, 0x01),
  (2, '2021-01-18 16:47:58', '2021-04-12 12:43:21', '2021-04-20', 'monthly', NULL, '歯磨き粉', 'クリエイト', 200, 3, 13, NULL, 'gohiromi', 1, 0x01);

-- group_shopping_list table init data
INSERT INTO
  `group_shopping_list`
VALUES
  (1, '2021-01-18 16:42:38', '2021-04-12 13:01:19', '2021-01-19', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'tati', 1, 0x01, 98),
  (2, '2021-01-18 16:44:04', '2021-03-04 14:24:39', '2021-03-04', 0x01, '鶏胸肉', 'ビッグヨーサン', 730, 2, 6, NULL, NULL, 'gohiromi', 1, 0x01, 90),
  (3, '2021-01-18 16:47:03', '2021-04-12 13:01:33', '2021-02-06', 0x01, '航空券3人分 宮崎往復', 'skyticket', 66000, 6, 37, NULL, NULL, 'tendo', 1, 0x01, 102),
  (4, '2021-01-18 16:47:58', '2021-04-12 13:01:22', '2021-01-20', 0x01, '歯磨き粉', 'クリエイト', 200, 3, 13, NULL, 2, 'gohiromi', 1, 0x01, 99),
  (5, '2021-03-04 11:20:03', '2021-04-12 13:01:27', '2021-01-26', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'tati', 1, 0x01, 100),
  (6, '2021-03-04 11:20:03', '2021-04-12 13:01:32', '2021-02-02', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'tati', 1, 0x01, 101),
  (8, '2021-03-04 11:20:03', '2021-04-12 13:01:44', '2021-02-09', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'tati', 1, 0x01, 103),
  (11, '2021-03-04 11:20:03', '2021-04-12 13:01:50', '2021-02-16', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 1, 0x01, 104),
  (12, '2021-03-04 11:20:03', '2021-04-12 13:01:56', '2021-02-23', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'tendo', 1, 0x01, 106),
  (15, '2021-03-04 11:20:03', '2021-03-04 14:18:01', '2021-03-02', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 1, 0x01, 89),
  (19, '2021-03-04 11:20:03', '2021-04-12 13:01:51', '2021-02-20', 0x01, '歯磨き粉', 'クリエイト', 200, 3, 13, NULL, 2, 'gohiromi', 1, 0x01, 105),
  (20, '2021-03-04 11:20:03', '2021-04-12 13:02:21', '2021-03-20', 0x01, '歯磨き粉', 'クリエイト', 200, 3, 13, NULL, 2, 'gohiromi', 1, 0x01, 111),
  (21, '2021-03-04 14:19:01', '2021-04-12 13:02:05', '2021-03-04', 0x01, 'サランラップ', NULL, 110, 3, 13, NULL, NULL, 'tendo', 1, 0x01, 107),
  (22, '2021-03-04 14:19:31', '2021-04-12 13:02:20', '2021-03-18', 0x01, 'キャベツ', NULL, 100, 2, NULL, 1, NULL, 'gohiromi', 1, 0x01, 110),
  (23, '2021-03-04 14:28:07', '2021-04-12 13:02:35', '2021-03-25', 0x01, 'ハンドソープ', NULL, 200, 3, 13, NULL, NULL, 'tati', 1, 0x01, 113),
  (24, '2021-04-12 12:43:21', '2021-04-12 13:02:10', '2021-03-16', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'tati', 1, 0x01, 108),
  (26, '2021-04-12 12:43:21', '2021-04-12 13:02:25', '2021-03-23', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'gohiromi', 1, 0x01, 112),
  (28, '2021-04-12 12:43:21', '2021-04-12 13:02:40', '2021-03-30', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'tati', 1, 0x01, 114),
  (30, '2021-04-12 12:43:21', '2021-04-12 13:02:48', '2021-04-06', 0x01, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, 'tati', 1, 0x01, 115),
  (32, '2021-04-12 12:43:21', '2021-04-12 12:43:21', '2021-04-13', 0x00, 'トイレットペーパー', 'クリエイト', 120, 3, 13, NULL, 1, NULL, 1, 0x01, NULL),
  (34, '2021-04-12 12:43:21', '2021-04-12 12:43:21', '2021-04-20', 0x00, '歯磨き粉', 'クリエイト', 200, 3, 13, NULL, 2, 'gohiromi', 1, 0x01, NULL),
  (35, '2021-04-12 13:04:07', '2021-04-12 13:04:07', '2021-04-12', 0x00, '白菜', 'マルエツ', NULL, 2, NULL, 1, NULL, NULL, 1, 0x01, NULL);

-- group_tasks_users table init data
INSERT INTO
  `group_tasks_users`
VALUES
  (1, 'gohiromi', 1),
  (2, 'tati', 1),
  (3, 'tendo', 1);

-- group_tasks table init data
INSERT INTO
  `group_tasks`
VALUES
  (1, '2021-04-11 00:00:00', 'consecutive', 2, '料理', 1, 2),
  (2, '2021-04-12 00:00:00', 'consecutive', 1, '皿洗い', 1, 1),
  (3, '2021-04-10 00:00:00', 'every', 3, '洗濯', 1, 2),
  (4, NULL, NULL, NULL, '部屋掃除', 1, NULL),
  (5, NULL, NULL, NULL, '風呂掃除', 1, NULL);
