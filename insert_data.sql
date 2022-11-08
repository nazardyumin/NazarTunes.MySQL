INSERT INTO table_roles (role_name) VALUE ('admin');
INSERT INTO table_roles (role_name) VALUE ('client');

CALL procedure_create_user_test('nazar','123',1,'Nazar','Dyumin');
CALL procedure_create_user_test('ivan','123',2,'Ivan','Demidov');


INSERT INTO table_media_formats (media_format) VALUE ('CD');
INSERT INTO table_media_formats (media_format) VALUE ('DVD');
INSERT INTO table_media_formats (media_format) VALUE ('BD');
INSERT INTO table_media_formats (media_format) VALUE ('Vinyl 12"');
INSERT INTO table_media_formats (media_format) VALUE ('Vinyl 10"');
INSERT INTO table_media_formats (media_format) VALUE ('Vinyl 7"');


