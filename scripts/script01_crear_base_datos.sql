/*
    Paso 1: crear la base de datos del proyecto.
*/

-- Usamos la base de datos master para crear la base de datos del proyecto. No se requiere ejecutar este script si ya se creó la base de datos con el script01_crear_base_datos.sql.
USE [master];
GO

IF DB_ID(N'Aethel_Capital_Bank') IS NULL
BEGIN
    CREATE DATABASE [Aethel_Capital_Bank];
END;
GO
