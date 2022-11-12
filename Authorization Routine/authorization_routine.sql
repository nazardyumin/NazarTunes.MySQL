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