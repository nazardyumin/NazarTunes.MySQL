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
    DECLARE old_amount INT;
    DECLARE new_amount INT;
    INSERT INTO table_amounts_of_all_procurements (record_id, procurement_id, amount)
    VALUES (NEW.record_id, NEW.procurement_id, NEW.amount);
    SELECT amount INTO old_amount FROM table_nomenclatures WHERE table_nomenclatures.record_id = NEW.record_id;
    SELECT old_amount + NEW.amount INTO new_amount;
    UPDATE table_nomenclatures
    SET amount = new_amount
    WHERE record_id = NEW.record_id;
END |


DELIMITER |
CREATE TRIGGER trigger_make_nomenclature_available_or_unavailable
    AFTER UPDATE
    ON table_nomenclatures
    FOR EACH ROW
BEGIN
    IF NEW.sell_price = 0 AND NEW.total_amount = 0 THEN
        UPDATE table_nomenclatures SET is_available = FALSE WHERE nomenclature_id = NEW.nomenclature_id;
    ELSE
        IF NEW.sell_price > 0 AND NEW.total_amount = 0 THEN
            UPDATE table_nomenclatures SET is_available = FALSE WHERE nomenclature_id = NEW.nomenclature_id;
        ELSE
            IF NEW.sell_price = 0 AND NEW.total_amount > 0 THEN
                UPDATE table_nomenclatures SET is_available = FALSE WHERE nomenclature_id = NEW.nomenclature_id;
            ELSE
                UPDATE table_nomenclatures SET is_available = TRUE WHERE nomenclature_id = NEW.nomenclature_id;
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