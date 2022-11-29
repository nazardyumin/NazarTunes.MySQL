DELIMITER |
CREATE PROCEDURE procedure_create_supplier(IN new_supplier TEXT, IN new_contact_info TEXT)
BEGIN
    SET @exists := EXISTS(SELECT supplier_id
                          FROM table_suppliers
                          WHERE supplier_name = new_supplier
                            AND contact_info = new_contact_info);
    IF !@exists THEN
        INSERT INTO table_suppliers (supplier_name, contact_info) VALUES (new_supplier, new_contact_info);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_update_supplier(IN id_supplier INT, IN new_supplier TEXT, IN new_contact_info TEXT,
                                           IN cooperating BOOL)
BEGIN
    IF new_supplier != '' AND new_contact_info != '' THEN
        UPDATE table_suppliers
        SET supplier_name  = new_supplier,
            contact_info   = new_contact_info,
            is_cooperating = cooperating
        WHERE supplier_id = id_supplier;
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_suppliers()
BEGIN
    SELECT * FROM table_suppliers;
END |