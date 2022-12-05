DELIMITER |
CREATE PROCEDURE procedure_promotion_by_genre_true(IN nom_id INT)
BEGIN
    UPDATE table_nomenclatures SET promotion_by_genre = TRUE WHERE nomenclature_id = nom_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_promotion_by_genre_false(IN nom_id INT)
BEGIN
    UPDATE table_nomenclatures SET promotion_by_genre = FALSE WHERE nomenclature_id = nom_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_set_promotional_price_by_genre(IN id_genre INT, IN new_discount INT)
BEGIN
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE nom_id INT;
    DECLARE actual_price DOUBLE;
    DECLARE new_price DOUBLE;
    DECLARE all_nom_ids CURSOR FOR SELECT nomenclature_id
                                   FROM table_nomenclatures
                                            JOIN table_records
                                                 ON table_nomenclatures.record_id = table_records.record_id
                                            JOIN table_record_genre_items
                                                 ON table_records.record_id = table_record_genre_items.record_id
                                   WHERE genre_id = id_genre
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
        SELECT function_get_nomenclature_sell_price(nom_id) INTO actual_price;
        IF actual_price > 0 THEN
            SELECT actual_price * (1 - (new_discount / 100)) INTO new_price;
            CALL procedure_set_nomenclature_sell_price(nom_id, new_price);
            CALL procedure_promotion_by_genre_true(nom_id);
        END IF;
    END LOOP;
    CLOSE all_nom_ids;
END |


DELIMITER |
CREATE PROCEDURE procedure_return_normal_price_by_genre(IN id_genre INT, IN new_discount INT)
BEGIN
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE nom_id INT;
    DECLARE promotional_price DOUBLE;
    DECLARE normal_price DOUBLE;
    DECLARE all_nom_ids CURSOR FOR SELECT nomenclature_id
                                   FROM table_nomenclatures
                                            JOIN table_records
                                                 ON table_nomenclatures.record_id = table_records.record_id
                                            JOIN table_record_genre_items
                                                 ON table_records.record_id = table_record_genre_items.record_id
                                   WHERE genre_id = id_genre
                                     AND promotion_by_genre = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN all_nom_ids;
    read_loop:
    LOOP
        FETCH all_nom_ids INTO nom_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SELECT function_get_nomenclature_sell_price(nom_id) INTO promotional_price;
        SELECT promotional_price * (1 + (new_discount / 100)) INTO normal_price;
        CALL procedure_set_nomenclature_sell_price(nom_id, normal_price);
        CALL procedure_promotion_by_genre_false(nom_id);
    END LOOP;
    CLOSE all_nom_ids;
END |


DELIMITER |
CREATE PROCEDURE procedure_create_new_promotion_by_genre(IN id_genre INT, IN new_discount INT, IN new_is_started BOOL)
BEGIN
    DECLARE promo_id INT;
    INSERT INTO table_discount_promotions (genre_id, discount, is_started)
    VALUES (id_genre, new_discount, new_is_started);
    IF new_is_started THEN
        SELECT MAX(discount_promotion_id) FROM table_discount_promotions INTO promo_id;
        CALL procedure_start_promotion_by_genre(promo_id);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_start_promotion_by_genre(IN promotion_id INT)
BEGIN
    UPDATE table_discount_promotions
    SET is_started = TRUE,
        start_date = DATE(NOW())
    WHERE discount_promotion_id = promotion_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_finish_promotion_by_genre(IN promotion_id INT)
BEGIN
    UPDATE table_discount_promotions
    SET is_finished = TRUE,
        end_date    = DATE(NOW())
    WHERE discount_promotion_id = promotion_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_promotions_by_genre()
BEGIN
    SELECT discount_promotion_id,
           genre_name,
           discount,
           is_started,
           is_finished,
           start_date,
           end_date
    FROM table_discount_promotions
             JOIN table_genres ON table_discount_promotions.genre_id = table_genres.genre_id
    WHERE table_discount_promotions.genre_id > 0;
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

INSERT INTO table_discount_promotions (record_id, discount)
VALUES (2, 15);