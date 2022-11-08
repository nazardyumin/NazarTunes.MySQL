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
DROP TABLE table_record_types;
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
    person_id  INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL
);

CREATE TABLE table_performers
(
    performer_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    person_id    INT NOT NULL,
    wiki_link    VARCHAR(255),
    FOREIGN KEY (person_id) REFERENCES table_persons (person_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_bands
(
    band_id   INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    band_name VARCHAR(255) NOT NULL,
    wiki_link VARCHAR(255)
);

CREATE TABLE table_genres
(
    genre_id INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    genre    VARCHAR(100) NOT NULL
);

CREATE TABLE table_publishers
(
    publisher_id INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    publisher    VARCHAR(100) NOT NULL
);

CREATE TABLE table_record_types -- CD/DVD/Vinyl/LP/EP etc.
(
    record_type_id INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    type           VARCHAR(50) NOT NULL
);

CREATE TABLE table_records
(
    record_id      INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title          VARCHAR(255) NOT NULL,
    track_amount   INT          NOT NULL,
    total_duration TIME         NOT NULL,
    publisher_id   INT          NOT NULL,
    release_date   DATE         NOT NULL,
    type_id        INT          NOT NULL,
    cover_path     VARCHAR(255),
    FOREIGN KEY (publisher_id) REFERENCES table_publishers (publisher_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (type_id) REFERENCES table_record_types (record_type_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_record_performer_items
(
    record_performer_item_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id                INT NOT NULL,
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
    record_id            INT NOT NULL,
    genre_id             INT NOT NULL,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (genre_id) REFERENCES table_genres (genre_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_tracks
(
    track_id    INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id   INT          NOT NULL,
    track_title VARCHAR(255) NOT NULL,
    duration    TIME         NOT NULL,
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
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE table_clients
(
    client_id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    person_id          INT NOT NULL,
    phone              VARCHAR(20),
    email              VARCHAR(100),
    total_amount_spent DOUBLE,
    personal_discount  INT,
    is_subscribed      BOOL DEFAULT FALSE,
    FOREIGN KEY (client_id) REFERENCES table_credentials (credential_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (person_id) REFERENCES table_persons (person_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE table_admins
(
    admin_id  INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    person_id INT NOT NULL,
    FOREIGN KEY (admin_id) REFERENCES table_credentials (credential_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (person_id) REFERENCES table_persons (person_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);


-- tables for sales

CREATE TABLE table_suppliers
(
    supplier_id    INT  NOT NULL PRIMARY KEY AUTO_INCREMENT,
    supplier       TEXT NOT NULL,
    contact_info   TEXT NOT NULL,
    is_cooperating BOOL DEFAULT TRUE
);

CREATE TABLE table_procurements
(
    procurement_id      INT    NOT NULL PRIMARY KEY AUTO_INCREMENT,
    date_of_procurement DATE   NOT NULL,
    supplier_id         INT    NOT NULL,
    record_id           INT    NOT NULL,
    amount              INT    NOT NULL,
    cost_price          DOUBLE NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES table_suppliers (supplier_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE table_amounts_of_all_procurements
(
    amount_of_all_procurements_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id                     INT NOT NULL,
    procurement_id                INT NOT NULL,
    amount                        INT NOT NULL,
    profit                        DOUBLE,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (procurement_id) REFERENCES table_procurements (procurement_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE table_nomenclatures
(
    nomenclature_id  INT    NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id        INT    NOT NULL,
    total_amount     INT  DEFAULT 0,
    defective_amount INT  DEFAULT 0,
    sell_price       DOUBLE NOT NULL,
    total_items_sold INT  DEFAULT 0,
    is_available     BOOL DEFAULT FALSE,
    is_sold_out      BOOL DEFAULT FALSE,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE table_frozen_nomenclatures
(
    frozen_nomenclature_id INT  NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nomenclature_id        INT  NOT NULL,
    client_id              INT  NOT NULL,
    amount                 INT  NOT NULL,
    freeze_till_date       DATE NOT NULL,
    FOREIGN KEY (nomenclature_id) REFERENCES table_nomenclatures (nomenclature_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (client_id) REFERENCES table_clients (client_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE table_discount_promotions
(
    discount_promotion_id INT  NOT NULL PRIMARY KEY AUTO_INCREMENT,
    genre_id              INT,
    record_id             INT,
    performer_id          INT,
    band_id               INT,
    discount              INT  NOT NULL,
    end_date              DATE NOT NULL,
    FOREIGN KEY (genre_id) REFERENCES table_genres (genre_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (performer_id) REFERENCES table_performers (performer_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    FOREIGN KEY (band_id) REFERENCES table_bands (band_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);