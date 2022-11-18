DELIMITER |
CREATE TRIGGER trigger_create_nomenclature_after_creating_record
    AFTER INSERT
    ON table_records
    FOR EACH ROW
BEGIN
    INSERT INTO table_nomenclatures (record_id) VALUE (NEW.record_id);
END |


DELIMITER |
CREATE TRIGGER trigger_update_nomenclature_amount_after_adding_procurement
    AFTER INSERT
    ON table_procurements
    FOR EACH ROW
BEGIN
    DECLARE old_amount INT DEFAULT 0;
    DECLARE new_amount INT DEFAULT 0;
    INSERT INTO table_amounts_of_all_procurements (record_id, procurement_id, amount)
    VALUES (NEW.record_id, NEW.procurement_id, NEW.amount);
    SELECT function_get_nomenclature_total_amount(NEW.record_id) INTO old_amount;
    SELECT old_amount + NEW.amount INTO new_amount;
    UPDATE table_nomenclatures
    SET total_amount = new_amount
    WHERE record_id = NEW.record_id;
    CALL procedure_make_nomenclature_available_or_unavailable(NEW.record_id);
END |


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
    RETURNS DOUBLE
    DETERMINISTIC
BEGIN
    DECLARE _price INT;
    SELECT sell_price INTO _price FROM table_nomenclatures WHERE record_id = id;
    RETURN _price;
END |


DELIMITER |
CREATE PROCEDURE procedure_make_nomenclature_available_or_unavailable(IN rec_id INT)
BEGIN
    DECLARE _price DOUBLE;
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
CREATE PROCEDURE procedure_create_supplier(IN new_supplier TEXT, IN new_contact_info TEXT)
BEGIN
    SET @exists := EXISTS(SELECT supplier_id
                          FROM table_suppliers
                          WHERE supplier = new_supplier
                            AND contact_info = new_contact_info);
    IF !@exists THEN
        INSERT INTO table_suppliers (supplier, contact_info) VALUES (new_supplier, new_contact_info);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_suppliers()
BEGIN
    SELECT * FROM table_suppliers;
END |


DELIMITER |
CREATE PROCEDURE procedure_set_nomenclature_sell_price(IN nom_id INT, IN new_price DOUBLE)
BEGIN
    IF new_price > 0.0 THEN
        UPDATE table_nomenclatures SET sell_price = new_price WHERE nomenclature_id = nom_id;
        CALL procedure_make_nomenclature_available_or_unavailable(nom_id);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_new_procurement(IN new_date DATE, IN new_supplier_id INT, IN new_record_id INT,
                                                  IN new_amount INT,
                                                  IN new_cost_price DOUBLE)
BEGIN
    INSERT INTO table_procurements (date_of_procurement, supplier_id, record_id, amount, cost_price)
    VALUES (new_date, new_supplier_id, new_record_id, new_amount, new_cost_price);
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_nomenclatures()
BEGIN
    SELECT * FROM table_nomenclatures;
END |