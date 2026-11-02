-- Ejercicios numerados del enunciado. Ejecutar sentencias por separado en pgAdmin.
-- Algunas variantes se proporcionan comentadas y pueden ejecutarse de forma independiente.
-- EJERCICIO 38 | Propiedad y su anfitrión
SELECT p.title, o.name, o.surname
FROM owner o
JOIN property p ON p.owner_id = o.owner_id;
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Variante completa para habitación y anfitrión:
-- SELECT r.name AS habitacion, o.name, o.surname
-- FROM owner o
-- JOIN property p ON o.owner_id = p.owner_id
-- JOIN room r ON p.property_id = r.property_id;

-- EJERCICIO 39 | Título, tipo y anfitrión de propiedades
SELECT p.title, p.property_type, o.name, o.surname
FROM property p JOIN owner o ON p.owner_id = o.owner_id;

-- EJERCICIO 40 | Reservas y nombre del huésped
SELECT r.reservation_id, c.name, c.surname, r.status
FROM reservation r JOIN client c ON r.client_id = c.client_id;

-- EJERCICIO 41 | Reservas y nombre de habitación
SELECT res.reservation_id, r.name AS habitacion, res.status
FROM reservation res
LEFT JOIN room r ON res.room_id = r.room_id;

-- EJERCICIO 42 | Reserva, huésped, alojamiento, fechas y estado
SELECT r.reservation_id, c.name, c.surname, p.title,
       r.start_date, r.end_date, r.status
FROM reservation r
JOIN client c ON r.client_id = c.client_id
JOIN property p ON r.property_id = p.property_id;
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Variante completa con habitación (y reservas de propiedad completa):
-- SELECT res.reservation_id, c.name, c.surname,
--        p.title AS propiedad, rm.name AS habitacion,
--        res.start_date, res.end_date, res.status
-- FROM reservation res
-- JOIN client c ON res.client_id = c.client_id
-- JOIN property p ON res.property_id = p.property_id
-- LEFT JOIN room rm ON res.room_id = rm.room_id;

-- EJERCICIO 43 | Pagos y nombre del huésped
SELECT pay.payment_id, pay.amount, pay.status, c.name, c.surname
FROM payment pay
JOIN reservation res ON pay.reservation_id = res.reservation_id
JOIN client c ON res.client_id = c.client_id;

-- EJERCICIO 44 | Servicios asignados a cada habitación
SELECT r.name AS habitacion, f.name AS servicio
FROM room r
JOIN room_facility rf ON r.room_id = rf.room_id
JOIN facility f ON rf.facility_id = f.facility_id;

-- EJERCICIO 45 | Habitación, servicio, costo adicional y disponibilidad
SELECT r.name AS habitacion, f.name AS servicio,
       rf.costo_adicional, rf.disponibilidad
FROM room r
JOIN room_facility rf ON r.room_id = rf.room_id
JOIN facility f ON rf.facility_id = f.facility_id;

-- EJERCICIO 46 | Propiedades, anfitriones y reseñas
SELECT p.title AS propiedad, o.name AS anfitrion,
       rv.rating, rv.comment
FROM property p
JOIN owner o ON p.owner_id = o.owner_id
LEFT JOIN (
  SELECT res.property_id, re.rating, re.comment
  FROM review re JOIN reservation res ON re.reservation_id = res.reservation_id
  WHERE re.reservation_id IS NOT NULL
  UNION ALL
  SELECT v.property_id, re.rating, re.comment
  FROM review re JOIN visit v ON re.visit_id = v.visit_id
  WHERE re.visit_id IS NOT NULL
) rv ON p.property_id = rv.property_id;
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Variante completa: todas las habitaciones, su anfitrión y sus reseñas de estancia.
-- SELECT rm.name AS habitacion, o.name AS anfitrion, re.rating, re.comment
-- FROM room rm
-- JOIN property p ON rm.property_id = p.property_id
-- JOIN owner o ON p.owner_id = o.owner_id
-- LEFT JOIN reservation res ON rm.room_id = res.room_id
-- LEFT JOIN review re ON res.reservation_id = re.reservation_id;

