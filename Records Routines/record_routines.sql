DELIMITER |
CREATE FUNCTION function_check_if_publisher_exists_and_get_id(new_publisher VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SET @exists := EXISTS(SELECT publisher_id
                          FROM table_publishers
                          WHERE publisher = new_publisher);
    IF @exists THEN
        SELECT function_get_publisher_id(new_publisher) INTO id;
        RETURN id;
    ELSE
        SELECT function_insert_publisher_and_get_id(new_publisher) INTO id;
        RETURN id;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_get_publisher_id(new_publisher VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT publisher_id INTO id FROM table_publishers WHERE publisher = new_publisher;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_insert_publisher_and_get_id(new_publisher VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    INSERT INTO table_publishers (publisher) VALUE (new_publisher);
    SELECT MAX(publisher_id) INTO id FROM table_publishers;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_check_if_media_format_exists_and_get_id(new_media_format VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SET @exists := EXISTS(SELECT media_format_id
                          FROM table_media_formats
                          WHERE media_format = new_media_format);
    IF @exists THEN
        SELECT function_get_media_format_id(new_media_format) INTO id;
        RETURN id;
    ELSE
        SELECT function_insert_media_format_and_get_id(new_media_format) INTO id;
        RETURN id;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_get_media_format_id(new_media_format VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT media_format_id INTO id FROM table_media_formats WHERE media_format = new_media_format;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_insert_media_format_and_get_id(new_media_format VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    INSERT INTO table_media_formats (media_format) VALUE (new_media_format);
    SELECT MAX(media_format_id) INTO id FROM table_media_formats;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_check_if_genre_exists_and_get_id(new_genre VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SET @exists := EXISTS(SELECT genre_id
                          FROM table_genres
                          WHERE genre = new_genre);
    IF @exists THEN
        SELECT function_get_genre_id(new_genre) INTO id;
        RETURN id;
    ELSE
        SELECT function_insert_genre_and_get_id(new_genre) INTO id;
        RETURN id;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_get_genre_id(new_genre VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT genre_id INTO id FROM table_genres WHERE genre = new_genre;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_insert_genre_and_get_id(new_genre VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    INSERT INTO table_genres (genre) VALUE (new_genre);
    SELECT MAX(genre_id) INTO id FROM table_genres;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_check_if_person_as_performer_exists(new_first_name VARCHAR(100), new_last_name VARCHAR(100))
    RETURNS BOOL
    DETERMINISTIC
BEGIN
    SET @exists := EXISTS(SELECT person_id
                          FROM table_persons
                          WHERE first_name = new_first_name
                            AND last_name = new_last_name
                            AND is_performer = TRUE);
    IF @exists THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_get_person_as_performer_id(new_first_name VARCHAR(100), new_last_name VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT person_id
    INTO id
    FROM table_persons
    WHERE first_name = new_first_name
      AND last_name = new_last_name
      AND is_performer = TRUE;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_insert_person_as_performer_and_get_id(new_first_name VARCHAR(100), new_last_name VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    INSERT INTO table_persons (first_name, last_name, is_performer) VALUES (new_first_name, new_last_name, TRUE);
    SELECT MAX(person_id) INTO id FROM table_persons;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_check_if_performer_exists_and_get_id(new_first_name VARCHAR(100), new_last_name VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id_person INT;
    DECLARE id_performer INT;
    SET @exists := function_check_if_person_as_performer_exists(new_first_name, new_last_name);
    IF @exists THEN
        SELECT function_get_person_as_performer_id(new_first_name, new_last_name) INTO id_person;
        SELECT function_get_performer_id(id_person) INTO id_performer;
        RETURN id_performer;
    ELSE
        SELECT function_insert_person_as_performer_and_get_id(new_first_name, new_last_name) INTO id_person;
        SELECT function_insert_performer_and_get_id(id_person) INTO id_performer;
        RETURN id_performer;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_get_performer_id(new_person_id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT performer_id
    INTO id
    FROM table_performers
    WHERE person_id = new_person_id;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_insert_performer_and_get_id(new_person_id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    INSERT INTO table_performers (person_id) VALUE (new_person_id);
    SELECT MAX(performer_id) INTO id FROM table_performers;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_check_if_band_exists_and_get_id(new_band_name VARCHAR(255))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SET @exists := EXISTS(SELECT band_id
                          FROM table_bands
                          WHERE band_name = new_band_name);
    IF @exists THEN
        SELECT function_get_band_id(new_band_name) INTO id;
        RETURN id;
    ELSE
        SELECT function_insert_band_and_get_id(new_band_name) INTO id;
        RETURN id;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_get_band_id(new_band_name VARCHAR(255))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT band_id
    INTO id
    FROM table_bands
    WHERE band_name = new_band_name;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_insert_band_and_get_id(new_band_name VARCHAR(255))
    RETURNS BOOL
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    INSERT INTO table_bands (band_name) VALUE (new_band_name);
    SELECT MAX(band_id) INTO id FROM table_bands;
    RETURN id;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_record_genres(IN id_record INT)
BEGIN
    SELECT genre
    FROM table_genres
             JOIN table_record_genre_items
                  ON table_genres.genre_id = table_record_genre_items.genre_id
    WHERE record_id = id_record;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_record_performers_persons(IN id_record INT)
BEGIN
    SELECT first_name, last_name
    FROM table_persons
             JOIN table_performers ON table_persons.person_id = table_performers.person_id
             JOIN table_record_performer_items
                  ON table_performers.performer_id = table_record_performer_items.performer_id
    WHERE record_id = id_record;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_record_performers_bands(IN id_record INT)
BEGIN
    SELECT band_name
    FROM table_bands
             JOIN table_record_performer_items
                  ON table_bands.band_id = table_record_performer_items.band_id
    WHERE record_id = id_record;
END |


DELIMITER |
CREATE FUNCTION function_get_record_publisher(id_record INT)
    RETURNS VARCHAR(100)
    DETERMINISTIC
BEGIN
    DECLARE record_publisher VARCHAR(100);
    SELECT publisher
    INTO record_publisher
    FROM table_publishers
             JOIN table_records ON table_publishers.publisher_id = table_records.publisher_id
    WHERE record_id = id_record;
    RETURN record_publisher;
END |


DELIMITER |
CREATE FUNCTION function_get_record_media_format(id_record INT)
    RETURNS VARCHAR(50)
    DETERMINISTIC
BEGIN
    DECLARE media VARCHAR(50);
    SELECT media_format
    INTO media
    FROM table_media_formats
             JOIN table_records ON table_media_formats.media_format_id = table_records.media_format_id
    WHERE record_id = id_record;
    RETURN media;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_record_tracks(IN id_record INT)
BEGIN
    SELECT track_title FROM table_tracks WHERE record_id = id_record;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_record(IN id_record INT,
                                      OUT rec_title VARCHAR(255),
                                      OUT rec_total_duration TIME,
                                      OUT rec_publisher VARCHAR(100),
                                      OUT rec_release_year CHAR(4),
                                      OUT rec_media_format VARCHAR(50),
                                      OUT rec_cover_path VARCHAR(255))
BEGIN
    SELECT title INTO rec_title FROM table_records WHERE record_id = id_record;
    SELECT total_duration INTO rec_total_duration FROM table_records WHERE record_id = id_record;
    SELECT function_get_record_publisher(id_record) INTO rec_publisher;
    SELECT release_year INTO rec_release_year FROM table_records WHERE record_id = id_record;
    SELECT function_get_record_media_format(id_record) INTO rec_media_format;
    SELECT cover_path INTO rec_cover_path FROM table_records WHERE record_id = id_record;
END |


DELIMITER |
CREATE FUNCTION function_get_all_record_ids()
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE records_count INT;
    SELECT MAX(record_id) INTO records_count FROM table_records;
    RETURN records_count;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_record_and_get_id(IN new_title VARCHAR(255),
                                                    IN new_total_duration TIME, IN new_publisher VARCHAR(100),
                                                    IN new_release_date CHAR(4),
                                                    IN new_media_format VARCHAR(50), OUT new_record_id INT)
BEGIN
    INSERT INTO table_records (title, total_duration, publisher_id, release_year, media_format_id)
    VALUES (new_title, new_total_duration,
            function_check_if_publisher_exists_and_get_id(new_publisher), new_release_date,
            function_check_if_media_format_exists_and_get_id(new_media_format));
    SELECT MAX(record_id) INTO new_record_id FROM table_records;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_record_genre_item(IN new_record_id INT, IN new_genre VARCHAR(50))
BEGIN
    INSERT INTO table_record_genre_items (record_id, genre_id)
    VALUES (new_record_id, function_check_if_genre_exists_and_get_id(new_genre));
END |


DELIMITER |
CREATE PROCEDURE procedure_create_record_performer_item_with_performer(IN new_record_id INT,
                                                                       new_first_name VARCHAR(100),
                                                                       new_last_name VARCHAR(100))
BEGIN
    SET @id_performer := function_check_if_performer_exists_and_get_id(new_first_name, new_last_name);
    SET @exists := EXISTS(SELECT record_performer_item_id
                          FROM table_record_performer_items
                          WHERE record_id = new_record_id
                            AND performer_id = @id_performer);

    IF !@exists THEN
        INSERT INTO table_record_performer_items (record_id, performer_id)
        VALUES (new_record_id, @id_performer);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_record_performer_item_with_band(IN new_record_id INT, IN new_band_name VARCHAR(255))
BEGIN
    SET @id_band := function_check_if_band_exists_and_get_id(new_band_name);
    SET @exists := EXISTS(SELECT record_performer_item_id
                          FROM table_record_performer_items
                          WHERE record_id = new_record_id
                            AND band_id = @id_band);
    IF !@exists THEN
        INSERT INTO table_record_performer_items (record_id, band_id)
        VALUES (new_record_id, @id_band);
    END IF;
END |