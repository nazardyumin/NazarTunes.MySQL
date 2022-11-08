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