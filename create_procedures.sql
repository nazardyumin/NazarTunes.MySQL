DROP PROCEDURE procedure_insert_credentials_and_get_id;
DROP PROCEDURE procedure_insert_full_name_and_get_id;
DROP PROCEDURE procedure_insert_user_ids;
DROP PROCEDURE procedure_create_user;
DROP PROCEDURE procedure_create_user_test;


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
            DECLARE credential_id INT;
            DECLARE person_id INT;
            CALL procedure_insert_credentials_and_get_id(new_login, new_pass, new_role_id, credential_id);
            CALL procedure_insert_full_name_and_get_id(new_first_name, new_last_name, person_id);
            CALL procedure_insert_user_ids(new_role_id, credential_id, person_id);
        END;
        SELECT TRUE INTO if_succeed;
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

