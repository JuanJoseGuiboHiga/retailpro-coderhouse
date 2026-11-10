-- Motor utilizado: PostgreSQL
-- Base de datos: Ventas_Tech_DB

-- === SECCIÓN 1: DROP TABLES ===
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS metas;
DROP TABLE IF EXISTS territorios;
DROP TABLE IF EXISTS regiones;
DROP TABLE IF EXISTS zonas;
DROP TABLE IF EXISTS paises;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS subcategorias;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS segmentos;
DROP TABLE IF EXISTS ciudades;


-- === SECCIÓN 2: CREATE TABLES ===

-- 1. Dimensiones de Clientes y Productos
CREATE TABLE categorias (
	id_categoria INT PRIMARY KEY,
	nombre_categoria VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200)
);

CREATE TABLE subcategorias (
	id_subcategoria INT PRIMARY KEY,
	nombre_subcategoria VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200)
);

CREATE TABLE ciudades (
	id_ciudad INT PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL
);

CREATE TABLE segmentos (
	id_segmento INT PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL
);

CREATE TABLE clientes (
	id_cliente INT PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	email VARCHAR(100) UNIQUE,
	id_ciudad INT NOT NULL,
	id_segmento INT NOT NULL,
	fecha_registro DATE NOT NULL,

	CONSTRAINT fk_ciudades
		FOREIGN KEY (id_ciudad)
		REFERENCES ciudades(id_ciudad),
	CONSTRAINT fk_segmentos
		FOREIGN KEY (id_segmento)
		REFERENCES segmentos(id_segmento)
);

CREATE TABLE productos (
	id_producto INT PRIMARY KEY,
	nombre_producto VARCHAR(100) NOT NULL,
	id_categoria INT NOT NULL,
	id_subcategoria INT NOT NULL,
	precio DECIMAL(10,2) NOT NULL,
	stock INT DEFAULT 0,
	activo BOOLEAN DEFAULT TRUE,
	
	CONSTRAINT fk_categorias
		FOREIGN KEY (id_categoria)
		REFERENCES categorias(id_categoria),
	CONSTRAINT fk_subcategorias
		FOREIGN KEY (id_subcategoria)
		REFERENCES subcategorias(id_subcategoria)
);

-- 2. Dimensiones Geográficas y Territoriales (deben crearse ANTES de ventas)
CREATE TABLE paises (
	id_pais INT PRIMARY KEY,
	nombre_pais VARCHAR(50) NOT NULL
);

CREATE TABLE zonas (
	id_zona INT PRIMARY KEY,
	nombre_zona VARCHAR(50) NOT NULL
);

CREATE TABLE regiones (
	id_region INT PRIMARY KEY,
	nombre_region VARCHAR(50) NOT NULL
);

CREATE TABLE territorios (
	id_territorio INT PRIMARY KEY,
	id_region INT NOT NULL,
	id_pais INT NOT NULL,
	id_zona INT NOT NULL,
	nombre_territorio VARCHAR(50) NOT NULL,
	
	CONSTRAINT fk_regiones
		FOREIGN KEY (id_region)
		REFERENCES regiones(id_region),
	CONSTRAINT fk_paises
		FOREIGN KEY (id_pais)
		REFERENCES paises(id_pais),
	CONSTRAINT fk_zonas
		FOREIGN KEY (id_zona)
		REFERENCES zonas(id_zona)
);

CREATE TABLE metas (
	id_meta INT PRIMARY KEY,
	id_region INT NOT NULL,
	nombre_meta VARCHAR(50) NOT NULL,
	monto_meta DECIMAL(10,2) NOT NULL,
	estado_meta BOOLEAN DEFAULT TRUE,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,

	CONSTRAINT fk_metas_regiones
		FOREIGN KEY (id_region)
		REFERENCES regiones(id_region)
);

