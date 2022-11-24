DELIMITER |
CREATE PROCEDURE procedure_add_new_track(IN id_record INT, new_track_title varchar(255))
BEGIN
    SET @exists := EXISTS(SELECT track_id FROM table_tracks WHERE is_deleted = TRUE);
    IF @exists THEN
        BEGIN
            DECLARE deleted_track_id INT;
            SELECT track_id
            INTO deleted_track_id
            FROM table_tracks
            WHERE is_deleted = TRUE
            LIMIT 1;
            UPDATE table_tracks
            SET is_deleted  = FALSE,
                record_id   = id_record,
                track_title = new_track_title
            WHERE track_id = deleted_track_id;
        END;
    ELSE
        INSERT INTO table_tracks (record_id, track_title) VALUES (id_record, new_track_title);
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_update_track(IN id_track INT, new_track_title varchar(255))
BEGIN
    SET @exists := EXISTS(SELECT track_id FROM table_tracks WHERE track_id = id_track);
    IF !@exists THEN
        UPDATE table_tracks SET track_title = new_track_title WHERE track_id = id_track;
    END IF;
END |


DELIMITER |
CREATE PROCEDURE procedure_delete_track(IN id_track INT)
BEGIN
    UPDATE table_tracks
    SET is_deleted  = TRUE,
        record_id   = NULL,
        track_title = ''
    WHERE track_id = id_track;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_all_track_ids_for_one_record(IN id_record INT)
BEGIN
    SELECT track_id FROM table_tracks WHERE record_id = id_record;
END |


DELIMITER |
CREATE PROCEDURE procedure_get_record_tracks(IN id_record INT)
BEGIN
    SELECT track_title FROM table_tracks WHERE record_id = id_record;
END |