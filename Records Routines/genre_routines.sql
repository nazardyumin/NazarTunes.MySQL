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
CREATE PROCEDURE procedure_get_record_genres(IN id_record INT)
BEGIN
    SELECT genre_name
    FROM table_genres
             JOIN table_record_genre_items
                  ON table_genres.genre_id = table_record_genre_items.genre_id
    WHERE record_id = id_record;
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
CREATE PROCEDURE procedure_get_all_record_genre_item_ids(IN id_record INT)
BEGIN
    SELECT record_genre_item_id FROM table_record_genre_items WHERE record_id = id_record;
END |


DELIMITER |
CREATE PROCEDURE procedure_delete_record_genre_item(IN item_id INT)
BEGIN
    DELETE
    FROM table_record_genre_items
    WHERE record_genre_item_id = item_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_update_record_genre_item(IN item_id INT, IN new_genre_name VARCHAR(100))
BEGIN
    SET @id_genre := function_check_if_genre_exists_and_get_id(new_genre_name);
    UPDATE table_record_genre_items
    SET genre_id = @id_genre
    WHERE record_genre_item_id = item_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_record_genre_item(IN new_record_id INT, IN new_genre_name VARCHAR(100))
BEGIN
    SET @id_genre := function_check_if_genre_exists_and_get_id(new_genre_name);
    SET @exists := EXISTS(SELECT record_genre_item_id
                          FROM table_record_genre_items
                          WHERE record_id = new_record_id
                            AND genre_id = @id_genre);
    IF !@exists THEN
        INSERT INTO table_record_genre_items (record_id, genre_id)
        VALUES (new_record_id, @id_genre);
    END IF;
END |