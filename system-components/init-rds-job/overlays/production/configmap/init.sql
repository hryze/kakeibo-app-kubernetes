CREATE DATABASE user;
USE user;

CREATE TABLE users
(
  user_id VARCHAR(10) NOT NULL,
  name VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  password VARCHAR(60) NOT NULL,
  PRIMARY KEY(user_id),
  UNIQUE uq_users(email)
);

CREATE TABLE group_names
(
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  group_name VARCHAR(20) NOT NULL
);

CREATE TABLE group_users
(
  id INT NOT NULL AUTO_INCREMENT,
  group_id INT NOT NULL,
  user_id VARCHAR(10) NOT NULL,
  color_code VARCHAR(7) NOT NULL,
  PRIMARY KEY(id),
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
  id INT NOT NULL AUTO_INCREMENT,
  group_id INT NOT NULL,
  user_id VARCHAR(10) NOT NULL,
  PRIMARY KEY(id),
  UNIQUE uq_group_unapproved_users(group_id, user_id),
  FOREIGN KEY fk_group_id(group_id)
    REFERENCES group_names(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_user_id(user_id)
    REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE DATABASE account;
USE account;

CREATE TABLE big_categories
(
  id INT NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(10) NOT NULL,
  transaction_type ENUM('expense', 'income') NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE medium_categories
(
  id INT NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(10) NOT NULL,
  big_category_id INT NOT NULL,
  PRIMARY KEY(id),
  UNIQUE uq_medium_category(category_name, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE custom_categories
(
  id INT NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(50) NOT NULL,
  big_category_id INT NOT NULL,
  user_id VARCHAR(10) NOT NULL,
  PRIMARY KEY(id),
  UNIQUE uq_custom_category(category_name, big_category_id, user_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_user_id(user_id, id)
);

CREATE TABLE transactions
(
  id INT NOT NULL AUTO_INCREMENT,
  transaction_type ENUM('expense', 'income') NOT NULL,
  posted_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  transaction_date DATE NOT NULL,
  shop VARCHAR(20) DEFAULT NULL,
  memo VARCHAR(50) DEFAULT NULL,
  amount INT NOT NULL,
  user_id VARCHAR(10) NOT NULL,
  big_category_id INT NOT NULL,
  medium_category_id INT DEFAULT NULL,
  custom_category_id INT DEFAULT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_medium_category_id(medium_category_id)
    REFERENCES medium_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_custom_category_id(custom_category_id)
    REFERENCES custom_categories(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_user_id(user_id)
);

CREATE TABLE standard_budgets
(
  user_id VARCHAR(10) NOT NULL,
  big_category_id INT NOT NULL,
  budget INT NOT NULL DEFAULT 0,
  PRIMARY KEY(user_id, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE custom_budgets
(
  user_id VARCHAR(10) NOT NULL,
  years_months DATE NOT NULL,
  big_category_id INT NOT NULL,
  budget INT NOT NULL,
  PRIMARY KEY(user_id, years_months, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE group_custom_categories
(
  id INT NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(50) NOT NULL,
  big_category_id INT NOT NULL,
  group_id INT NOT NULL,
  PRIMARY KEY(id),
  UNIQUE uq_group_custom_category(category_name, big_category_id, group_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_group_id(group_id, id)
);

CREATE TABLE group_transactions
(
  id INT NOT NULL AUTO_INCREMENT,
  transaction_type ENUM('expense', 'income') NOT NULL,
  posted_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  transaction_date DATE NOT NULL,
  shop VARCHAR(20) DEFAULT NULL,
  memo VARCHAR(50) DEFAULT NULL,
  amount INT NOT NULL,
  group_id INT NOT NULL,
  posted_user_id VARCHAR(10) NOT NULL,
  updated_user_id VARCHAR(10) DEFAULT NULL,
  payment_user_id VARCHAR(10) NOT NULL,
  big_category_id INT NOT NULL,
  medium_category_id INT DEFAULT NULL,
  custom_category_id INT DEFAULT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_medium_category_id(medium_category_id)
    REFERENCES medium_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY fk_custom_category_id(custom_category_id)
    REFERENCES group_custom_categories(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_group_id(group_id)
);

CREATE TABLE group_standard_budgets
(
  group_id INT NOT NULL,
  big_category_id INT NOT NULL,
  budget INT NOT NULL DEFAULT 0,
  PRIMARY KEY(group_id, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE group_custom_budgets
(
  group_id INT NOT NULL,
  years_months DATE NOT NULL,
  big_category_id INT NOT NULL,
  budget INT NOT NULL,
  PRIMARY KEY(group_id, years_months, big_category_id),
  FOREIGN KEY fk_big_category_id(big_category_id)
    REFERENCES big_categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE group_accounts
(
  id INT NOT NULL AUTO_INCREMENT,
  years_months DATE NOT NULL,
  payer_user_id VARCHAR(10) DEFAULT NULL,
  recipient_user_id VARCHAR(10) DEFAULT NULL,
  payment_amount INT DEFAULT NULL,
  payment_confirmation bit(1) NOT NULL DEFAULT b'0',
  receipt_confirmation bit(1) NOT NULL DEFAULT b'0',
  group_id INT NOT NULL,
  PRIMARY KEY(id),
  UNIQUE uq_group_accounts(years_months, payer_user_id, recipient_user_id, group_id),
  INDEX idx_group_id(group_id)
);

-- big_categories table default data
INSERT INTO big_categories
  (id, category_name, transaction_type)
VALUES
  (1,  "収入", "income"),
  (2, "食費", "expense"),
  (3, "日用品", "expense"),
  (4, "趣味・娯楽", "expense"),
  (5, "交際費", "expense"),
  (6, "交通費", "expense"),
  (7, "衣服・美容", "expense"),
  (8, "健康・医療", "expense"),
  (9, "通信費", "expense"),
  (10, "教養・教育", "expense"),
  (11, "住宅", "expense"),
  (12, "水道・光熱費", "expense"),
  (13, "自動車", "expense"),
  (14, "保険", "expense"),
  (15, "税金・社会保険", "expense"),
  (16, "現金・カード", "expense"),
  (17, "その他", "expense");

-- medium_categories table default data
INSERT INTO medium_categories
  (id, category_name, big_category_id)
VALUES
  (1, "給与", 1),
  (2, "賞与", 1),
  (3, "一時所得", 1),
  (4, "事業所得", 1),
  (5, "その他収入", 1),
  (6, "食料品", 2),
  (7, "朝食", 2),
  (8, "昼食", 2),
  (9, "夕食", 2),
  (10, "外食", 2),
  (11, "カフェ", 2),
  (12, "その他食費", 2),
  (13, "消耗品", 3),
  (14, "子育て用品", 3),
  (15, "ペット用品", 3),
  (16, "家具", 3),
  (17, "家電", 3),
  (18, "その他日用品", 3),
  (19, "アウトドア", 4),
  (20, "旅行", 4),
  (21, "イベント", 4),
  (22, "スポーツ", 4),
  (23, "映画・動画", 4),
  (24, "音楽", 4),
  (25, "漫画", 4),
  (26, "書籍", 4),
  (27, "ゲーム", 4),
  (28, "その他趣味・娯楽", 4),
  (29, "飲み会", 5),
  (30, "プレゼント", 5),
  (31, "冠婚葬祭", 5),
  (32, "その他交際費", 5),
  (33, "電車", 6),
  (34, "バス", 6),
  (35, "タクシー", 6),
  (36, "新幹線", 6),
  (37, "飛行機", 6),
  (38, "その他交通費", 6),
  (39, "衣服", 7),
  (40, "アクセサリー", 7),
  (41, "クリーニング", 7),
  (42, "美容院・理髪", 7),
  (43, "化粧品", 7),
  (44, "エステ・ネイル", 7),
  (45, "その他衣服・美容", 7),
  (46, "病院", 8),
  (47, "薬", 8),
  (48, "ボディケア", 8),
  (49, "フィットネス", 8),
  (50, "その他健康・医療", 8),
  (51, "携帯電話", 9),
  (52, "固定電話", 9),
  (53, "インターネット", 9),
  (54, "放送サービス", 9),
  (55, "情報サービス", 9),
  (56, "宅配・運送", 9),
  (57, "切手・はがき", 9),
  (58, "その他通信費", 9),
  (59, "新聞", 10),
  (60, "参考書", 10),
  (61, "受験料", 10),
  (62, "学費", 10),
  (63, "習い事", 10),
  (64, "塾", 10),
  (65, "その他教養・教育", 10),
  (66, "家賃", 11),
  (67, "住宅ローン", 11),
  (68, "リフォーム", 11),
  (69, "その他住宅", 11),
  (70, "水道", 12),
  (71, "電気", 12),
  (72, "ガス", 12),
  (73, "その他水道・光熱費", 12),
  (74, "自動車ローン", 13),
  (75, "ガソリン", 13),
  (76, "駐車場", 13),
  (77, "高速料金", 13),
  (78, "車検・整備", 13),
  (79, "その他自動車", 13),
  (80, "生命保険", 14),
  (81, "医療保険", 14),
  (82, "自動車保険", 14),
  (83, "住宅保険", 14),
  (84, "学資保険", 14),
  (85, "その他保険", 14),
  (86, "所得税", 15),
  (87, "住民税", 15),
  (88, "年金保険料", 15),
  (89, "自動車税", 15),
  (90, "その他税金・社会保険", 15),
  (91, "現金引き出し", 16),
  (92, "カード引き落とし", 16),
  (93, "電子マネー", 16),
  (94, "立替金", 16),
  (95, "その他現金・カード", 16),
  (96, "仕送り", 17),
  (97, "お小遣い", 17),
  (98, "使途不明金", 17),
  (99, "雑費", 17);

CREATE DATABASE todo;
USE todo;

CREATE TABLE todo_list
(
  id INT NOT NULL AUTO_INCREMENT,
  posted_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  implementation_date DATE NOT NULL,
  due_date DATE NOT NULL,
  todo_content VARCHAR(100) NOT NULL,
  complete_flag bit(1) NOT NULL DEFAULT b'0',
  user_id VARCHAR(10) NOT NULL,
  PRIMARY KEY(id),
  INDEX idx_user_id(user_id)
);

CREATE TABLE regular_shopping_list
(
  id INT NOT NULL AUTO_INCREMENT,
  posted_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expected_purchase_date DATE NOT NULL,
  cycle_type ENUM('daily', 'weekly', 'monthly', 'custom') NOT NULL,
  cycle INT DEFAULT NULL,
  purchase VARCHAR(50) NOT NULL,
  shop VARCHAR(20) DEFAULT NULL,
  amount INT DEFAULT NULL,
  big_category_id INT NOT NULL,
  medium_category_id INT DEFAULT NULL,
  custom_category_id INT DEFAULT NULL,
  user_id VARCHAR(10) NOT NULL,
  transaction_auto_add bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY(id)
);

CREATE TABLE shopping_list
(
  id INT NOT NULL AUTO_INCREMENT,
  posted_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expected_purchase_date DATE NOT NULL,
  complete_flag bit(1) NOT NULL DEFAULT b'0',
  purchase VARCHAR(50) NOT NULL,
  shop VARCHAR(20) DEFAULT NULL,
  amount INT DEFAULT NULL,
  big_category_id INT NOT NULL,
  medium_category_id INT DEFAULT NULL,
  custom_category_id INT DEFAULT NULL,
  regular_shopping_list_id INT DEFAULT NULL,
  user_id VARCHAR(10) NOT NULL,
  transaction_auto_add bit(1) NOT NULL DEFAULT b'0',
  transaction_id INT DEFAULT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY fk_shopping_list_id(regular_shopping_list_id)
    REFERENCES regular_shopping_list(id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE group_todo_list
(
  id INT NOT NULL AUTO_INCREMENT,
  posted_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  implementation_date DATE NOT NULL,
  due_date DATE NOT NULL,
  todo_content VARCHAR(100) NOT NULL,
  complete_flag bit(1) NOT NULL DEFAULT b'0',
  user_id VARCHAR(10) NOT NULL,
  group_id INT NOT NULL,
  PRIMARY KEY(id),
  INDEX idx_group_id(group_id)
);

CREATE TABLE group_regular_shopping_list
(
  id INT NOT NULL AUTO_INCREMENT,
  posted_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expected_purchase_date DATE NOT NULL,
  cycle_type ENUM('daily', 'weekly', 'monthly', 'custom') NOT NULL,
  cycle INT DEFAULT NULL,
  purchase VARCHAR(50) NOT NULL,
  shop VARCHAR(20) DEFAULT NULL,
  amount INT DEFAULT NULL,
  big_category_id INT NOT NULL,
  medium_category_id INT DEFAULT NULL,
  custom_category_id INT DEFAULT NULL,
  payment_user_id VARCHAR(10) DEFAULT NULL,
  group_id INT NOT NULL,
  transaction_auto_add bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY(id)
);

CREATE TABLE group_shopping_list
(
  id INT NOT NULL AUTO_INCREMENT,
  posted_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expected_purchase_date DATE NOT NULL,
  complete_flag bit(1) NOT NULL DEFAULT b'0',
  purchase VARCHAR(50) NOT NULL,
  shop VARCHAR(20) DEFAULT NULL,
  amount INT DEFAULT NULL,
  big_category_id INT NOT NULL,
  medium_category_id INT DEFAULT NULL,
  custom_category_id INT DEFAULT NULL,
  regular_shopping_list_id INT DEFAULT NULL,
  payment_user_id VARCHAR(10) DEFAULT NULL,
  group_id INT NOT NULL,
  transaction_auto_add bit(1) NOT NULL DEFAULT b'0',
  transaction_id INT DEFAULT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY fk_group_shopping_list_id(regular_shopping_list_id)
    REFERENCES group_regular_shopping_list(id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE group_tasks_users
(
  id INT NOT NULL AUTO_INCREMENT,
  user_id VARCHAR(10) NOT NULL,
  group_id INT NOT NULL,
  PRIMARY KEY(id),
  UNIQUE uq_group_tasks_users(user_id, group_id),
  INDEX idx_group_id(group_id)
);

CREATE TABLE group_tasks
(
  id INT NOT NULL AUTO_INCREMENT,
  base_date DATETIME DEFAULT NULL,
  cycle_type ENUM('every', 'consecutive', 'none') DEFAULT NULL,
  cycle INT DEFAULT NULL,
  task_name VARCHAR(20) NOT NULL,
  group_id INT NOT NULL,
  group_tasks_users_id INT DEFAULT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY fk_group_tasks_users_id(group_tasks_users_id)
    REFERENCES group_tasks_users(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_group_id(group_id)
);

USE user;

-- users table init data
INSERT INTO users
  (user_id, name, email, password)
VALUES
  ('gohiromi', '郷ひろみ', 'kakeibo@gmail.com', '$2a$10$t2mJ8/chozn4QjVEF4RLy.HkPZUqi3snAvJbRCUTWenkEPlfyFuWi'),
  ('tati', '舘ひろし', 'tati@gmail.com', '$2a$10$t2mJ8/chozn4QjVEF4RLy.HkPZUqi3snAvJbRCUTWenkEPlfyFuWi'),
  ('tendo', '天童よしみ', 'tendo@gmail.com', '$2a$10$t2mJ8/chozn4QjVEF4RLy.HkPZUqi3snAvJbRCUTWenkEPlfyFuWi'),
  ('saigo', '西郷隆盛', 'saigo@gmail.com', '$2a$10$t2mJ8/chozn4QjVEF4RLy.HkPZUqi3snAvJbRCUTWenkEPlfyFuWi');

-- group_users table init data
INSERT INTO group_names
  (group_name)
VALUES
  ('テラスハウス');

-- group_users table init data
INSERT INTO group_users
  (group_id, user_id, color_code)
VALUES
  (1, 'gohiromi', '#FF0000'),
  (1, 'tati', '#00FFFF'),
  (1, 'tendo', '#80FF00');

-- group_unapproved_users table init data
INSERT INTO group_unapproved_users
  (group_id, user_id)
VALUES
  (1, 'saigo');

USE account;

-- standard_budgets table init data
INSERT INTO standard_budgets
  (user_id, big_category_id)
VALUES
  ('gohiromi', 2),
  ('gohiromi', 3),
  ('gohiromi', 4),
  ('gohiromi', 5),
  ('gohiromi', 6),
  ('gohiromi', 7),
  ('gohiromi', 8),
  ('gohiromi', 9),
  ('gohiromi', 10),
  ('gohiromi', 11),
  ('gohiromi', 12),
  ('gohiromi', 13),
  ('gohiromi', 14),
  ('gohiromi', 15),
  ('gohiromi', 16),
  ('gohiromi', 17),
  ('tati', 2),
  ('tati', 3),
  ('tati', 4),
  ('tati', 5),
  ('tati', 6),
  ('tati', 7),
  ('tati', 8),
  ('tati', 9),
  ('tati', 10),
  ('tati', 11),
  ('tati', 12),
  ('tati', 13),
  ('tati', 14),
  ('tati', 15),
  ('tati', 16),
  ('tati', 17),
  ('tendo', 2),
  ('tendo', 3),
  ('tendo', 4),
  ('tendo', 5),
  ('tendo', 6),
  ('tendo', 7),
  ('tendo', 8),
  ('tendo', 9),
  ('tendo', 10),
  ('tendo', 11),
  ('tendo', 12),
  ('tendo', 13),
  ('tendo', 14),
  ('tendo', 15),
  ('tendo', 16),
  ('tendo', 17),
  ('saigo', 2),
  ('saigo', 3),
  ('saigo', 4),
  ('saigo', 5),
  ('saigo', 6),
  ('saigo', 7),
  ('saigo', 8),
  ('saigo', 9),
  ('saigo', 10),
  ('saigo', 11),
  ('saigo', 12),
  ('saigo', 13),
  ('saigo', 14),
  ('saigo', 15),
  ('saigo', 16),
  ('saigo', 17);

-- group_standard_budgets table init data
INSERT INTO group_standard_budgets
  (group_id, big_category_id)
VALUES
  (1, 2),
  (1, 3),
  (1, 4),
  (1, 5),
  (1, 6),
  (1, 7),
  (1, 8),
  (1, 9),
  (1, 10),
  (1, 11),
  (1, 12),
  (1, 13),
  (1, 14),
  (1, 15),
  (1, 16),
  (1, 17);
