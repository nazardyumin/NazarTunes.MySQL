DELIMITER |
CREATE PROCEDURE procedure_promotion_by_band_true(IN nom_id INT)
BEGIN
    UPDATE table_nomenclatures SET promotion_by_band = TRUE WHERE nomenclature_id = nom_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_promotion_by_band_false(IN nom_id INT)
BEGIN
    UPDATE table_nomenclatures SET promotion_by_band = FALSE WHERE nomenclature_id = nom_id;
END |

-- doesn't work!!!!!!!!!
DELIMITER |
CREATE PROCEDURE procedure_set_promotional_price_by_band(IN id_band INT, IN new_discount INT)
BEGIN
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE nom_id INT;
    DECLARE new_price FLOAT;
    DECLARE all_nom_ids CURSOR FOR SELECT nomenclature_id
                                   FROM table_nomenclatures
                                            JOIN table_records
                                                 ON table_nomenclatures.record_id = table_records.record_id
                                            JOIN table_record_performer_items
                                                 ON table_records.record_id = table_record_performer_items.record_id
                                   WHERE band_id = id_band
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
        SET @actual_price:= function_get_nomenclature_sell_price(nom_id);
        IF @actual_price > 0 THEN
            SELECT @actual_price*(1-(new_discount/100)) INTO new_price;
            CALL procedure_set_nomenclature_sell_price(nom_id, new_price);
            CALL procedure_promotion_by_band_true(nom_id);
        END IF;
    END LOOP;
    CLOSE all_nom_ids;
END |


DELIMITER |
CREATE PROCEDURE procedure_return_normal_price_by_band(IN id_band INT, IN new_discount INT)
BEGIN
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE nom_id INT;
    DECLARE normal_price FLOAT;
    DECLARE all_nom_ids CURSOR FOR SELECT nomenclature_id
                                   FROM table_nomenclatures
                                            JOIN table_records
                                                 ON table_nomenclatures.record_id = table_records.record_id
                                            JOIN table_record_performer_items
                                                 ON table_records.record_id = table_record_performer_items.record_id
                                   WHERE band_id = id_band
                                     AND promotion_by_band = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN all_nom_ids;
    read_loop:
    LOOP
        FETCH all_nom_ids INTO nom_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @promotional_price := function_get_nomenclature_sell_price(nom_id);
        SELECT 100 * (@promotional_price/(100-new_discount)) INTO normal_price;
        CALL procedure_set_nomenclature_sell_price(nom_id, normal_price);
        CALL procedure_promotion_by_band_false(nom_id);
    END LOOP;
    CLOSE all_nom_ids;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_new_promotion_by_band(IN id_band INT, IN new_discount INT, IN new_is_started BOOL)
BEGIN
    DECLARE promo_id INT;
    INSERT INTO table_discount_promotions (band_id, discount, is_started)
    VALUES (id_band, new_discount, new_is_started);
    IF new_is_started THEN
        SELECT MAX(discount_promotion_id) FROM table_discount_promotions INTO promo_id;
        CALL procedure_start_promotion(promo_id);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_promotions_by_band()
BEGIN
    SELECT discount_promotion_id,
           band_name,
           discount,
           is_started,
           is_finished,
           start_date,
           end_date
    FROM table_discount_promotions
             JOIN table_bands ON table_discount_promotions.band_id = table_bands.band_id
    WHERE table_discount_promotions.band_id > 0;
END |