-- EJERCICIO 47 | Reservas con huésped, anfitrión y propiedad
SELECT r.reservation_id, c.name AS huesped,
       o.name AS anfitrion, p.title AS propiedad
FROM reservation r
JOIN client c ON r.client_id = c.client_id
JOIN property p ON r.property_id = p.property_id
JOIN owner o ON p.owner_id = o.owner_id;

-- EJERCICIO 48 | Propiedades de Carlos Ramírez
SELECT p.title
FROM property p
JOIN owner o ON p.owner_id = o.owner_id
WHERE o.name = 'Carlos' AND o.surname = 'Ramírez';

-- EJERCICIO 49 | Reservas de Paula Ríos
SELECT r.reservation_id, r.start_date, r.end_date, r.status
FROM reservation r
JOIN client c ON r.client_id = c.client_id
WHERE c.name = 'Paula' AND c.surname = 'Ríos';

-- EJERCICIO 50 | Servicios de Loft Central
SELECT f.name AS servicio, rf.costo_adicional
FROM room r
JOIN room_facility rf ON r.room_id = rf.room_id
JOIN facility f ON rf.facility_id = f.facility_id
WHERE r.name = 'Loft Central';

-- EJERCICIO 51 | Huésped que reservó Suite Norte
SELECT DISTINCT c.name, c.surname
FROM client c
JOIN reservation res ON c.client_id = res.client_id
JOIN room r ON res.room_id = r.room_id
WHERE r.name = 'Suite Norte';

-- EJERCICIO 52 | Propiedades con al menos una reseña
SELECT DISTINCT p.property_id, p.title
FROM property p
WHERE EXISTS (
 SELECT 1 FROM review re
 LEFT JOIN reservation res ON re.reservation_id = res.reservation_id
 LEFT JOIN visit v ON re.visit_id = v.visit_id
 WHERE res.property_id = p.property_id OR v.property_id = p.property_id
);
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Variante completa por habitación:
-- SELECT r.room_id, r.name
-- FROM room r
-- WHERE EXISTS (
--  SELECT 1 FROM reservation res
--  JOIN review re ON re.reservation_id = res.reservation_id
--  WHERE res.room_id = r.room_id
-- );

-- EJERCICIO 53 | Propiedades sin reseñas registradas
SELECT p.property_id, p.title
FROM property p
LEFT JOIN (
 SELECT res.property_id FROM review re
 JOIN reservation res ON re.reservation_id = res.reservation_id
 UNION
 SELECT v.property_id FROM review re
 JOIN visit v ON re.visit_id = v.visit_id
) valoradas ON p.property_id = valoradas.property_id
WHERE valoradas.property_id IS NULL;
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Variante completa por habitación:
-- SELECT r.room_id, r.name
-- FROM room r
-- LEFT JOIN reservation res ON r.room_id = res.room_id
-- LEFT JOIN review re ON res.reservation_id = re.reservation_id
-- GROUP BY r.room_id, r.name
-- HAVING COUNT(re.review_id) = 0;

-- EJERCICIO 54 | Habitaciones con servicios asignados
SELECT DISTINCT r.room_id, r.name
FROM room r
JOIN room_facility rf ON r.room_id = rf.room_id;

-- EJERCICIO 55 | Habitaciones sin servicios asignados
SELECT r.room_id, r.name
FROM room r
LEFT JOIN room_facility rf ON r.room_id = rf.room_id
WHERE rf.room_id IS NULL;

-- EJERCICIO 56 | Total de anfitriones
SELECT COUNT(*) AS total FROM owner;

-- EJERCICIO 57 | Total de huéspedes
SELECT COUNT(*) AS total FROM client;

-- EJERCICIO 58 | Total de habitaciones publicadas
SELECT COUNT(*) AS total_habitaciones FROM room;

-- EJERCICIO 59 | Total de reservas
SELECT COUNT(*) AS total FROM reservation;

