DELIMITER |
CREATE PROCEDURE procedure_start_promotion(IN promotion_id INT)
BEGIN
    UPDATE table_discount_promotions
    SET is_started = TRUE,
        start_date = DATE(NOW())
    WHERE discount_promotion_id = promotion_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_finish_promotion(IN promotion_id INT)
BEGIN
    UPDATE table_discount_promotions
    SET is_finished = TRUE,
        end_date    = DATE(NOW())
    WHERE discount_promotion_id = promotion_id;
END |







INSERT INTO table_discount_promotions (record_id, discount)
VALUES (2, 15);