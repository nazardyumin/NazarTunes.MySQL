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