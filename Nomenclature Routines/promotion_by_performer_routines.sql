








DELIMITER |
CREATE PROCEDURE procedure_get_all_promotions_by_performer()
BEGIN
    SELECT discount_promotion_id,
           first_name,
           last_name,
           discount,
           is_started,
           is_finished,
           start_date,
           end_date
    FROM table_discount_promotions
             JOIN table_performers ON table_discount_promotions.performer_id = table_performers.performer_id
             JOIN table_persons ON table_performers.person_id = table_persons.person_id
    WHERE table_discount_promotions.performer_id > 0;
END |