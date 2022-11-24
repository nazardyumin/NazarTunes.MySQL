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
                          WHERE genre_name = new_genre);
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
    SELECT genre_id INTO id FROM table_genres WHERE genre_name = new_genre;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_insert_genre_and_get_id(new_genre VARCHAR(100))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    INSERT INTO table_genres (genre_name) VALUE (new_genre);
    SELECT MAX(genre_id) INTO id FROM table_genres;
    RETURN id;
END |























DELIMITER |
CREATE PROCEDURE procedure_get_record_genres(IN id_record INT)
BEGIN
    SELECT genre_name
    FROM table_genres
             JOIN table_record_genre_items
                  ON table_genres.genre_id = table_record_genre_items.genre_id
    WHERE record_id = id_record
      AND is_deleted = FALSE;
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
CREATE PROCEDURE procedure_get_all_genres()
BEGIN
    SELECT * FROM table_genres;
END|











DELIMITER |
CREATE PROCEDURE procedure_update_genre(IN id INT, IN new_genre_name VARCHAR(100))
BEGIN
    UPDATE table_genres SET genre_name = new_genre_name WHERE genre_id = id;
END|







DELIMITER |
CREATE PROCEDURE procedure_delete_record_genre_item(IN id_record INT, IN not_actual_genre VARCHAR(100))
BEGIN
    SET @id_genre := function_get_genre_id(not_actual_genre);
    UPDATE table_record_genre_items
    SET is_deleted = TRUE
    WHERE record_id = id_record
      AND genre_id = @id_genre;
END |











-- UNDONE!!!
DELIMITER |
CREATE PROCEDURE procedure_update_record(IN new_title varchar(255),
                                         IN new_total_duration time,
                                         IN new_publisher varchar(100),
                                         IN new_release_date char(4),
                                         IN new_media_format varchar(50),
                                         OUT new_record_id int)
BEGIN
    INSERT INTO table_records (title, total_duration, publisher_id, release_year, media_format_id)
    VALUES (new_title, new_total_duration,
            function_check_if_publisher_exists_and_get_id(new_publisher), new_release_date,
            function_check_if_media_format_exists_and_get_id(new_media_format));
    SELECT MAX(record_id) INTO new_record_id FROM table_records;
END |
