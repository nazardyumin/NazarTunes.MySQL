DELIMITER |
CREATE PROCEDURE procedure_create_new_procurement(IN new_date DATE, IN new_supplier_id INT, IN new_record_id INT,
                                                  IN new_amount INT,
                                                  IN new_cost_price DOUBLE)
BEGIN
    INSERT INTO table_procurements (date_of_procurement, supplier_id, record_id, amount, cost_price)
    VALUES (new_date, new_supplier_id, new_record_id, new_amount, new_cost_price);
END |