-- EJERCICIO 60 | Precio promedio de habitaciones
SELECT AVG(price) AS precio_promedio FROM room;

-- EJERCICIO 61 | Habitación más costosa
SELECT name, price FROM room ORDER BY price DESC LIMIT 1;

-- EJERCICIO 62 | Habitación más económica
SELECT name, price FROM room ORDER BY price ASC LIMIT 1;

-- EJERCICIO 63 | Ingresos acumulados de pagos
SELECT SUM(amount) AS ingresos
FROM payment
WHERE status = 'pagado';

-- EJERCICIO 64 | Cantidad de propiedades por tipo
SELECT property_type, COUNT(*) AS total
FROM property GROUP BY property_type;

-- EJERCICIO 65 | Cantidad de habitaciones por anfitrión
SELECT o.name, o.surname, COUNT(r.room_id) AS total_rooms
FROM owner o
JOIN property p ON o.owner_id = p.owner_id
JOIN room r ON p.property_id = r.property_id
GROUP BY o.owner_id, o.name, o.surname;
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Variante sencilla: contar propiedades por anfitrión.
-- SELECT o.name, o.surname, COUNT(p.property_id) AS total_propiedades
-- FROM owner o JOIN property p ON o.owner_id = p.owner_id
-- GROUP BY o.owner_id, o.name, o.surname;

-- EJERCICIO 66 | Reservas por huésped
SELECT c.client_id, c.name, c.surname, COUNT(r.reservation_id) AS total_reservas
FROM client c LEFT JOIN reservation r ON c.client_id = r.client_id
GROUP BY c.client_id, c.name, c.surname;

-- EJERCICIO 67 | Reservas por habitación
SELECT rm.room_id, rm.name, COUNT(r.reservation_id) AS total_reservas
FROM room rm LEFT JOIN reservation r ON rm.room_id = r.room_id
GROUP BY rm.room_id, rm.name;

-- EJERCICIO 68 | Servicios por habitación
SELECT r.room_id, r.name, COUNT(rf.facility_id) AS total_servicios
FROM room r LEFT JOIN room_facility rf ON r.room_id = rf.room_id
GROUP BY r.room_id, r.name;

-- EJERCICIO 69 | Precio promedio de propiedades por ciudad
SELECT c.name AS ciudad, AVG(p.price) AS precio_medio
FROM city c JOIN property p ON c.city_id = p.city_id
GROUP BY c.city_id, c.name;

-- EJERCICIO 70 | Anfitriones con más de una habitación
SELECT o.name, o.surname, COUNT(r.room_id) AS total_habitaciones
FROM owner o
JOIN property p ON o.owner_id = p.owner_id
JOIN room r ON p.property_id = r.property_id
GROUP BY o.owner_id, o.name, o.surname
HAVING COUNT(r.room_id) > 1;
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Variante sencilla: propietarios con más de una propiedad.
-- SELECT o.name, o.surname, COUNT(p.property_id) AS total_propiedades
-- FROM owner o JOIN property p ON o.owner_id = p.owner_id
-- GROUP BY o.owner_id, o.name, o.surname
-- HAVING COUNT(p.property_id) > 1;

-- EJERCICIO 71 | Tipos de propiedad con más de una publicación
SELECT property_type, COUNT(*) AS publicaciones
FROM property
GROUP BY property_type
HAVING COUNT(*) > 1;

-- EJERCICIO 72 | Huéspedes con más de una reserva
SELECT c.client_id, c.name, c.surname, COUNT(r.reservation_id) AS reservas
FROM client c JOIN reservation r ON c.client_id = r.client_id
GROUP BY c.client_id, c.name, c.surname
HAVING COUNT(r.reservation_id) > 1;

-- EJERCICIO 73 | Habitaciones con más de un servicio
SELECT r.room_id, r.name, COUNT(rf.facility_id) AS servicios
FROM room r JOIN room_facility rf ON r.room_id = rf.room_id
GROUP BY r.room_id, r.name
HAVING COUNT(rf.facility_id) > 1;
