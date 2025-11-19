-- MySQL script
USE ingresos;

CREATE TABLE tipo_ingreso (
    id_tipo_ingreso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE
);

CREATE TABLE tipo_universidad (
    id_tipo_universidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE
);

CREATE TABLE estudiante (
    id_estudiante INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    es_becado BOOLEAN,
    id_tipo_universidad INT,
    FOREIGN KEY (id_tipo_universidad) REFERENCES tipo_universidad(id_tipo_universidad)
);

CREATE TABLE ingreso (
    id_ingreso INT AUTO_INCREMENT PRIMARY KEY,
    ingreso_cantidad DECIMAL(10,2),
    id_tipo_ingreso INT,
    id_estudiante INT,
    FOREIGN KEY (id_tipo_ingreso) REFERENCES tipo_ingreso(id_tipo_ingreso),
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
);
