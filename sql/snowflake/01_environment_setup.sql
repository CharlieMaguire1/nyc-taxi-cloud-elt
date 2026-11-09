-- 1. Inspect session context
SELECT
    CURRENT_ROLE() AS active_role,
    CURRENT_WAREHOUSE() AS active_warehouse,
    CURRENT_DATABASE() AS active_database,
    CURRENT_SCHEMA() AS active_schema;

-- 2. Inspect available warehouses
SHOW WAREHOUSES;

-- 3. Select the warehouse
USE WAREHOUSE SNOWFLAKE_LEARNING_WH;

-- 4. Verify the selected warehouse
SELECT
    CURRENT_WAREHOUSE() AS active_warehouse;

-- 5. Inspect existing databases
SHOW DATABASES;

-- 6. Create the NYC Taxi project database
CREATE DATABASE IF NOT EXISTS NYC_TAXI_ELT;

-- 7. Verify that NYC Taxi database exists
SHOW DATABASES LIKE 'NYC_TAXI_ELT';

-- 8. Create RAW schema
CREATE SCHEMA IF NOT EXISTS NYC_TAXI_ELT.RAW;

-- 9. Verify that the RAW schema exists
SHOW SCHEMAS LIKE 'RAW' IN DATABASE NYC_TAXI_ELT;