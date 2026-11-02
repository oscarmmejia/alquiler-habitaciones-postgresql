# Catálogo de consultas SQL — Plataforma inmobiliaria de alquiler

**Base de datos:** `alquiler_habitaciones` · **Gestor:** PostgreSQL 18 · **Cliente:** pgAdmin 4.

Este repositorio documenta la implementación relacional y las consultas de la plataforma. Se usan las entidades `owner`, `client`, `property`, `room`, `reservation`, `payment`, `visit`, `review`, `facility` y `room_facility`, además de `country` y `city`.

Los precios están expresados en **euros por noche**. Algunas consultas de alojamiento usan `property` porque el atributo de tipo (`property_type`) y la ciudad se almacenan a nivel de propiedad; otras consultan `room`.

## Archivos de ejecución

Los scripts independientes están en la carpeta [`sql/`](../sql/). El archivo `README.md` de la raíz explica el orden de ejecución. Este catálogo reúne las consultas con su numeración y sus variantes.

> **Nota de numeración:** el enunciado utiliza el número **30** dos veces. Se identifica como **30A (LIKE)** y **30B (ORDER BY)** para conservar ambas consignas.

> **Modelo y alcance:** el esquema recoge las 12 tablas utilizadas en el proyecto académico. Las reseñas se relacionan con una visita o una reserva; los servicios se asignan a habitaciones mediante `room_facility`. La columna `room_type` no existe en el esquema, por lo que las consultas por tipo se expresan a nivel de propiedad.

## Consultas obligatorias (ejercicios 0–73)

## CREATE

### Ejercicio 0 — Crear las tablas del modelo relacional

Esquema con 12 tablas y relaciones PK/FK. La primera sentencia se ejecuta por separado, conectándose a la base postgres.

```sql
-- Crear la base de datos ejecutando esta instrucción desde 'postgres':
CREATE DATABASE alquiler_habitaciones;

-- Las siguientes sentencias se ejecutan después conectándose a alquiler_habitaciones.

CREATE TABLE owner (
 owner_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 surname VARCHAR(100) NOT NULL,
 email VARCHAR(150) UNIQUE NOT NULL,
 phone VARCHAR(20),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE country (
 country_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE city (
 city_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 country_id INTEGER NOT NULL REFERENCES country(country_id) ON DELETE RESTRICT
);

CREATE TABLE client (
 client_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 city_id INTEGER NOT NULL REFERENCES city(city_id) ON DELETE RESTRICT,
 name VARCHAR(100) NOT NULL,
 surname VARCHAR(100) NOT NULL,
 email VARCHAR(150) UNIQUE NOT NULL,
 phone VARCHAR(20),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE property (
 property_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 owner_id INTEGER NOT NULL REFERENCES owner(owner_id) ON DELETE RESTRICT,
 city_id INTEGER NOT NULL REFERENCES city(city_id) ON DELETE RESTRICT,
 title VARCHAR(150) NOT NULL,
 description TEXT,
 status VARCHAR(30) NOT NULL,
 property_type VARCHAR(50) NOT NULL,
 price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE room (
 room_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 property_id INTEGER NOT NULL REFERENCES property(property_id) ON DELETE RESTRICT,
 name VARCHAR(150) NOT NULL,
 description TEXT,
 status VARCHAR(30) NOT NULL,
 price NUMERIC(12,2) NOT NULL CHECK (price >= 0),
 capacity INTEGER NOT NULL CHECK (capacity > 0),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE facility (
 facility_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 name VARCHAR(100) UNIQUE NOT NULL,
 category VARCHAR(60) NOT NULL
);

CREATE TABLE room_facility (
 room_id INTEGER NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
 facility_id INTEGER NOT NULL REFERENCES facility(facility_id) ON DELETE CASCADE,
 verified BOOLEAN DEFAULT FALSE,
 costo_adicional NUMERIC(8,2) NOT NULL DEFAULT 0 CHECK (costo_adicional >= 0),
 disponibilidad BOOLEAN NOT NULL DEFAULT TRUE,
 PRIMARY KEY(room_id, facility_id)
);

CREATE TABLE reservation (
 reservation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 client_id INTEGER NOT NULL REFERENCES client(client_id) ON DELETE RESTRICT,
 property_id INTEGER NOT NULL REFERENCES property(property_id) ON DELETE RESTRICT,
 room_id INTEGER REFERENCES room(room_id) ON DELETE RESTRICT,
 status VARCHAR(30) NOT NULL CHECK (status IN ('pendiente','confirmada','cancelada','completada')),
 start_date DATE NOT NULL,
 end_date DATE NOT NULL,
 expires_at TIMESTAMP,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CHECK (end_date > start_date)
);

CREATE TABLE payment (
 payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 reservation_id INTEGER NOT NULL REFERENCES reservation(reservation_id) ON DELETE RESTRICT,
 amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
 payment_method VARCHAR(50) NOT NULL,
 status VARCHAR(30) NOT NULL CHECK (status IN ('pendiente','pagado','reembolsado')),
 paid_at TIMESTAMP
);

CREATE TABLE visit (
 visit_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 client_id INTEGER NOT NULL REFERENCES client(client_id) ON DELETE RESTRICT,
 property_id INTEGER NOT NULL REFERENCES property(property_id) ON DELETE RESTRICT,
 date TIMESTAMP NOT NULL,
 status VARCHAR(30) NOT NULL,
 confirmed_by_owner BOOLEAN NOT NULL DEFAULT FALSE,
 confirmed_by_client BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE review (
 review_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 reservation_id INTEGER REFERENCES reservation(reservation_id) ON DELETE RESTRICT,
 visit_id INTEGER REFERENCES visit(visit_id) ON DELETE RESTRICT,
 rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
 comment TEXT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CHECK ((reservation_id IS NOT NULL AND visit_id IS NULL)
     OR (reservation_id IS NULL AND visit_id IS NOT NULL))
);
```

