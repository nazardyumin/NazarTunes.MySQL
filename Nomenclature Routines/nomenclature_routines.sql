DELIMITER |
CREATE FUNCTION function_get_nomenclature_total_amount(id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE nom_amount INT;
    SELECT total_amount INTO nom_amount FROM table_nomenclatures WHERE record_id = id;
    RETURN nom_amount;
END |


DELIMITER |
CREATE FUNCTION function_get_nomenclature_sell_price(id INT)
    RETURNS DECIMAL(8, 2)
    DETERMINISTIC
BEGIN
    DECLARE _price DECIMAL(8, 2);
    SELECT sell_price INTO _price FROM table_nomenclatures WHERE record_id = id;
    RETURN _price;
END |

-- don't forget to use it after sales
DELIMITER |
CREATE PROCEDURE procedure_make_nomenclature_available_or_unavailable(IN rec_id INT)
BEGIN
    DECLARE _price DECIMAL(8, 2);
    DECLARE _amount INT;
    SELECT function_get_nomenclature_sell_price(rec_id) INTO _price;
    SELECT function_get_nomenclature_total_amount(rec_id) INTO _amount;
    IF _price = 0 AND _amount = 0 THEN
        UPDATE table_nomenclatures SET is_available = FALSE WHERE record_id = rec_id;
    ELSE
        IF _price > 0 AND _amount = 0 THEN
            UPDATE table_nomenclatures SET is_available = FALSE WHERE record_id = rec_id;
        ELSE
            IF _price = 0 AND _amount > 0 THEN
                UPDATE table_nomenclatures SET is_available = FALSE WHERE record_id = rec_id;
            ELSE
                UPDATE table_nomenclatures SET is_available = TRUE WHERE record_id = rec_id;
            END IF;
        END IF;
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_set_nomenclature_sell_price(IN nom_id INT, IN new_price DECIMAL(8, 2))
BEGIN
    IF new_price > 0.0 THEN
        UPDATE table_nomenclatures SET sell_price = new_price WHERE nomenclature_id = nom_id;
        CALL procedure_make_nomenclature_available_or_unavailable(nom_id);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_nomenclatures()
BEGIN
    SELECT * FROM table_nomenclatures;
END |


DELIMITER |
CREATE FUNCTION function_check_if_entered_amount_exceeds_actual(id_nomenclature INT, entered_amount INT)
    RETURNS BOOL
    DETERMINISTIC
BEGIN
    SET @actual_amount := function_get_nomenclature_total_amount(id_nomenclature);
    IF entered_amount > @actual_amount THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_add_new_frozen_item(IN id_nomenclature INT, IN id_client INT, IN new_amount INT)
BEGIN
    INSERT INTO table_frozen_nomenclatures (nomenclature_id, client_id, amount)
    VALUES (id_nomenclature, id_client, new_amount);
END |


DELIMITER |
CREATE FUNCTION function_get_nomenclature_frozen_amount(id INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE frozen_amount INT;
    SELECT total_items_frozen INTO frozen_amount FROM table_nomenclatures WHERE record_id = id;
    RETURN frozen_amount;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_frozen_nomenclatures()
BEGIN
    SELECT * FROM table_frozen_nomenclatures;
END |


DELIMITER |
CREATE PROCEDURE procedure_unfreeze_nomenclature(IN id_frozen_nomenclature INT)
BEGIN
    DELETE FROM table_frozen_nomenclatures WHERE frozen_nomenclature_id = id_frozen_nomenclature;
END |