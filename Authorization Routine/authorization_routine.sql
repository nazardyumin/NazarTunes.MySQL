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