## INSERT

### Ejercicio 1 — Insertar registros de ejemplo

Datos ficticios para practicar consultas y operaciones CRUD; importes expresados en euros por noche.

```sql
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
```

## READ

### Ejercicio 2 — Mostrar todos los anfitriones

Consulta todos los registros de `owner`.

```sql
SELECT * FROM owner;
```

### Ejercicio 3 — Mostrar todos los huéspedes

Consulta todos los registros de `client`.

```sql
SELECT * FROM client;
```

### Ejercicio 4 — Mostrar todas las habitaciones

Consulta todos los registros de `room`.

```sql
SELECT * FROM room;
```

### Ejercicio 5 — Mostrar todas las reservas

Consulta todos los registros de `reservation`.

```sql
SELECT * FROM reservation;
```

### Ejercicio 6 — Mostrar todos los pagos

Consulta todos los registros de `payment`.

```sql
SELECT * FROM payment;
```

### Ejercicio 7 — Nombre y correo de anfitriones

Proyecta solamente dos columnas.

```sql
SELECT name, email FROM owner;
```

### Ejercicio 8 — Título, tipo y ciudad de propiedades

Variante sencilla acorde con la ubicación de ciudad en Property.

```sql
SELECT p.title, p.property_type, c.name AS ciudad
FROM property p JOIN city c ON p.city_id = c.city_id;
```

**Otra variante de la consulta**
```sql
Variante completa del modelo: habitación → propiedad → ciudad:
SELECT r.name AS habitacion, p.property_type, c.name AS ciudad
FROM room r JOIN property p ON r.property_id = p.property_id
JOIN city c ON p.city_id = c.city_id;
```

### Ejercicio 9 — Nombre y teléfono de huéspedes

Permite mostrar solo los datos de contacto requeridos.

```sql
SELECT name, phone FROM client;
```

## UPDATE

### Ejercicio 10 — Actualizar el teléfono de un anfitrión

Modifica una fila específica mediante WHERE.

```sql
UPDATE owner SET phone = '612345679' WHERE owner_id = 1;
```

### Ejercicio 11 — Confirmar una reserva pendiente

Se valida el estado previo para evitar actualizaciones no deseadas.

```sql
UPDATE reservation SET status = 'confirmada' WHERE reservation_id = 4 AND status = 'pendiente';
```

### Ejercicio 12 — Actualizar precio de una habitación

