DROP TABLE table_tracks;
DROP TABLE table_record_genre_items;
DROP TABLE table_record_performer_items;
DROP TABLE table_nomenclatures;
DROP TABLE table_nomenclature_item_amounts;
DROP TABLE table_procurements;
DROP TABLE table_records;
DROP TABLE table_suppliers;
DROP TABLE table_record_types;
DROP TABLE table_publishers;
DROP TABLE table_genres;
DROP TABLE table_bands;
DROP TABLE table_performers;
DROP TABLE table_persons;


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
    cover_path     VARCHAR(255) NOT NULL,
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

CREATE TABLE table_nomenclature_item_amounts
(
    nomenclature_item_amount_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id                   INT NOT NULL,
    procurement_id              INT NOT NULL,
    amount                      INT NOT NULL,
    profit                      DOUBLE,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (procurement_id) REFERENCES table_procurements (procurement_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE table_nomenclatures
(
    nomenclature_id             INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    record_id                   INT NOT NULL,
    nomenclature_item_amount_id INT NOT NULL,
    defective_amount            INT  DEFAULT 0,
    sell_price                  DOUBLE NOT NULL,
    total_items_sold            INT  DEFAULT 0,
    is_available                BOOL DEFAULT FALSE,
    is_sold_out                 BOOL DEFAULT FALSE,
    FOREIGN KEY (record_id) REFERENCES table_records (record_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (nomenclature_item_amount_id) REFERENCES table_nomenclature_item_amounts (nomenclature_item_amount_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);


