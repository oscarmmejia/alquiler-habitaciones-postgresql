-- Pregunta 98: una habitación con varios servicios
SELECT room_id, COUNT(*) AS total_servicios
FROM room_facility
GROUP BY room_id
HAVING COUNT(*) > 1;

-- Pregunta 98: un servicio compartido por varias habitaciones
SELECT facility_id, COUNT(*) AS total_habitaciones
FROM room_facility
GROUP BY facility_id
HAVING COUNT(*) > 1;

-- Pregunta 100: subconsulta frente al precio promedio
SELECT name, price
FROM room
WHERE price > (SELECT AVG(price) FROM room);