Precio por noche en euros.

```sql
UPDATE room SET price = 70.00 WHERE room_id = 1;
```

### Ejercicio 13 — Modificar el costo adicional de un servicio

Se identifica la asignación mediante su PK compuesta.

```sql
UPDATE room_facility SET costo_adicional = 7.00 WHERE room_id = 1 AND facility_id = 3;
```

### Ejercicio 14 — Actualizar un pago y corregir fechas

El valor temporal se normaliza mediante un segundo UPDATE.

```sql
UPDATE payment SET amount = 210.00 WHERE reservation_id = 2;

-- Las fechas de pago se corrigen para que sean posteriores a la creación de reservas.
UPDATE payment SET paid_at = '2026-10-27' WHERE payment_id IN (1,2,3);
```

## DELETE

### Ejercicio 15 — Retirar un servicio de una habitación

Solo se elimina la asociación; ni habitación ni servicio se eliminan.

```sql
DELETE FROM room_facility WHERE room_id = 3 AND facility_id = 2;
```

### Ejercicio 16 — Eliminar una reserva concreta

Se elige una reserva sin pagos ni reseñas vinculados.

```sql
DELETE FROM reservation WHERE reservation_id = 4;
```

### Ejercicio 17 — Intentar eliminar una habitación con reservas

Error de FK esperado (`ON DELETE RESTRICT` de reservation): la habitación no se elimina. Ejecutar esta sentencia de manera individual.

```sql
DELETE FROM room WHERE room_id = 1;
```

### Ejercicio 18 — Intentar eliminar un anfitrión con propiedades

Error de FK esperado (`ON DELETE RESTRICT` de property). Ejecutar individualmente.

```sql
DELETE FROM owner WHERE owner_id = 1;
```

## WHERE

### Ejercicio 19 — Propiedades de tipo Apartamento

Variante sencilla con tipo existente en Property.

```sql
SELECT * FROM property WHERE property_type = 'Apartamento';
```

### Ejercicio 20 — Propiedades de tipo Casa

Se aplica el filtro sobre Property, que sí tiene columna de tipo.

```sql
SELECT * FROM property WHERE property_type = 'Casa';
```

### Ejercicio 21 — Reservas pendientes

```sql
SELECT * FROM reservation WHERE status = 'pendiente';
```

### Ejercicio 22 — Reservas confirmadas

```sql
SELECT * FROM reservation WHERE status = 'confirmada';
```

### Ejercicio 23 — Habitaciones con precio superior a 60 €

Equivalente adaptado a importes en euros.

```sql
SELECT * FROM room WHERE price > 60;
```

### Ejercicio 24 — Propiedades creadas después del 1 de enero de 2024

Se usa created_at como fecha de registro y se excluye completamente el 1 de enero.

```sql
SELECT * FROM property WHERE created_at >= DATE '2024-01-02';
```

### Ejercicio 25 — Anfitriones llamados Carlos

```sql
SELECT * FROM owner WHERE name = 'Carlos';
```

## LIKE

### Ejercicio 26 — Anfitriones cuyo nombre empieza por L

Con los datos iniciales, puede devolver cero filas.

```sql
SELECT * FROM owner WHERE name LIKE 'L%';
```

### Ejercicio 27 — Huéspedes cuyo nombre empieza por M

```sql
SELECT * FROM client WHERE name LIKE 'M%';
```

### Ejercicio 28 — Propiedades con Centro en el título

```sql
SELECT * FROM property WHERE title LIKE '%Centro%';
```

### Ejercicio 29 — Servicios cuyos nombres terminan en Fi

```sql
SELECT * FROM facility WHERE name LIKE '%Fi';
```

### Ejercicio 30A — Propiedades ubicadas en ciudades que contienen a

Busca la letra a, también con tilde, sin distinguir mayúsculas.

```sql
SELECT p.title, c.name AS ciudad
FROM property p
JOIN city c ON p.city_id = c.city_id
WHERE c.name ILIKE '%a%' OR c.name ILIKE '%á%';
```

## ORDER BY

### Ejercicio 30B — Propiedades ordenadas alfabéticamente por título

El enunciado repite el número 30; se etiqueta 30b para conservar ambas consultas.

