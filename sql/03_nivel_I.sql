-- Nivel I · Ejercicios 2–18. Ejecutar de forma individual o por bloques controlados.
-- Los intentos de borrado 17 y 18 producen errores de FK de manera intencionada.


-- EJERCICIO 2 | Mostrar todos los anfitriones
SELECT * FROM owner;

-- EJERCICIO 3 | Mostrar todos los huéspedes
SELECT * FROM client;

-- EJERCICIO 4 | Mostrar todas las habitaciones
SELECT * FROM room;

-- EJERCICIO 5 | Mostrar todas las reservas
SELECT * FROM reservation;

-- EJERCICIO 6 | Mostrar todos los pagos
SELECT * FROM payment;

-- EJERCICIO 7 | Nombre y correo de anfitriones
SELECT name, email FROM owner;

-- EJERCICIO 8 | Título, tipo y ciudad de propiedades
SELECT p.title, p.property_type, c.name AS ciudad
FROM property p JOIN city c ON p.city_id = c.city_id;
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Variante completa del modelo: habitación → propiedad → ciudad:
-- SELECT r.name AS habitacion, p.property_type, c.name AS ciudad
-- FROM room r JOIN property p ON r.property_id = p.property_id
-- JOIN city c ON p.city_id = c.city_id;

-- EJERCICIO 9 | Nombre y teléfono de huéspedes
SELECT name, phone FROM client;

-- EJERCICIO 10 | Actualizar el teléfono de un anfitrión
UPDATE owner SET phone = '612345679' WHERE owner_id = 1;

-- EJERCICIO 11 | Confirmar una reserva pendiente
UPDATE reservation SET status = 'confirmada' WHERE reservation_id = 4 AND status = 'pendiente';

-- EJERCICIO 12 | Actualizar precio de una habitación
UPDATE room SET price = 70.00 WHERE room_id = 1;

-- EJERCICIO 13 | Modificar el costo adicional de un servicio
UPDATE room_facility SET costo_adicional = 7.00 WHERE room_id = 1 AND facility_id = 3;

-- EJERCICIO 14 | Actualizar un pago y corregir fechas
UPDATE payment SET amount = 210.00 WHERE reservation_id = 2;

-- Las fechas de pago se corrigen para que sean posteriores a la creación de reservas.
UPDATE payment SET paid_at = '2026-10-27' WHERE payment_id IN (1,2,3);

-- EJERCICIO 15 | Retirar un servicio de una habitación
DELETE FROM room_facility WHERE room_id = 3 AND facility_id = 2;

-- EJERCICIO 16 | Eliminar una reserva concreta
DELETE FROM reservation WHERE reservation_id = 4;

-- EJERCICIO 17 | Intentar eliminar una habitación con reservas
-- PRUEBA DE RESTRICCIÓN: error de FK esperado; ejecutar de forma individual.
DELETE FROM room WHERE room_id = 1;

-- EJERCICIO 18 | Intentar eliminar un anfitrión con propiedades
-- PRUEBA DE RESTRICCIÓN: error de FK esperado; ejecutar de forma individual.
DELETE FROM owner WHERE owner_id = 1;
