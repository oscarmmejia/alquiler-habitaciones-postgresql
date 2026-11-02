-- Ejercicio 74: Habitaciones por encima del precio promedio
SELECT r.name, r.price
FROM room r
WHERE r.price > (SELECT AVG(price) FROM room);

-- Ejercicio 77: Habitaciones sin reservas
SELECT r.room_id, r.name
FROM room r
WHERE NOT EXISTS (
  SELECT 1 FROM reservation res WHERE res.room_id = r.room_id
);

-- Ejercicio 79: Huéspedes con reservas confirmadas
SELECT c.client_id, c.name, c.surname
FROM client c
WHERE EXISTS (
  SELECT 1 FROM reservation res
  WHERE res.client_id = c.client_id AND res.status = 'confirmada'
);

-- Ejercicio 82: Anfitriones sin propiedades
SELECT o.owner_id, o.name, o.surname
FROM owner o LEFT JOIN property p ON o.owner_id = p.owner_id
WHERE p.property_id IS NULL;

-- Ejercicio 91: Huéspedes por cantidad de reservas
SELECT c.client_id, c.name, c.surname,
       COUNT(res.reservation_id) AS reservas
FROM client c
LEFT JOIN reservation res ON c.client_id = res.client_id
GROUP BY c.client_id, c.name, c.surname
ORDER BY reservas DESC, c.surname ASC;

-- Ejercicio 93: Habitaciones con reservas pero sin servicios
SELECT r.room_id, r.name
FROM room r
WHERE EXISTS (SELECT 1 FROM reservation res WHERE res.room_id = r.room_id)
  AND NOT EXISTS (SELECT 1 FROM room_facility rf WHERE rf.room_id = r.room_id);

-- Ejercicio 94: Servicios nunca asignados
SELECT f.facility_id, f.name
FROM facility f
LEFT JOIN room_facility rf ON f.facility_id = rf.facility_id
WHERE rf.facility_id IS NULL;

-- Ejercicio 95: Ingresos pagados por habitación
SELECT r.room_id, r.name,
       COALESCE(SUM(CASE WHEN pay.status = 'pagado' THEN pay.amount ELSE 0 END),0) AS ingresos_eur
FROM room r
LEFT JOIN reservation res ON r.room_id = res.room_id
LEFT JOIN payment pay ON res.reservation_id = pay.reservation_id
GROUP BY r.room_id, r.name
ORDER BY ingresos_eur DESC;