```sql
SELECT * FROM property ORDER BY title ASC;
```

### Ejercicio 31 — Habitaciones de mayor a menor precio

```sql
SELECT * FROM room ORDER BY price DESC;
```

### Ejercicio 32 — Reservas ordenadas por fecha de check-in

ASC ordena de fecha anterior a posterior.

```sql
SELECT * FROM reservation ORDER BY start_date ASC;
```

### Ejercicio 33 — Anfitriones por nombre descendente

```sql
SELECT * FROM owner ORDER BY name DESC;
```

## BETWEEN / IN

### Ejercicio 34 — Habitaciones entre 40 € y 80 €

BETWEEN incluye ambos límites.

```sql
SELECT * FROM room WHERE price BETWEEN 40 AND 80;
```

### Ejercicio 35 — Propiedades de tipo Apartamento o Casa

Adaptación de la clasificación de tipo: Room no dispone de room_type.

```sql
SELECT * FROM property WHERE property_type IN ('Apartamento','Casa');
```

### Ejercicio 36 — Reservas pendientes o confirmadas

```sql
SELECT * FROM reservation WHERE status IN ('pendiente','confirmada');
```

### Ejercicio 37 — Propiedades en Bogotá o Medellín

```sql
SELECT p.title, c.name AS ciudad
FROM property p JOIN city c ON p.city_id = c.city_id
WHERE c.name IN ('Bogotá','Medellín');
```

**Otra variante de la consulta**
```sql
Versión por habitaciones:
SELECT r.name AS habitacion, c.name AS ciudad
FROM room r
JOIN property p ON r.property_id = p.property_id
JOIN city c ON p.city_id = c.city_id
WHERE c.name IN ('Bogotá','Medellín');
```

## JOIN

### Ejercicio 38 — Propiedad y su anfitrión

Variante sencilla con un JOIN.

```sql
SELECT p.title, o.name, o.surname
FROM owner o
JOIN property p ON p.owner_id = o.owner_id;
```

**Otra variante de la consulta**
```sql
Variante completa para habitación y anfitrión:
SELECT r.name AS habitacion, o.name, o.surname
FROM owner o
JOIN property p ON o.owner_id = p.owner_id
JOIN room r ON p.property_id = r.property_id;
```

### Ejercicio 39 — Título, tipo y anfitrión de propiedades

`property_type` es atributo de Property.

```sql
SELECT p.title, p.property_type, o.name, o.surname
FROM property p JOIN owner o ON p.owner_id = o.owner_id;
```

### Ejercicio 40 — Reservas y nombre del huésped

```sql
SELECT r.reservation_id, c.name, c.surname, r.status
FROM reservation r JOIN client c ON r.client_id = c.client_id;
```

### Ejercicio 41 — Reservas y nombre de habitación

LEFT JOIN conserva la reserva de la propiedad completa, que tiene room_id NULL.

```sql
SELECT res.reservation_id, r.name AS habitacion, res.status
FROM reservation res
LEFT JOIN room r ON res.room_id = r.room_id;
```

### Ejercicio 42 — Reserva, huésped, alojamiento, fechas y estado

Variante sencilla que identifica el alojamiento a través de Property.

```sql
SELECT r.reservation_id, c.name, c.surname, p.title,
       r.start_date, r.end_date, r.status
FROM reservation r
JOIN client c ON r.client_id = c.client_id
JOIN property p ON r.property_id = p.property_id;
```

**Otra variante de la consulta**
```sql
Variante completa con habitación (y reservas de propiedad completa):
SELECT res.reservation_id, c.name, c.surname,
       p.title AS propiedad, rm.name AS habitacion,
       res.start_date, res.end_date, res.status
FROM reservation res
JOIN client c ON res.client_id = c.client_id
JOIN property p ON res.property_id = p.property_id
LEFT JOIN room rm ON res.room_id = rm.room_id;
```

### Ejercicio 43 — Pagos y nombre del huésped

```sql
SELECT pay.payment_id, pay.amount, pay.status, c.name, c.surname
FROM payment pay
JOIN reservation res ON pay.reservation_id = res.reservation_id
JOIN client c ON res.client_id = c.client_id;
```

