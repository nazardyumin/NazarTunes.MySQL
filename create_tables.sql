DROP TABLE table_record_genre_items;
DROP TABLE table_record_performer_items;
DROP TABLE table_records;
DROP TABLE table_publishers;
DROP TABLE table_genres;
DROP TABLE table_bands;
DROP TABLE table_performers;
DROP TABLE table_persons;

CREATE TABLE table_persons
(
    person_id  INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL
);

CREATE TABLE table_performers
(
    performer_id       INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    person_id          INT NOT NULL,
    wiki_link          VARCHAR(255),
    total_records_sold INT,
    FOREIGN KEY (person_id) REFERENCES table_persons (person_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE table_bands
(
    band_id            INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    band_name          VARCHAR(255) NOT NULL,
    wiki_link          VARCHAR(255),
    total_records_sold INT
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

CREATE TABLE table_records
(
    record_id    INT          NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title        VARCHAR(255) NOT NULL,
    track_amount INT          NOT NULL,
    publisher_id INT          NOT NULL,
    release_date DATE         NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES table_publishers (publisher_id)
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