INSERT INTO table_roles (role_name) VALUE ('admin');
INSERT INTO table_roles (role_name) VALUE ('client');

CALL procedure_create_user_test('nazar','123',1,'Nazar','Dyumin');


INSERT INTO table_media_formats (media_format) VALUE ('CD');
INSERT INTO table_media_formats (media_format) VALUE ('DVD');
INSERT INTO table_media_formats (media_format) VALUE ('BD');
INSERT INTO table_media_formats (media_format) VALUE ('Vinyl 12"');
INSERT INTO table_media_formats (media_format) VALUE ('Vinyl 10"');
INSERT INTO table_media_formats (media_format) VALUE ('Vinyl 7"');

INSERT INTO table_bands (band_name) VALUE ('Modern Talking');
INSERT INTO table_bands (band_name) VALUE ('Queen');
INSERT INTO table_bands (band_name) VALUE ('Iron Maiden');
INSERT INTO table_bands (band_name) VALUE ('System Of A Down');
INSERT INTO table_bands (band_name) VALUE ('Backstreet Boys');
INSERT INTO table_bands (band_name) VALUE ('Aqua');
INSERT INTO table_bands (band_name) VALUE ('Scorpions');
INSERT INTO table_bands (band_name) VALUE ('Acoustic Alchemy');
INSERT INTO table_bands (band_name) VALUE ('Bee Gees');

INSERT INTO table_persons (first_name, last_name, is_performer) VALUES ('Brian','Culbertson',TRUE);
INSERT INTO table_persons (first_name, last_name, is_performer) VALUES ('Thomas','Anders',TRUE);
INSERT INTO table_persons (first_name, last_name, is_performer) VALUES ('Dieter','Bohlen',TRUE);
INSERT INTO table_persons (first_name, last_name, is_performer) VALUES ('Julien','Dore',TRUE);
INSERT INTO table_persons (first_name, last_name, is_performer) VALUES ('Louis','Armstrong',TRUE);
INSERT INTO table_persons (first_name, last_name, is_performer) VALUES ('Britney','Spears',TRUE);

INSERT INTO table_publishers (publisher) VALUE ('Sony Music');
INSERT INTO table_publishers (publisher) VALUE ('BMG');
INSERT INTO table_publishers (publisher) VALUE ('Polydor');

SET @test :=0;
CALL procedure_create_record_and_get_id('The 1st Album', '9', '00:39:40', 'BMG Ariola', '1985','LP',@test);

CALL procedure_create_record_genre_item(@test, 'Disco');

CALL procedure_create_record_performer_item_with_performer(@test, 'Somebody', 'Famous');
CALL procedure_create_record_performer_item_with_performer(@test, 'Somebody', 'With Guitar');
CALL procedure_create_record_performer_item_with_performer(@test, 'Somebody', 'With Piano');
CALL procedure_create_record_performer_item_with_band(@test, 'Some Very Popular Band');