### Ejercicio 44 — Servicios asignados a cada habitación

Dos JOIN recorren la tabla intermedia N:M.

```sql
SELECT r.name AS habitacion, f.name AS servicio
FROM room r
JOIN room_facility rf ON r.room_id = rf.room_id
JOIN facility f ON rf.facility_id = f.facility_id;
```

### Ejercicio 45 — Habitación, servicio, costo adicional y disponibilidad

```sql
SELECT r.name AS habitacion, f.name AS servicio,
       rf.costo_adicional, rf.disponibilidad
FROM room r
JOIN room_facility rf ON r.room_id = rf.room_id
JOIN facility f ON rf.facility_id = f.facility_id;
```

### Ejercicio 46 — Propiedades, anfitriones y reseñas

Una reseña puede pertenecer a visita o reserva; ambas vías se unen para consultar reseñas por propiedad. El LEFT JOIN conserva propiedades sin reseñas.

```sql
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
```

**Otra variante de la consulta**
```sql
Variante completa: todas las habitaciones, su anfitrión y sus reseñas de estancia.
SELECT rm.name AS habitacion, o.name AS anfitrion, re.rating, re.comment
FROM room rm
JOIN property p ON rm.property_id = p.property_id
JOIN owner o ON p.owner_id = o.owner_id
LEFT JOIN reservation res ON rm.room_id = res.room_id
LEFT JOIN review re ON res.reservation_id = re.reservation_id;
```

### Ejercicio 47 — Reservas con huésped, anfitrión y propiedad

```sql
SELECT r.reservation_id, c.name AS huesped,
       o.name AS anfitrion, p.title AS propiedad
FROM reservation r
JOIN client c ON r.client_id = c.client_id
JOIN property p ON r.property_id = p.property_id
JOIN owner o ON p.owner_id = o.owner_id;
```

## JOIN negocio

### Ejercicio 48 — Propiedades de Carlos Ramírez

```sql
SELECT p.title
FROM property p
JOIN owner o ON p.owner_id = o.owner_id
WHERE o.name = 'Carlos' AND o.surname = 'Ramírez';
```

### Ejercicio 49 — Reservas de Paula Ríos

```sql
SELECT r.reservation_id, r.start_date, r.end_date, r.status
FROM reservation r
JOIN client c ON r.client_id = c.client_id
WHERE c.name = 'Paula' AND c.surname = 'Ríos';
```

### Ejercicio 50 — Servicios de Loft Central

```sql
SELECT f.name AS servicio, rf.costo_adicional
FROM room r
JOIN room_facility rf ON r.room_id = rf.room_id
JOIN facility f ON rf.facility_id = f.facility_id
WHERE r.name = 'Loft Central';
```

### Ejercicio 51 — Huésped que reservó Suite Norte

```sql
SELECT DISTINCT c.name, c.surname
FROM client c
JOIN reservation res ON c.client_id = res.client_id
JOIN room r ON res.room_id = r.room_id
WHERE r.name = 'Suite Norte';
```

### Ejercicio 52 — Propiedades con al menos una reseña

Se consultan reseñas de visita o reserva sin atribuir reseñas de propiedad a habitaciones concretas.

```sql
SELECT DISTINCT p.property_id, p.title
FROM property p
WHERE EXISTS (
 SELECT 1 FROM review re
 LEFT JOIN reservation res ON re.reservation_id = res.reservation_id
 LEFT JOIN visit v ON re.visit_id = v.visit_id
 WHERE res.property_id = p.property_id OR v.property_id = p.property_id
);
```

**Otra variante de la consulta**
```sql
Variante completa por habitación:
SELECT r.room_id, r.name
FROM room r
WHERE EXISTS (
 SELECT 1 FROM reservation res
 JOIN review re ON re.reservation_id = res.reservation_id
 WHERE res.room_id = r.room_id
);
```

### Ejercicio 53 — Propiedades sin reseñas registradas

LEFT JOIN + IS NULL identifica propiedades sin reseñas de ningún origen.

```sql
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
```

