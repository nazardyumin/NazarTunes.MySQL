






DELIMITER |
CREATE PROCEDURE procedure_get_all_promotions_by_record()
BEGIN
    SELECT discount_promotion_id,
           record_id,
           discount,
           is_started,
           is_finished,
           start_date,
           end_date
    FROM table_discount_promotions
    WHERE record_id > 0;
END |