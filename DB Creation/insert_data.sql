INSERT INTO table_roles (role_name) VALUE ('admin');
INSERT INTO table_roles (role_name) VALUE ('client');

CALL procedure_create_user_test('nazar','123',1,'Nazar','Dyumin');
CALL procedure_create_user_test('ivan','123',2,'Ivan','Ivanov');

SET @test :=0;
CALL procedure_create_record_and_get_id('The 1st Album', '00:39:40', 'BMG Ariola', '1985','LP',@test);

CALL procedure_create_record_genre_item(@test, 'Pop');
CALL procedure_create_record_genre_item(@test, 'Disco');

CALL procedure_create_record_performer_item_with_performer(@test, 'Thomas', 'Anders');
CALL procedure_create_record_performer_item_with_performer(@test, 'Dieter', 'Bohlen');
CALL procedure_create_record_performer_item_with_band(@test, 'Modern Talking');

INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'You’re My Heart, You’re My Soul');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'You Can Win If You Want');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'There’s Too Much Blue In Missing You');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Diamonds Never Made A Lady');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'The Night Is Yours — The Night Is Mine');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Do You Wanna');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Lucky Guy');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'One In A Million');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Bells Of Paris');

CALL procedure_create_record_and_get_id('The Montreux Album', '00:34:32', 'RAK', '1978','LP',@test);
CALL procedure_create_record_performer_item_with_band(@test, 'Smokie');
CALL procedure_create_record_genre_item(@test, 'Pop Rock');
CALL procedure_create_record_genre_item(@test, 'Country Rock');

INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'The Girl Can’t Help It');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Power Of Love');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'No More Letters');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Mexican Girl');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'You Took Me By Surprise');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Oh Carol');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Liverpool Docks');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Light Up My Life');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'Petesey’s Song');
INSERT INTO table_tracks (record_id, track_title) VALUES (@test, 'For A Few Dollars More');

CALL procedure_create_supplier('Melody Vinyl Store','Russia, Ufa, 5 Lenin str, 8(347)200-30-40');
CALL procedure_create_supplier('CD Base','Russia, Moscow, 12 Arbat str, 8(495)900-50-60');


CALL procedure_create_new_procurement('2022-11-17',1,1,10,2050.10);
CALL procedure_set_nomenclature_sell_price(1,3500.20);




CALL procedure_get_record_genres(@test);

CALL procedure_get_record_performers_persons(@test);
CALL procedure_get_record_performers_bands(@test);