
# TechStoreTaller3

## Descripción
Este proyecto corresponde al Taller Evaluativo No. 3 de Bases de Datos II. Se trabaja con una base de datos ficticia llamada TechStore, creada en SQL Server y migrada a MongoDB mediante un script en Python.

El objetivo es practicar la creación y población de tablas relacionales, la migración de información y la consulta de datos en MongoDB.

## Tecnologías utilizadas
- SQL Server: creación y manejo de la base de datos relacional.
- Python: ejecución del proceso de migración.
- MongoDB: almacenamiento de los datos migrados y consultas de agregación.
- GitHub: organización y entrega de los archivos del proyecto.

## Estructura del repositorio
- `sql/`: scripts para crear las tablas, insertar registros y verificar los datos.
- `migracion/`: script de Python utilizado para migrar los datos de SQL Server a MongoDB.
- `consultas/`: consultas de agregación realizadas en MongoDB.

## Archivos principales
- `sql/01_crear_tablas.sql`: crea la estructura de las tablas.
- `sql/02_poblar_tablas.sql`: inserta los registros de prueba.
- `sql/03_verificar_datos.sql`: contiene consultas para revisar los datos en SQL Server.
- `migracion/migracion/03_migrar_a_mongo.py`: realiza la migración hacia MongoDB.
- `consultas/04_consultas.js`: contiene las consultas de agregación para analizar la información en MongoDB.

## Proceso realizado
1. Se creó la base de datos TechStore en SQL Server.
2. Se definieron y poblaron las tablas con datos de prueba.
3. Se verificaron los registros mediante consultas SQL.
4. Se desarrolló un script en Python para migrar la información a MongoDB.
5. Se organizaron los documentos en colecciones y se realizaron consultas de agregación.

## Nota
Los datos utilizados en el proyecto son datos de prueba. Para ejecutar los scripts, se deben ajustar las conexiones y configuraciones según el entorno local.
