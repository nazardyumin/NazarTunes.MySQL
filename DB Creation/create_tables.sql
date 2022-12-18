DROP TABLE table_order_items;
DROP TABLE table_all_sales;
DROP TABLE table_orders;
DROP TABLE table_tracks;
DROP TABLE table_record_genre_items;
DROP TABLE table_record_performer_items;
DROP TABLE table_frozen_nomenclatures;
DROP TABLE table_nomenclatures;
DROP TABLE table_amounts_of_all_procurements;
DROP TABLE table_procurements;
DROP TABLE table_discount_promotions;
DROP TABLE table_records;
DROP TABLE table_suppliers;
DROP TABLE table_media_formats;
DROP TABLE table_publishers;
DROP TABLE table_genres;
DROP TABLE table_bands;
DROP TABLE table_performers;
DROP TABLE table_clients;
DROP TABLE table_admins;
DROP TABLE table_persons;
DROP TABLE table_credentials;
DROP TABLE table_roles;


-- tables for records

CREATE TABLE table_persons
(
    person_id    INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    is_performer BOOL DEFAULT FALSE
);

CREATE TABLE table_performers
(
    performer_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    person_id    INT NOT NULL,
    wiki_link    VARCHAR(255) DEFAULT '',
    FOREIGN KEY (person_id) REFERENCES table_persons (person_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_bands
(
    band_id   INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    band_name VARCHAR(255) NOT NULL,
    wiki_link VARCHAR(255) DEFAULT ''
);

CREATE TABLE table_genres
(
    genre_id   INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(100) NOT NULL
);

CREATE TABLE table_publishers
(
    publisher_id INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    publisher    VARCHAR(100) NOT NULL
);

CREATE TABLE table_media_formats
(
    media_format_id INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    media_format    VARCHAR(50) NOT NULL
);

CREATE TABLE table_records
(
    record_id       INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title           VARCHAR(255) NOT NULL,
    total_duration  TIME         NOT NULL,
    publisher_id    INT          NOT NULL,
    release_year    CHAR(4)      NOT NULL,
    media_format_id INT          NOT NULL,
    cover_path      VARCHAR(255) DEFAULT '',
    FOREIGN KEY (publisher_id) REFERENCES table_publishers (publisher_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (media_format_id) REFERENCES table_media_formats (media_format_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_record_performer_items
(
    record_performer_item_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id                INT,
    performer_id             INT,
    band_id                  INT,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (performer_id) REFERENCES table_performers (performer_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (band_id) REFERENCES table_bands (band_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_record_genre_items
(
    record_genre_item_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id            INT,
    genre_id             INT,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (genre_id) REFERENCES table_genres (genre_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_tracks
(
    track_id    INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id   INT,
    track_title VARCHAR(255) NOT NULL,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- tables for users

CREATE TABLE table_roles
(
    role_id   INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(10) NOT NULL
);

CREATE TABLE table_credentials
(
    credential_id INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    login         VARCHAR(50) NOT NULL,
    pass          VARCHAR(50) NOT NULL,
    role_id       INT         NOT NULL,
    is_deleted    BOOL DEFAULT FALSE,
    FOREIGN KEY (role_id) REFERENCES table_roles (role_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_clients
(
    client_id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    credential_id      INT NOT NULL,
    person_id          INT NOT NULL,
    phone              VARCHAR(20)  DEFAULT '',
    email              VARCHAR(100) DEFAULT '',
    total_amount_spent DOUBLE       DEFAULT 0.0,
    personal_discount  INT          DEFAULT 0,
    is_subscribed      BOOL         DEFAULT FALSE,
    has_frozen_items   BOOL         DEFAULT FALSE,
    FOREIGN KEY (credential_id) REFERENCES table_credentials (credential_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (person_id) REFERENCES table_persons (person_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_admins
(
    admin_id      INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    credential_id INT NOT NULL,
    person_id     INT NOT NULL,
    FOREIGN KEY (credential_id) REFERENCES table_credentials (credential_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (person_id) REFERENCES table_persons (person_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- tables for sales

CREATE TABLE table_suppliers
(
    supplier_id    INT  NOT NULL PRIMARY KEY AUTO_INCREMENT,
    supplier_name  TEXT NOT NULL,
    contact_info   TEXT NOT NULL,
    is_cooperating BOOL DEFAULT TRUE
);

CREATE TABLE table_procurements
(
    procurement_id      INT           NOT NULL PRIMARY KEY AUTO_INCREMENT,
    date_of_procurement DATE          NOT NULL,
    supplier_id         INT           NOT NULL,
    record_id           INT           NOT NULL,
    amount              INT           NOT NULL,
    cost_price          DECIMAL(8, 2) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES table_suppliers (supplier_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_amounts_of_all_procurements
(
    amount_of_all_procurements_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id                     INT NOT NULL,
    procurement_id                INT NOT NULL,
    amount                        INT NOT NULL,
    defective_amount              INT DEFAULT 0,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (procurement_id) REFERENCES table_procurements (procurement_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_nomenclatures
(
    nomenclature_id        INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id              INT NOT NULL,
    total_amount           INT           DEFAULT 0,
    sell_price             DECIMAL(8, 2) DEFAULT 0.0,
    total_items_sold       INT           DEFAULT 0,
    total_items_frozen     INT           DEFAULT 0,
    is_available           BOOL          DEFAULT FALSE,
    promotion_by_genre     BOOL          DEFAULT FALSE,
    promotion_by_record    BOOL          DEFAULT FALSE,
    promotion_by_band      BOOL          DEFAULT FALSE,
    promotion_by_performer BOOL          DEFAULT FALSE,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_frozen_nomenclatures
(
    frozen_nomenclature_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nomenclature_id        INT NOT NULL,
    client_id              INT NOT NULL,
    amount                 INT NOT NULL,
    FOREIGN KEY (nomenclature_id) REFERENCES table_nomenclatures (nomenclature_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (client_id) REFERENCES table_clients (client_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_discount_promotions
(
    discount_promotion_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    genre_id              INT,
    record_id             INT,
    performer_id          INT,
    band_id               INT,
    discount              INT NOT NULL,
    is_started            BOOL DEFAULT FALSE,
    is_finished           BOOL DEFAULT FALSE,
    start_date            DATE,
    end_date              DATE,
    FOREIGN KEY (genre_id) REFERENCES table_genres (genre_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (performer_id) REFERENCES table_performers (performer_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (band_id) REFERENCES table_bands (band_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_orders
(
    order_id               INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    client_id              INT NOT NULL,
    datetime_of_order      DATETIME,
    total_items            INT           DEFAULT 0,
    total_price            DECIMAL(8, 2) DEFAULT 0.0,
    discount               INT           DEFAULT 0,
    is_confirmed           BOOL          DEFAULT FALSE,
    discount_is_considered BOOL          DEFAULT FALSE,
    is_paid                BOOL          DEFAULT FALSE,
    is_refunded            BOOL          DEFAULT FALSE,
    FOREIGN KEY (client_id) REFERENCES table_clients (client_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_order_items
(
    order_item_id   INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    order_id        INT NOT NULL,
    nomenclature_id INT NOT NULL,
    amount          INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES table_orders (order_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (nomenclature_id) REFERENCES table_nomenclatures (nomenclature_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_all_sales
(
    sale_id  INT    NOT NULL PRIMARY KEY AUTO_INCREMENT,
    order_id INT    NOT NULL,
    profit   DOUBLE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES table_orders (order_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- triggers

DELIMITER |
CREATE TRIGGER trigger_create_nomenclature_after_creating_record
    AFTER INSERT
    ON table_records
    FOR EACH ROW
BEGIN
    INSERT INTO table_nomenclatures (record_id) VALUE (NEW.record_id);
END |


DELIMITER |
CREATE TRIGGER trigger_update_nomenclature_amount_after_adding_procurement
    AFTER INSERT
    ON table_procurements
    FOR EACH ROW
BEGIN
    DECLARE old_amount INT DEFAULT 0;
    DECLARE new_amount INT DEFAULT 0;
    INSERT INTO table_amounts_of_all_procurements (record_id, procurement_id, amount)
    VALUES (NEW.record_id, NEW.procurement_id, NEW.amount);
    SELECT function_get_nomenclature_total_amount(NEW.record_id) INTO old_amount;
    SELECT old_amount + NEW.amount INTO new_amount;
    UPDATE table_nomenclatures
    SET total_amount = new_amount
    WHERE record_id = NEW.record_id;
    CALL procedure_make_nomenclature_available_or_unavailable(NEW.record_id);
END |


DELIMITER |
CREATE TRIGGER trigger_set_promotional_price_if_promotion_by_genre_started
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF NEW.genre_id > 0 AND NEW.is_started AND !NEW.is_finished THEN
        CALL procedure_set_promotional_price_by_genre(NEW.genre_id, NEW.discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_return_normal_price_if_promotion_by_genre_finished
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF NEW.genre_id > 0 AND NEW.is_started AND NEW.is_finished THEN
        CALL procedure_return_normal_price_by_genre(NEW.genre_id, NEW.discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_set_promotional_price_if_promotion_by_band_started
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF NEW.band_id > 0 AND NEW.is_started AND !NEW.is_finished THEN
        CALL procedure_set_promotional_price_by_band(NEW.band_id, NEW.discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_return_normal_price_if_promotion_by_band_finished
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF NEW.band_id > 0 AND NEW.is_started AND NEW.is_finished THEN
        CALL procedure_return_normal_price_by_band(NEW.band_id, NEW.discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_set_promotional_price_if_promotion_by_performer_started
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF NEW.performer_id > 0 AND NEW.is_started AND !NEW.is_finished THEN
        CALL procedure_set_promotional_price_by_performer(NEW.performer_id, NEW.discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_return_normal_price_if_promotion_by_performer_finished
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF NEW.performer_id > 0 AND NEW.is_started AND NEW.is_finished THEN
        CALL procedure_return_normal_price_by_performer(NEW.performer_id, NEW.discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_set_promotional_price_if_promotion_by_record_started
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF NEW.record_id > 0 AND NEW.is_started AND !NEW.is_finished THEN
        CALL procedure_set_promotional_price_by_record(NEW.record_id, NEW.discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_return_normal_price_if_promotion_by_record_finished
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF NEW.record_id > 0 AND NEW.is_started AND NEW.is_finished THEN
        CALL procedure_return_normal_price_by_record(NEW.record_id, NEW.discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_refresh_nomenclature_amount_after_adding_new_frozen_item
    AFTER INSERT
    ON table_frozen_nomenclatures
    FOR EACH ROW
BEGIN
    UPDATE table_nomenclatures
    SET total_amount       = function_get_nomenclature_total_amount(NEW.nomenclature_id) - NEW.amount,
        total_items_frozen = function_get_nomenclature_frozen_amount(NEW.nomenclature_id) + NEW.amount
    WHERE nomenclature_id = NEW.nomenclature_id;
    CALL procedure_make_nomenclature_available_or_unavailable(NEW.nomenclature_id);
    UPDATE table_clients SET has_frozen_items = TRUE WHERE client_id = NEW.client_id;
END |



