DELIMITER |
CREATE PROCEDURE procedure_add_new_track(IN id_record INT, new_track_title varchar(255))
BEGIN
    INSERT INTO table_tracks (record_id, track_title) VALUES (id_record, new_track_title);
END |


DELIMITER |
CREATE PROCEDURE procedure_update_track(IN id_track INT, new_track_title varchar(255))
BEGIN
    UPDATE table_tracks SET track_title = new_track_title WHERE track_id = id_track;
END |


DELIMITER |
CREATE PROCEDURE procedure_delete_track(IN id_track INT)
BEGIN
    DELETE
    FROM table_tracks
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