-- 3. Tabla de Hechos (Ventas)
CREATE TABLE ventas (
	id_venta INT PRIMARY KEY,
	id_cliente INT NOT NULL,
	id_producto INT NOT NULL,
	id_territorio INT NOT NULL,
	cantidad INT NOT NULL,
	fecha_venta DATE NOT NULL,
	
	CONSTRAINT fk_clientes
		FOREIGN KEY (id_cliente)
		REFERENCES clientes(id_cliente),
	CONSTRAINT fk_productos
		FOREIGN KEY (id_producto)
		REFERENCES productos(id_producto),
	CONSTRAINT fk_territorio
		FOREIGN KEY (id_territorio)
		REFERENCES territorios(id_territorio)
);


-- === SECCIÓN 3: INSERT DATA ===

-- 1. Dimensiones geográficas y de clasificación
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
  (1, 'Computación',    'Laptops, PCs y monitores'),
  (2, 'Accesorios',     'Periféricos y complementos'),
  (3, 'Audio',          'Auriculares y parlantes'),
  (4, 'Almacenamiento', 'Discos y memorias');

INSERT INTO subcategorias (id_subcategoria, nombre_subcategoria, descripcion) VALUES
  (1, 'Portátiles',       'Equipos portátiles para trabajo y gaming'),
  (2, 'Pantallas',        'Monitores de alta resolución'),
  (3, 'Input/Output',     'Mouses, teclados y periféricos'),
  (4, 'Audio Personal',   'Auriculares inalámbricos y de estudio'),
  (5, 'Discos Externos',  'Unidades de almacenamiento sólido');

INSERT INTO ciudades (id_ciudad, nombre) VALUES
  (1, 'Buenos Aires'),
  (2, 'Córdoba'),
  (3, 'Rosario'),
  (4, 'Mendoza'),
  (5, 'Tucumán'),
  (6, 'Neuquén');

INSERT INTO segmentos (id_segmento, nombre) VALUES
  (1, 'Corporativo'),
  (2, 'Consumo Final'),
  (3, 'Pymes');

INSERT INTO paises (id_pais, nombre_pais) VALUES
  (1, 'Argentina'),
  (2, 'Chile'),
  (3, 'Uruguay');

INSERT INTO zonas (id_zona, nombre_zona) VALUES
  (1, 'Centro'),
  (2, 'Norte'),
  (3, 'Cuyo'),
  (4, 'Sur');

INSERT INTO regiones (id_region, nombre_region) VALUES
  (1, 'Región Pampeana'),
  (2, 'Región Noroeste'),
  (3, 'Región Andina'),
  (4, 'Región Patagónica');

-- 2. Entidades principales (Clientes y Productos)
INSERT INTO clientes (id_cliente, nombre, email, id_ciudad, id_segmento, fecha_registro) VALUES
  (1, 'María López',   'maria@mail.com',   1, 1, '2024-01-05'),
  (2, 'Carlos Ruiz',   'carlos@mail.com',  2, 2, '2024-01-10'),
  (3, 'Ana Gómez',     'ana@mail.com',     3, 3, '2024-02-01'),
  (4, 'Pedro Sanz',    'pedro@mail.com',   4, 2, '2024-02-15'),
  (5, 'Laura Torres',  'laura@mail.com',   5, 1, '2024-03-01'),
  (6, 'Martín Castro', 'martin@mail.com',  6, 3, '2024-03-04'),
  (7, 'Esteban Morales', 'esteban@mail.com', 1, 1, '2024-03-20'),
  (8, 'Valeria Rivas',   'valeria@mail.com', 2, 2, '2024-03-22'),
  (9, 'Gonzalo Méndez',  'gonzalo@mail.com', 4, 3, '2024-03-25'),
  (10, 'Camila Herrera',  'camila@mail.com',  6, 2, '2024-03-28');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, id_subcategoria, precio, stock, activo) VALUES
  (1, 'Laptop Pro 15',      1, 1, 1200.00, 15, TRUE),
  (2, 'Mouse Inalámbrico',  2, 3,   28.00, 80, TRUE),
  (3, 'Monitor 4K 27',      1, 2,  450.00, 12, TRUE),
  (4, 'Auriculares BT Pro', 3, 4,  120.00, 35, TRUE),
  (5, 'SSD Externo 1TB',    4, 5,  130.00, 18, TRUE),
  (6, 'Teclado Mecánico',   2, 3,   95.00, 40, TRUE),
  (7,  'Webcam Full HD 1080p',  2, 3,  65.00, 25, TRUE),
  (8,  'Micrófono Condensador', 3, 4, 110.00, 14, TRUE),
  (9,  'Pad Mouse XXL',         2, 3,  20.00, 50, TRUE),
  (10, 'Hub USB-C 7 en 1',      2, 3,  45.00, 30, TRUE);

