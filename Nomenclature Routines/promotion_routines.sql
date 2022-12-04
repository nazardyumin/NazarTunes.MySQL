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
    INSERT INTO table_discount_promotions (genre_id, discount, is_started)
    VALUES (id_genre, new_discount, new_is_started);
    IF new_is_started THEN
        CALL procedure_set_promotional_price_by_genre(id_genre, new_discount);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_start_promotion_by_genre(IN promotion_id INT)
BEGIN
    UPDATE table_discount_promotions SET is_started = TRUE WHERE discount_promotion_id = promotion_id;
END |


DELIMITER |
CREATE PROCEDURE procedure_finish_promotion_by_genre(IN promotion_id INT)
BEGIN
    UPDATE table_discount_promotions
    SET is_started = FALSE, is_finished = TRUE
    WHERE discount_promotion_id = promotion_id;
END |


DELIMITER |
CREATE TRIGGER trigger_set_promotional_price_if_promotion_by_genre_started
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF genre_id > 0 AND NEW.is_started THEN
        CALL procedure_set_promotional_price_by_genre(genre_id, discount);
    END IF;
END |


DELIMITER |
CREATE TRIGGER trigger_return_normal_price_if_promotion_by_genre_finished
    AFTER UPDATE
    ON table_discount_promotions
    FOR EACH ROW
BEGIN
    IF genre_id > 0 AND NEW.is_finished THEN
        CALL procedure_return_normal_price_by_genre(genre_id, discount);
    END IF;
END |