**Otra variante de la consulta**
```sql
Variante completa por habitación:
SELECT r.room_id, r.name
FROM room r
LEFT JOIN reservation res ON r.room_id = res.room_id
LEFT JOIN review re ON res.reservation_id = re.reservation_id
GROUP BY r.room_id, r.name
HAVING COUNT(re.review_id) = 0;
```

### Ejercicio 54 — Habitaciones con servicios asignados

```sql
SELECT DISTINCT r.room_id, r.name
FROM room r
JOIN room_facility rf ON r.room_id = rf.room_id;
```

### Ejercicio 55 — Habitaciones sin servicios asignados

LEFT JOIN + IS NULL encuentra relaciones ausentes.

```sql
SELECT r.room_id, r.name
FROM room r
LEFT JOIN room_facility rf ON r.room_id = rf.room_id
WHERE rf.room_id IS NULL;
```

## Agregación

### Ejercicio 56 — Total de anfitriones

Cuenta registros en la tabla.

```sql
SELECT COUNT(*) AS total FROM owner;
```

### Ejercicio 57 — Total de huéspedes

Cuenta registros en la tabla.

```sql
SELECT COUNT(*) AS total FROM client;
```

### Ejercicio 58 — Total de habitaciones publicadas

Room no tiene columna 'publicada'; el recuento incluye todas las habitaciones registradas.

```sql
SELECT COUNT(*) AS total_habitaciones FROM room;
```

### Ejercicio 59 — Total de reservas

Cuenta registros en la tabla.

```sql
SELECT COUNT(*) AS total FROM reservation;
```

### Ejercicio 60 — Precio promedio de habitaciones

AVG ignora valores NULL; aquí el precio es obligatorio.

```sql
SELECT AVG(price) AS precio_promedio FROM room;
```

### Ejercicio 61 — Habitación más costosa

LIMIT 1 devuelve una habitación; ante empates puede elegirse una arbitrariamente.

```sql
SELECT name, price FROM room ORDER BY price DESC LIMIT 1;
```

### Ejercicio 62 — Habitación más económica

```sql
SELECT name, price FROM room ORDER BY price ASC LIMIT 1;
```

### Ejercicio 63 — Ingresos acumulados de pagos

Se contabilizan únicamente pagos con estado pagado.

```sql
SELECT SUM(amount) AS ingresos
FROM payment
WHERE status = 'pagado';
```

## GROUP BY

### Ejercicio 64 — Cantidad de propiedades por tipo

La clasificación de tipo está en Property.

```sql
SELECT property_type, COUNT(*) AS total
FROM property GROUP BY property_type;
```

### Ejercicio 65 — Cantidad de habitaciones por anfitrión

Versión completa con dos JOIN.

```sql
SELECT o.name, o.surname, COUNT(r.room_id) AS total_rooms
FROM owner o
JOIN property p ON o.owner_id = p.owner_id
JOIN room r ON p.property_id = r.property_id
GROUP BY o.owner_id, o.name, o.surname;
```

**Otra variante de la consulta**
```sql
Variante sencilla: contar propiedades por anfitrión.
SELECT o.name, o.surname, COUNT(p.property_id) AS total_propiedades
FROM owner o JOIN property p ON o.owner_id = p.owner_id
GROUP BY o.owner_id, o.name, o.surname;
```

### Ejercicio 66 — Reservas por huésped

LEFT JOIN incluye huéspedes con cero reservas.

```sql
SELECT c.client_id, c.name, c.surname, COUNT(r.reservation_id) AS total_reservas
FROM client c LEFT JOIN reservation r ON c.client_id = r.client_id
GROUP BY c.client_id, c.name, c.surname;
```

### Ejercicio 67 — Reservas por habitación

Las reservas de propiedad completa no se asignan artificialmente a una habitación.

```sql
SELECT rm.room_id, rm.name, COUNT(r.reservation_id) AS total_reservas
FROM room rm LEFT JOIN reservation r ON rm.room_id = r.room_id
GROUP BY rm.room_id, rm.name;
```

### Ejercicio 68 — Servicios por habitación

Cuenta cero cuando no hay asignaciones.

```sql
SELECT r.room_id, r.name, COUNT(rf.facility_id) AS total_servicios
FROM room r LEFT JOIN room_facility rf ON r.room_id = rf.room_id
GROUP BY r.room_id, r.name;
```