-- 3. Dimensiones Territoriales y Metas
INSERT INTO territorios (id_territorio, id_region, id_pais, id_zona, nombre_territorio) VALUES
  (1, 1, 1, 1, 'Territorio Buenos Aires - Pampeana'),
  (2, 2, 1, 2, 'Territorio NOA - Tucumán'),
  (3, 3, 1, 3, 'Territorio Cuyo - Mendoza'),
  (4, 4, 1, 4, 'Territorio Patagonia - Sur');

INSERT INTO metas (id_meta, id_region, nombre_meta, monto_meta, estado_meta, fecha_inicio, fecha_fin) VALUES
  (1, 1, 'Meta Q1-Q2 Pampeana',  50000.00, TRUE, '2024-01-01', '2024-06-30'),
  (2, 2, 'Meta Q1-Q2 NOA',       30000.00, TRUE, '2024-01-01', '2024-06-30'),
  (3, 3, 'Meta Q1-Q2 Cuyo',      25000.00, TRUE, '2024-01-01', '2024-06-30'),
  (4, 4, 'Meta Q1-Q2 Patagonia', 35000.00, TRUE, '2024-01-01', '2024-06-30');

-- 4. Transacciones (Ventas ajustadas a 6 columnas: id_venta, id_cliente, id_producto, id_territorio, cantidad, fecha_venta)
INSERT INTO ventas (id_venta, id_cliente, id_producto, id_territorio, cantidad, fecha_venta) VALUES
  ( 1, 1, 1, 1, 2, '2024-03-05'),
  ( 2, 2, 2, 1, 5, '2024-03-06'),
  ( 3, 3, 3, 1, 1, '2024-03-07'),
  ( 4, 1, 4, 1, 2, '2024-03-08'),
  ( 5, 4, 5, 3, 3, '2024-03-10'),
  ( 6, 2, 6, 1, 4, '2024-03-11'),
  ( 7, 5, 1, 2, 1, '2024-03-12'),
  ( 8, 3, 2, 1, 8, '2024-03-13'),
  ( 9, 4, 4, 3, 1, '2024-03-14'),
  (10, 5, 3, 2, 2, '2024-03-15'),
  (11, 6, 1, 4, 1, '2024-03-16'),
  (12, 6, 5, 4, 2, '2024-03-17');

-- === SECCIÓN 4: VALIDACIÓN ===

-- 1. Tablas maestras y de clasificación
SELECT * FROM categorias;      -- esperado: 4 filas
SELECT * FROM subcategorias;   -- esperado: 5 filas
SELECT * FROM ciudades;        -- esperado: 6 filas
SELECT * FROM segmentos;       -- esperado: 3 filas

-- 2. Tablas geográficas y de metas
SELECT * FROM paises;          -- esperado: 3 filas
SELECT * FROM zonas;           -- esperado: 4 filas
SELECT * FROM regiones;        -- esperado: 4 filas
SELECT * FROM territorios;     -- esperado: 4 filas
SELECT * FROM metas;           -- esperado: 4 filas

-- 3. Tablas de entidades principales y transacciones
SELECT * FROM clientes;        -- esperado: 6 filas
SELECT * FROM productos;       -- esperado: 6 filas
SELECT * FROM ventas;          -- esperado: 12 filas

