DELIMITER |
CREATE PROCEDURE procedure_promotion_by_record_true(IN nom_id INT)
BEGIN
    UPDATE table_nomenclatures SET promotion_by_record = TRUE WHERE nomenclature_id = nom_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_promotion_by_record_false(IN nom_id INT)
BEGIN
    UPDATE table_nomenclatures SET promotion_by_record = FALSE WHERE nomenclature_id = nom_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_set_promotional_price_by_record(IN id_record INT, IN new_discount INT)
BEGIN
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE nom_id INT;
    DECLARE new_price FLOAT;
    DECLARE all_nom_ids CURSOR FOR SELECT nomenclature_id
                                   FROM table_nomenclatures
                                   WHERE record_id = id_record
                                     AND promotion_by_genre = FALSE
                                     AND promotion_by_band = FALSE
                                     AND promotion_by_performer = FALSE
                                     AND promotion_by_record = FALSE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN all_nom_ids;
    read_loop:
    LOOP
        FETCH all_nom_ids INTO nom_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @actual_price := function_get_nomenclature_sell_price(nom_id);
        IF @actual_price > 0 THEN
            SELECT @actual_price * (1 - (new_discount / 100)) INTO new_price;
            CALL procedure_set_nomenclature_sell_price(nom_id, new_price);
            CALL procedure_promotion_by_record_true(nom_id);
        END IF;
    END LOOP;
    CLOSE all_nom_ids;
END |


DELIMITER |
CREATE PROCEDURE procedure_return_normal_price_by_record(IN id_record INT, IN new_discount INT)
BEGIN
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE nom_id INT;
    DECLARE normal_price FLOAT;
    DECLARE all_nom_ids CURSOR FOR SELECT nomenclature_id
                                   FROM table_nomenclatures
                                   WHERE record_id = id_record
                                     AND promotion_by_record = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN all_nom_ids;
    read_loop:
    LOOP
        FETCH all_nom_ids INTO nom_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @promotional_price := function_get_nomenclature_sell_price(nom_id);
        SELECT 100 * (@promotional_price / (100 - new_discount)) INTO normal_price;
        CALL procedure_set_nomenclature_sell_price(nom_id, normal_price);
        CALL procedure_promotion_by_record_false(nom_id);
    END LOOP;
    CLOSE all_nom_ids;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_new_promotion_by_record(IN id_record INT, IN new_discount INT, IN new_is_started BOOL)
BEGIN
    DECLARE promo_id INT;
    INSERT INTO table_discount_promotions (record_id, discount, is_started)
    VALUES (id_record, new_discount, new_is_started);
    IF new_is_started THEN
        SELECT MAX(discount_promotion_id) FROM table_discount_promotions INTO promo_id;
        CALL procedure_start_promotion(promo_id);
    END IF;
END |


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