### Ejercicio 69 — Precio promedio de propiedades por ciudad

La relación directa Property–City evita unir Room.

```sql
SELECT c.name AS ciudad, AVG(p.price) AS precio_medio
FROM city c JOIN property p ON c.city_id = p.city_id
GROUP BY c.city_id, c.name;
```

## HAVING

### Ejercicio 70 — Anfitriones con más de una habitación

Variante completa, usando dos JOIN y HAVING.

```sql
SELECT o.name, o.surname, COUNT(r.room_id) AS total_habitaciones
FROM owner o
JOIN property p ON o.owner_id = p.owner_id
JOIN room r ON p.property_id = r.property_id
GROUP BY o.owner_id, o.name, o.surname
HAVING COUNT(r.room_id) > 1;
```

**Otra variante de la consulta**
```sql
Variante sencilla: propietarios con más de una propiedad.
SELECT o.name, o.surname, COUNT(p.property_id) AS total_propiedades
FROM owner o JOIN property p ON o.owner_id = p.owner_id
GROUP BY o.owner_id, o.name, o.surname
HAVING COUNT(p.property_id) > 1;
```

### Ejercicio 71 — Tipos de propiedad con más de una publicación

Con los datos iniciales puede no haber grupos con más de una publicación.

```sql
SELECT property_type, COUNT(*) AS publicaciones
FROM property
GROUP BY property_type
HAVING COUNT(*) > 1;
```

### Ejercicio 72 — Huéspedes con más de una reserva

```sql
SELECT c.client_id, c.name, c.surname, COUNT(r.reservation_id) AS reservas
FROM client c JOIN reservation r ON c.client_id = r.client_id
GROUP BY c.client_id, c.name, c.surname
HAVING COUNT(r.reservation_id) > 1;
```

### Ejercicio 73 — Habitaciones con más de un servicio

```sql
SELECT r.room_id, r.name, COUNT(rf.facility_id) AS servicios
FROM room r JOIN room_facility rf ON r.room_id = rf.room_id
GROUP BY r.room_id, r.name
HAVING COUNT(rf.facility_id) > 1;
```

## Nivel IV — ejercicios opcionales incluidos

### Ejercicio 74 — Habitaciones por encima del precio promedio

Subconsulta escalar con AVG.

```sql
SELECT r.name, r.price
FROM room r
WHERE r.price > (SELECT AVG(price) FROM room);
```

### Ejercicio 77 — Habitaciones sin reservas

NOT EXISTS evita confusiones con valores NULL.

```sql
SELECT r.room_id, r.name
FROM room r
WHERE NOT EXISTS (
  SELECT 1 FROM reservation res WHERE res.room_id = r.room_id
);
```

### Ejercicio 79 — Huéspedes con reservas confirmadas

```sql
SELECT c.client_id, c.name, c.surname
FROM client c
WHERE EXISTS (
  SELECT 1 FROM reservation res
  WHERE res.client_id = c.client_id AND res.status = 'confirmada'
);
```

### Ejercicio 82 — Anfitriones sin propiedades

Se utiliza Property como alojamiento vinculado a Owner.

```sql
SELECT o.owner_id, o.name, o.surname
FROM owner o LEFT JOIN property p ON o.owner_id = p.owner_id
WHERE p.property_id IS NULL;
```

### Ejercicio 91 — Huéspedes por cantidad de reservas

```sql
SELECT c.client_id, c.name, c.surname,
       COUNT(res.reservation_id) AS reservas
FROM client c
LEFT JOIN reservation res ON c.client_id = res.client_id
GROUP BY c.client_id, c.name, c.surname
ORDER BY reservas DESC, c.surname ASC;
```

### Ejercicio 93 — Habitaciones con reservas pero sin servicios

Con la reserva 4 eliminada, puede no haber resultados.

```sql
SELECT r.room_id, r.name
FROM room r
WHERE EXISTS (SELECT 1 FROM reservation res WHERE res.room_id = r.room_id)
  AND NOT EXISTS (SELECT 1 FROM room_facility rf WHERE rf.room_id = r.room_id);
```

