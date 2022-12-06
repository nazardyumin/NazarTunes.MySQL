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
CREATE PROCEDURE procedure_get_all_record_performer_item_with_performer_ids(IN id_record INT)
BEGIN
    SELECT record_performer_item_id FROM table_record_performer_items WHERE record_id = id_record AND performer_id > 0;
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
CREATE PROCEDURE procedure_update_record_performer_item_with_performer(IN item_id INT,
                                                                       new_first_name VARCHAR(100),
                                                                       new_last_name VARCHAR(100))
BEGIN
    SET @id_performer := function_check_if_performer_exists_and_get_id(new_first_name, new_last_name);
    UPDATE table_record_performer_items
    SET performer_id = @id_performer
    WHERE record_performer_item_id = item_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_delete_record_performer_item(IN item_id INT)
BEGIN
    DELETE
    FROM table_record_performer_items
    WHERE record_performer_item_id = item_id;
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
CREATE PROCEDURE procedure_get_all_performers()
BEGIN
    SELECT performer_id, first_name, last_name
    FROM table_performers JOIN table_persons ON table_performers.person_id = table_persons.person_id WHERE is_performer = TRUE;
END|


DELIMITER |
CREATE PROCEDURE procedure_update_person_performer(IN id_performer INT, IN new_first_name VARCHAR(100),
                                                   IN new_last_name VARCHAR(100))
BEGIN
    DECLARE id_person INT;
    SELECT person_id INTO id_person FROM table_performers WHERE performer_id = id_performer;
    UPDATE table_persons SET first_name = new_first_name, last_name = new_last_name WHERE person_id = id_person;
END|

