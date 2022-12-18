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


DELIMITER |
CREATE FUNCTION function_check_if_login_exists(new_login VARCHAR(50))
    RETURNS BOOL
    DETERMINISTIC
BEGIN
    SET @exists := EXISTS(SELECT credential_id
                          FROM table_credentials
                          WHERE login = new_login);
    IF @exists THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_check_if_credentials_correct(new_login VARCHAR(50), new_pass VARCHAR(50))
    RETURNS BOOL
    DETERMINISTIC
BEGIN
    SET @success := EXISTS(SELECT credential_id
                           FROM table_credentials
                           WHERE login = new_login
                             AND pass = new_pass);
    IF @success THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_get_credential_id(new_login VARCHAR(50), new_pass VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT credential_id
    INTO id
    FROM table_credentials
    WHERE login = new_login
      AND pass = new_pass;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_get_role_id(cred_id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT role_id INTO id FROM table_credentials WHERE credential_id = cred_id;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_get_role(new_login VARCHAR(50), new_pass VARCHAR(50))
    RETURNS VARCHAR(10)
    DETERMINISTIC
BEGIN
    DECLARE role VARCHAR(10);
    SET @id := function_get_credential_id(new_login, new_pass);
    SET @role_id := function_get_role_id(@id);
    SELECT role_name INTO role FROM table_roles WHERE role_id = @role_id;
    RETURN role;
END |


DELIMITER |
CREATE FUNCTION function_check_if_user_is_deleted(new_login VARCHAR(50), new_pass VARCHAR(50))
    RETURNS BOOL
    DETERMINISTIC
BEGIN
    DECLARE deleted_user BOOl;
    SELECT is_deleted
    INTO deleted_user
    FROM table_credentials
    WHERE login = new_login
      AND pass = new_pass;
    RETURN deleted_user;
END |


DELIMITER |
CREATE FUNCTION function_get_admin_id(cred_id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT admin_id INTO id FROM table_admins WHERE credential_id = cred_id;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_get_admin_person_id(cred_id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT person_id INTO id FROM table_admins WHERE credential_id = cred_id;
    RETURN id;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_admin(IN new_login VARCHAR(50),
                                     IN new_pass VARCHAR(50),
                                     OUT user_id INT,
                                     OUT user_first_name VARCHAR(100),
                                     OUT user_last_name VARCHAR(100))
BEGIN
    SET @credential_id := function_get_credential_id(new_login, new_pass);
    SET @person_id := function_get_admin_person_id(@credential_id);
    SELECT function_get_admin_id(@credential_id) INTO user_id;
    SELECT first_name INTO user_first_name FROM table_persons WHERE person_id = @person_id;
    SELECT last_name INTO user_last_name FROM table_persons WHERE person_id = @person_id;
END |


DELIMITER |
CREATE FUNCTION function_get_client_id(cred_id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT client_id INTO id FROM table_clients WHERE credential_id = cred_id;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_get_client_person_id(cred_id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT person_id INTO id FROM table_clients WHERE credential_id = cred_id;
    RETURN id;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_client(IN new_login VARCHAR(50),
                                      IN new_pass VARCHAR(50),
                                      OUT user_id INT,
                                      OUT user_first_name VARCHAR(100),
                                      OUT user_last_name VARCHAR(100),
                                      OUT user_phone VARCHAR(20),
                                      OUT user_email VARCHAR(100),
                                      OUT user_total_amount_spent DOUBLE,
                                      OUT user_personal_discount INT,
                                      OUT user_is_subscribed BOOL)
BEGIN
    SET @credential_id := function_get_credential_id(new_login, new_pass);
    SET @person_id := function_get_client_person_id(@credential_id);
    SELECT function_get_client_id(@credential_id) INTO user_id;
    SELECT first_name INTO user_first_name FROM table_persons WHERE person_id = @person_id;
    SELECT last_name INTO user_last_name FROM table_persons WHERE person_id = @person_id;
    SELECT phone INTO user_phone FROM table_clients WHERE client_id = user_id;
    SELECT email INTO user_email FROM table_clients WHERE client_id = user_id;
    SELECT total_amount_spent INTO user_total_amount_spent FROM table_clients WHERE client_id = user_id;
    SELECT personal_discount INTO user_personal_discount FROM table_clients WHERE client_id = user_id;
    SELECT is_subscribed INTO user_is_subscribed FROM table_clients WHERE client_id = user_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_user_with_no_check(IN new_login VARCHAR(50),
                                                     IN new_pass VARCHAR(50),
                                                     IN new_role_id INT,
                                                     IN new_first_name VARCHAR(100),
                                                     IN new_last_name VARCHAR(100),
                                                     OUT if_succeed BOOL)
BEGIN
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
END |


DELIMITER |
CREATE FUNCTION function_get_client_person_id(cred_id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE id INT;
    SELECT person_id INTO id FROM table_clients WHERE credential_id = cred_id;
    RETURN id;
END |


DELIMITER |
CREATE FUNCTION function_check_if_client_exists(id_client INT, clients_phone VARCHAR(20), clients_email VARCHAR(100))
    RETURNS BOOL
    DETERMINISTIC
BEGIN
    DECLARE client_exists BOOL DEFAULT FALSE;
    IF id_client > 0 THEN
        SELECT EXISTS(SELECT client_id FROM table_clients WHERE client_id = id_client) INTO client_exists;
    ELSE
        IF clients_phone != '' THEN
            SELECT EXISTS(SELECT client_id FROM table_clients WHERE phone = clients_phone) INTO client_exists;
        ELSE
            IF clients_email != '' THEN
                SELECT EXISTS(SELECT client_id FROM table_clients WHERE email = clients_email) INTO client_exists;
            ELSE
                RETURN client_exists;
            END IF;
        END IF;
    END IF;
    RETURN client_exists;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_clients_full_name_and_id(IN id_client INT, IN clients_phone VARCHAR(20),
                                                        IN clients_email VARCHAR(100),
                                                        OUT id INT,
                                                        OUT clients_first_name VARCHAR(100),
                                                        OUT clients_last_name VARCHAR(100))
BEGIN
    IF clients_phone != '' THEN
        SELECT client_id INTO id FROM table_clients WHERE phone = clients_phone;
        SELECT first_name
        INTO clients_first_name
        FROM table_persons
                 JOIN table_clients ON table_persons.person_id = table_clients.person_id
        WHERE phone = clients_phone;
        SELECT last_name
        INTO clients_last_name
        FROM table_persons
                 JOIN table_clients ON table_persons.person_id = table_clients.person_id
        WHERE phone = clients_phone;
    ELSE
        IF clients_email != '' THEN
            SELECT client_id INTO id FROM table_clients WHERE email = clients_email;
            SELECT first_name
            INTO clients_first_name
            FROM table_persons
                     JOIN table_clients ON table_persons.person_id = table_clients.person_id
            WHERE email = clients_email;
            SELECT last_name
            INTO clients_last_name
            FROM table_persons
                     JOIN table_clients ON table_persons.person_id = table_clients.person_id
            WHERE email = clients_email;
        ELSE
            SELECT id_client INTO id;
            SELECT first_name
            INTO clients_first_name
            FROM table_persons
                     JOIN table_clients ON table_persons.person_id = table_clients.person_id
            WHERE client_id = id_client;
            SELECT last_name
            INTO clients_last_name
            FROM table_persons
                     JOIN table_clients ON table_persons.person_id = table_clients.person_id
            WHERE client_id = id_client;
        END IF;
    END IF;
END |


DELIMITER |
CREATE FUNCTION function_get_client_info(id_client INT)
    RETURNS TEXT
    DETERMINISTIC
BEGIN
    DECLARE client_info TEXT;
    SELECT CONCAT_WS(' ', 'ID', client_id, '-', first_name, last_name, phone, email)
    FROM table_clients
             JOIN table_persons ON table_clients.person_id = table_persons.person_id
    WHERE client_id = id_client
    INTO client_info;
    RETURN client_info;
END |