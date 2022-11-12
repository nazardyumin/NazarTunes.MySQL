DROP PROCEDURE procedure_insert_credentials_and_get_id;
DROP PROCEDURE procedure_insert_full_name_and_get_id;
DROP PROCEDURE procedure_insert_user_ids;
DROP PROCEDURE procedure_create_user;
DROP PROCEDURE procedure_create_user_test;

DELIMITER |
CREATE PROCEDURE procedure_if_authorization_succeed(IN new_login VARCHAR(50),
                                                    IN new_pass VARCHAR(50),
                                                    OUT if_succeed BOOL)
BEGIN
    SET @success := function_check_if_credentials_correct(new_login, new_pass);
    IF @success THEN
        SELECT TRUE INTO if_succeed;
    ELSE
        SELECT FALSE INTO if_succeed;
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_insert_credentials_and_get_id(IN new_login VARCHAR(50),
                                                         IN new_pass VARCHAR(50),
                                                         IN new_role_id INT,
                                                         OUT new_credential_id INT)
BEGIN
    INSERT INTO table_credentials (login, pass, role_id)
    VALUES (new_login, new_pass, new_role_id);
    SELECT MAX(credential_id) INTO new_credential_id FROM table_credentials;
END |


DELIMITER |
CREATE PROCEDURE procedure_insert_full_name_and_get_id(IN new_first_name VARCHAR(100),
                                                       IN new_last_name VARCHAR(100),
                                                       OUT new_person_id INT)
BEGIN
    INSERT INTO table_persons (first_name, last_name)
    VALUES (new_first_name, new_last_name);
    SELECT MAX(person_id) INTO new_person_id FROM table_persons;
END |


DELIMITER |
CREATE PROCEDURE procedure_insert_user_ids(IN new_role_id INT, IN new_credential_id INT, IN new_person_id INT)
BEGIN
    IF new_role_id = 1 THEN
        INSERT INTO table_admins (credential_id, person_id) VALUES (new_credential_id, new_person_id);
    ELSE
        INSERT INTO table_clients (credential_id, person_id) VALUES (new_credential_id, new_person_id);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_user(IN new_login VARCHAR(50),
                                       IN new_pass VARCHAR(50),
                                       IN new_role_id INT,
                                       IN new_first_name VARCHAR(100),
                                       IN new_last_name VARCHAR(100),
                                       OUT if_succeed BOOL)
BEGIN
    SET @exists := function_check_if_login_exists(new_login);
    IF @exists THEN
        SELECT FALSE INTO if_succeed;
    ELSE
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
                BEGIN
                    SELECT FALSE INTO if_succeed;
                    ROLLBACK;
                END;
            DECLARE EXIT HANDLER FOR SQLWARNING
                BEGIN
                    SELECT FALSE INTO if_succeed;
                    ROLLBACK;
                END;
            BEGIN
                START TRANSACTION;
                BEGIN
                    DECLARE credential_id INT;
                    DECLARE person_id INT;
                    CALL procedure_insert_credentials_and_get_id(new_login, new_pass, new_role_id, credential_id);
                    CALL procedure_insert_full_name_and_get_id(new_first_name, new_last_name, person_id);
                    CALL procedure_insert_user_ids(new_role_id, credential_id, person_id);
                END;
                COMMIT;
                SELECT TRUE INTO if_succeed;
            END;
        END;
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_record_and_get_id(IN new_title VARCHAR(255), IN new_track_amount INT,
                                                    IN new_total_duration TIME, IN new_publisher VARCHAR(100),
                                                    IN new_release_date CHAR(4),
                                                    IN new_media_format VARCHAR(50), OUT new_record_id INT)
BEGIN
    INSERT INTO table_records (title, track_amount, total_duration, publisher_id, release_year, media_format_id)
    VALUES (new_title, new_track_amount, new_total_duration,
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
    SET @id_band :=function_check_if_band_exists_and_get_id(new_band_name);
    SET @exists := EXISTS(SELECT record_performer_item_id
                          FROM table_record_performer_items
                          WHERE record_id = new_record_id
                            AND band_id = @id_band);
    IF !@exists THEN
       INSERT INTO table_record_performer_items (record_id, band_id)
        VALUES (new_record_id, @id_band);
    END IF;
END |







DELIMITER |
CREATE PROCEDURE procedure_create_user_test(IN new_login VARCHAR(50),
                                            IN new_pass VARCHAR(50),
                                            IN new_role_id INT,
                                            IN new_first_name VARCHAR(100),
                                            IN new_last_name VARCHAR(100))
BEGIN
    SET @exists := function_check_if_login_exists(new_login);
    IF !@exists THEN
        BEGIN
            DECLARE credential_id INT;
            DECLARE person_id INT;
            CALL procedure_insert_credentials_and_get_id(new_login, new_pass, new_role_id, credential_id);
            CALL procedure_insert_full_name_and_get_id(new_first_name, new_last_name, person_id);
            CALL procedure_insert_user_ids(new_role_id, credential_id, person_id);
        END;
    END IF;
END |



