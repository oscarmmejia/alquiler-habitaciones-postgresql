-- Registros iniciales
-- Se presupone una base recién creada con identificadores 1, 2, 3...
INSERT INTO owner (name,surname,email,phone)
VALUES ('Carlos','Ramírez','carlos@email.com','612345678');

INSERT INTO country (name) VALUES ('Colombia'),('España');

INSERT INTO city (name,country_id)
VALUES ('Bogotá',1),('Medellín',1),('Cali',1),('Madrid',2);

INSERT INTO client (city_id,name,surname,email,phone)
VALUES
 (1,'Paula','Ríos','paula@email.com','611111111'),
 (2,'María','López','maria@email.com','622222222'),
 (3,'Miguel','Torres','miguel@email.com','633333333');

INSERT INTO property (owner_id,city_id,title,description,status,property_type,price,created_at)
VALUES
 (1,1,'Apartamento Centro Bogotá','Apartamento céntrico y luminoso','publicada','Apartamento',90.00,'2024-04-15'),
 (1,2,'Casa Jardín Medellín','Casa con jardín y terraza','publicada','Casa',150.00,'2024-06-20');

INSERT INTO room (property_id,name,description,status,price,capacity)
VALUES
 (1,'Loft Central','Habitación privada con baño','disponible',65.00,2),
 (1,'Habitación Compartida','Habitación compartida para estudiantes','disponible',35.00,3),
 (2,'Suite Norte','Habitación amplia con terraza','disponible',85.00,2);

INSERT INTO facility (name,category)
VALUES ('Wi-Fi','Tecnología'),('Aparcamiento','Transporte'),
 ('Aire acondicionado','Comodidad'),('Desayuno','Alimentación'),
 ('Lavadora','Equipamiento');

INSERT INTO room_facility (room_id,facility_id,verified,costo_adicional,disponibilidad)
VALUES (1,1,TRUE,0,TRUE),(1,3,TRUE,5,TRUE),(1,4,TRUE,8,TRUE),
       (3,1,TRUE,0,TRUE),(3,2,FALSE,10,FALSE);

INSERT INTO reservation (client_id,property_id,room_id,status,start_date,end_date,expires_at,created_at)
VALUES
 (1,1,1,'pendiente','2026-11-05','2026-11-08','2026-11-01','2026-10-25 23:09:35'),
 (1,1,1,'confirmada','2026-11-20','2026-11-23',NULL,'2026-10-25 23:09:35'),
 (2,2,3,'confirmada','2026-12-10','2026-12-12',NULL,'2026-10-25 23:09:35'),
 (3,1,2,'pendiente','2026-12-03','2026-12-06','2026-11-25','2026-10-25 23:09:35'),
 (2,2,NULL,'confirmada','2027-01-15','2027-01-18',NULL,'2026-10-25 23:09:35');

-- Estado histórico de ejemplo: las fechas anteriores a la creación se corrigen en E14.
INSERT INTO payment (reservation_id,amount,payment_method,status,paid_at)
VALUES (2,195.00,'tarjeta','pagado','2026-10-20'),
       (3,170.00,'transferencia','pagado','2026-10-21'),
       (5,450.00,'tarjeta','pagado','2026-10-22');

INSERT INTO visit (client_id,property_id,date,status,confirmed_by_owner,confirmed_by_client)
VALUES
 (1,1,'2026-10-15 17:00:00','realizada',TRUE,TRUE),
 (2,1,'2026-10-19 12:00:00','realizada',TRUE,TRUE),
 (3,2,'2026-11-05 16:00:00','programada',FALSE,FALSE);

INSERT INTO review (reservation_id,visit_id,rating,comment)
VALUES (NULL,1,5,'Propiedad muy bien ubicada'),
       (NULL,2,4,'Buena distribución y espacios');
