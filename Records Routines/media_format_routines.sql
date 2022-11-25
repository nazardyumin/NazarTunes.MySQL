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