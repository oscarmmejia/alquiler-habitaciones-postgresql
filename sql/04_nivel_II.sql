-- Ejercicios numerados del enunciado. Ejecutar sentencias por separado en pgAdmin.
-- Algunas variantes se proporcionan comentadas y pueden ejecutarse de forma independiente.
-- EJERCICIO 19 | Propiedades de tipo Apartamento
SELECT * FROM property WHERE property_type = 'Apartamento';

-- EJERCICIO 20 | Propiedades de tipo Casa
SELECT * FROM property WHERE property_type = 'Casa';

-- EJERCICIO 21 | Reservas pendientes
SELECT * FROM reservation WHERE status = 'pendiente';

-- EJERCICIO 22 | Reservas confirmadas
SELECT * FROM reservation WHERE status = 'confirmada';

-- EJERCICIO 23 | Habitaciones con precio superior a 60 €
SELECT * FROM room WHERE price > 60;

-- EJERCICIO 24 | Propiedades creadas después del 1 de enero de 2024
SELECT * FROM property WHERE created_at >= DATE '2024-01-02';

-- EJERCICIO 25 | Anfitriones llamados Carlos
SELECT * FROM owner WHERE name = 'Carlos';

-- EJERCICIO 26 | Anfitriones cuyo nombre empieza por L
SELECT * FROM owner WHERE name LIKE 'L%';

-- EJERCICIO 27 | Huéspedes cuyo nombre empieza por M
SELECT * FROM client WHERE name LIKE 'M%';

-- EJERCICIO 28 | Propiedades con Centro en el título
SELECT * FROM property WHERE title LIKE '%Centro%';

-- EJERCICIO 29 | Servicios cuyos nombres terminan en Fi
SELECT * FROM facility WHERE name LIKE '%Fi';

-- EJERCICIO 30 | Propiedades ubicadas en ciudades que contienen a
SELECT p.title, c.name AS ciudad
FROM property p
JOIN city c ON p.city_id = c.city_id
WHERE c.name ILIKE '%a%' OR c.name ILIKE '%á%';

-- EJERCICIO 30b | Propiedades ordenadas alfabéticamente por título
SELECT * FROM property ORDER BY title ASC;

-- EJERCICIO 31 | Habitaciones de mayor a menor precio
SELECT * FROM room ORDER BY price DESC;

-- EJERCICIO 32 | Reservas ordenadas por fecha de check-in
SELECT * FROM reservation ORDER BY start_date ASC;

-- EJERCICIO 33 | Anfitriones por nombre descendente
SELECT * FROM owner ORDER BY name DESC;

-- EJERCICIO 34 | Habitaciones entre 40 € y 80 €
SELECT * FROM room WHERE price BETWEEN 40 AND 80;

-- EJERCICIO 35 | Propiedades de tipo Apartamento o Casa
SELECT * FROM property WHERE property_type IN ('Apartamento','Casa');

-- EJERCICIO 36 | Reservas pendientes o confirmadas
SELECT * FROM reservation WHERE status IN ('pendiente','confirmada');

-- EJERCICIO 37 | Propiedades en Bogotá o Medellín
SELECT p.title, c.name AS ciudad
FROM property p JOIN city c ON p.city_id = c.city_id
WHERE c.name IN ('Bogotá','Medellín');
-- VARIANTE ADICIONAL (consulta de referencia; ejecutar por separado):
-- Versión por habitaciones:
-- SELECT r.name AS habitacion, c.name AS ciudad
-- FROM room r
-- JOIN property p ON r.property_id = p.property_id
-- JOIN city c ON p.city_id = c.city_id
-- WHERE c.name IN ('Bogotá','Medellín');
