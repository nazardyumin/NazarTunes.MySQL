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