### Ejercicio 94 — Servicios nunca asignados

```sql
SELECT f.facility_id, f.name
FROM facility f
LEFT JOIN room_facility rf ON f.facility_id = rf.facility_id
WHERE rf.facility_id IS NULL;
```

### Ejercicio 95 — Ingresos pagados por habitación

Las reservas de propiedad completa (room_id NULL) se excluyen correctamente del desglose por habitación; por ello este total puede diferir de los ingresos generales.

```sql
SELECT r.room_id, r.name,
       COALESCE(SUM(CASE WHEN pay.status = 'pagado' THEN pay.amount ELSE 0 END),0) AS ingresos_eur
FROM room r
LEFT JOIN reservation res ON r.room_id = res.room_id
LEFT JOIN payment pay ON res.reservation_id = pay.reservation_id
GROUP BY r.room_id, r.name
ORDER BY ingresos_eur DESC;
```

## Parte 17 — Preguntas de análisis

### Pregunta 97 — Relación 1:1 entre reservas y pagos
Para implementar una relación 1:1, la tabla `payment` debe contener una clave foránea (`reservation_id`) que haga referencia a `reservation`, acompañada de una restricción `UNIQUE` que impida asociar varios pagos a una misma reserva.

En nuestra implementación utilizamos una relación **1:N**, porque una reserva puede tener varios pagos, por ejemplo, un anticipo y un pago final. La clave foránea garantiza que cada pago pertenezca a una reserva existente, pero no limita la cantidad de pagos por reserva.

Además, si se quisiera exigir que todas las reservas tuvieran exactamente un pago, sería necesario garantizar también esa obligatoriedad, ya que `FOREIGN KEY` + `UNIQUE` solo asegura que cada reserva tenga como máximo un pago.

### Pregunta 98 — Relación muchos a muchos entre habitaciones y servicios
La tabla intermedia `room_facility` implementa la relación muchos a muchos mediante las claves foráneas `room_id` y `facility_id`, que forman una clave primaria compuesta. Para demostrarla, se cuentan las asignaciones agrupadas primero por habitación y después por servicio. Si una habitación tiene varios servicios y un mismo servicio pertenece a varias habitaciones, se observa la cardinalidad N:M.

```sql
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
```

### Pregunta 99 — Diferencia entre JOIN y LEFT JOIN
`JOIN` (o `INNER JOIN`) devuelve únicamente las filas con coincidencias entre las tablas relacionadas. `LEFT JOIN` conserva todas las filas de la tabla izquierda, aunque no exista una fila correspondiente en la tabla derecha; en ese caso, las columnas de la derecha aparecen como `NULL`. Por ejemplo, `LEFT JOIN` junto con `IS NULL` permite localizar habitaciones sin servicios.

### Pregunta 100 — Uso de subconsulta frente a JOIN
Se puede utilizar una subconsulta cuando el resultado de otra consulta sirve como condición o referencia para filtrar datos. Por ejemplo, para buscar habitaciones cuyo precio supere el promedio general, una subconsulta calcula `AVG(price)` y la consulta externa compara cada precio con ese valor. En cambio, `JOIN` resulta apropiado cuando se necesitan combinar columnas relacionadas de varias tablas.

```sql
-- Pregunta 100: subconsulta frente al precio promedio
SELECT name, price
FROM room
WHERE price > (SELECT AVG(price) FROM room);
```

## Notas de integridad y lectura de resultados

- `property` posee ciudad y anfitrión; `room` pertenece a una propiedad. Cuando se consultan los dos niveles, se recorre `owner → property → room`.
- Las reservas de propiedades completas tienen `reservation.room_id IS NULL`; no se atribuyen a una habitación en las estadísticas.
- La implementación actual de `payment` es **1:N** con respecto a `reservation`. En una relación 1:1, una restricción `UNIQUE` sobre la FK limitaría el máximo a un pago por reserva.
- `room_facility` utiliza `ON DELETE CASCADE` para borrar asociaciones, mientras que las reservas y pagos utilizan `ON DELETE RESTRICT` para proteger los registros relacionados.
- Puede haber consultas con cero resultados: eso no implica que la sentencia SQL sea errónea.
