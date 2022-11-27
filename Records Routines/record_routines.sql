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
                                                    IN new_total_duration TIME,
                                                    IN new_publisher VARCHAR(100),
                                                    IN new_release_date CHAR(4),
                                                    IN new_media_format VARCHAR(50),
                                                    IN new_cover_path varchar(255),
                                                    OUT new_record_id INT)
BEGIN
    INSERT INTO table_records (title, total_duration, publisher_id, release_year, media_format_id,cover_path)
    VALUES (new_title, new_total_duration,
            function_check_if_publisher_exists_and_get_id(new_publisher), new_release_date,
            function_check_if_media_format_exists_and_get_id(new_media_format), new_cover_path);
    SELECT MAX(record_id) INTO new_record_id FROM table_records;
END |


DELIMITER |
CREATE PROCEDURE procedure_update_record(IN id_record INT,
                                         IN new_title varchar(255),
                                         IN new_total_duration time,
                                         IN new_publisher varchar(100),
                                         IN new_release_year char(4),
                                         IN new_media_format varchar(50),
                                         IN new_cover_path varchar(255))
BEGIN
    UPDATE table_records
    SET title           = new_title,
        total_duration  = new_total_duration,
        publisher_id    = function_check_if_publisher_exists_and_get_id(new_publisher),
        release_year    = new_release_year,
        media_format_id = function_check_if_media_format_exists_and_get_id(new_media_format),
        cover_path      = new_cover_path
    WHERE record_id = id_record;
END |