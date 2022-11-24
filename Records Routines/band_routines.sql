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
CREATE PROCEDURE procedure_update_band(IN id INT, IN new_band_name VARCHAR(255))
BEGIN
    UPDATE table_bands SET band_name = new_band_name WHERE band_id = id;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_record_performer_item_with_band_ids(IN id_record INT)
BEGIN
    SELECT record_performer_item_id FROM table_record_performer_items WHERE record_id = id_record AND band_id > 0;
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
        SET @deleted_item := EXISTS(SELECT record_performer_item_id
                                    FROM table_record_performer_items
                                    WHERE is_deleted = TRUE);
        IF @deleted_item THEN
            BEGIN
                DECLARE deleted_item_id INT;
                SELECT record_performer_item_id
                INTO deleted_item_id
                FROM table_record_performer_items
                WHERE is_deleted = TRUE
                LIMIT 1;
                UPDATE table_record_performer_items
                SET band_id    = @id_band,
                    record_id  = new_record_id,
                    is_deleted = FALSE
                WHERE record_performer_item_id = deleted_item_id;
            END;
        ELSE
            INSERT INTO table_record_performer_items (record_id, band_id)
            VALUES (new_record_id, @id_band);
        END IF;
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_update_record_performer_item_with_band(IN item_id INT, IN new_band_name VARCHAR(255))
BEGIN
    SET @id_band := function_check_if_band_exists_and_get_id(new_band_name);
    UPDATE table_record_performer_items
    SET band_id = @id_band
    WHERE record_performer_item_id = item_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_delete_record_performer_item_with_band(IN item_id INT)
BEGIN
    UPDATE table_record_performer_items
    SET is_deleted = TRUE,
        record_id  = NULL,
        band_id    = NULL
    WHERE record_performer_item_id = item_id;
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
CREATE PROCEDURE procedure_get_all_bands()
BEGIN
    SELECT * FROM table_bands;
END |