-- 0. Establish compute context
USE WAREHOUSE SNOWFLAKE_LEARNING_WH;

-- 1. Create Snowflake storage integration
CREATE STORAGE INTEGRATION IF NOT EXISTS
    NYC_TAXI_S3_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<account_id>:role/nyc-taxi-snowflake-s3-read-role'
    ENABLED = TRUE
    STORAGE_ALLOWED_LOCATIONS = ('s3://nyc-taxi-data-platform-ak47/raw/');

-- 2. Inspect storage integration properties
DESC INTEGRATION NYC_TAXI_S3_INT;

-- 3. Create external stage for NYC Taxi RAW data
CREATE STAGE IF NOT EXISTS
    NYC_TAXI_ELT.RAW.NYC_TAXI_S3_STAGE
    STORAGE_INTEGRATION = NYC_TAXI_S3_INT
    URL = 's3://nyc-taxi-data-platform-ak47/raw/'
    FILE_FORMAT = (TYPE = PARQUET);

-- 4. Test if Snowflake can list the S3 Parquet file
LIST @NYC_TAXI_ELT.RAW.NYC_TAXI_S3_STAGE;

-- 5. Create named Parquet file format
CREATE FILE FORMAT IF NOT EXISTS
    NYC_TAXI_ELT.RAW.NYC_TLC_PARQUET_FORMAT
    TYPE = PARQUET
    COMMENT = 'This is for schema inspection and future Parquet loading operations';

-- 6. Verify active warehouse
SELECT CURRENT_WAREHOUSE() AS active_warehouse;

-- 7. Infer source Parquet schema
SELECT *
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@NYC_TAXI_ELT.RAW.NYC_TAXI_S3_STAGE',
        FILE_FORMAT => 'NYC_TAXI_ELT.RAW.NYC_TLC_PARQUET_FORMAT'
    )
);

-- 8. Experiment with Parquet logical types
CREATE FILE FORMAT IF NOT EXISTS
    NYC_TAXI_ELT.RAW.NYC_TLC_PARQUET_FORMAT_EXPERIMENT
    TYPE = PARQUET
    USE_LOGICAL_TYPE = TRUE;

-- 9. Infer schema using Parquet logical types
SELECT *
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@NYC_TAXI_ELT.RAW.NYC_TAXI_S3_STAGE',
        FILE_FORMAT => 'NYC_TAXI_ELT.RAW.NYC_TLC_PARQUET_FORMAT_EXPERIMENT'
    )
);

-- 10. Count inferred source columns
SELECT COUNT(*) AS inferred_column_count
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@NYC_TAXI_ELT.RAW.NYC_TAXI_S3_STAGE',
        FILE_FORMAT => 'NYC_TAXI_ELT.RAW.NYC_TLC_PARQUET_FORMAT_EXPERIMENT'
    )
);

-- 11. Generate description of columns
SELECT GENERATE_COLUMN_DESCRIPTION(
    ARRAY_AGG(OBJECT_CONSTRUCT(*))
        WITHIN GROUP (ORDER BY order_id),
    'table') AS columns
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@NYC_TAXI_ELT.RAW.NYC_TAXI_S3_STAGE',
        FILE_FORMAT => 'NYC_TAXI_ELT.RAW.NYC_TLC_PARQUET_FORMAT_EXPERIMENT'
    )
);

-- 12. Create RAW table
CREATE TABLE IF NOT EXISTS NYC_TAXI_ELT.RAW.YELLOW_TAXI_TRIPS(
    "VendorID" NUMBER(38, 0),
    "tpep_pickup_datetime" TIMESTAMP_NTZ,
    "tpep_dropoff_datetime" TIMESTAMP_NTZ,
    "passenger_count" REAL,
    "trip_distance" REAL,
    "RatecodeID" REAL,
    "store_and_fwd_flag" TEXT,
    "PULocationID" NUMBER(38, 0),
    "DOLocationID" NUMBER(38, 0),
    "payment_type" NUMBER(38, 0),
    "fare_amount" REAL,
    "extra" REAL,
    "mta_tax" REAL,
    "tip_amount" REAL,
    "tolls_amount" REAL,
    "improvement_surcharge" REAL,
    "total_amount" REAL,
    "congestion_surcharge" REAL,
    "airport_fee" REAL
);

-- 13. Inspect RAW table schema
DESCRIBE TABLE NYC_TAXI_ELT.RAW.YELLOW_TAXI_TRIPS;

-- 14. Load data with COPY INTO
COPY INTO NYC_TAXI_ELT.RAW.YELLOW_TAXI_TRIPS
FROM @NYC_TAXI_ELT.RAW.NYC_TAXI_S3_STAGE
FILE_FORMAT = (
    FORMAT_NAME = 'NYC_TAXI_ELT.RAW.NYC_TLC_PARQUET_FORMAT_EXPERIMENT'
)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = ABORT_STATEMENT;

-- 15. Reconcile RAW table row count
SELECT COUNT(*) AS raw_row_count
FROM NYC_TAXI_ELT.RAW.YELLOW_TAXI_TRIPS;

-- 16. Inspect sample timestamp values and trip distances
SELECT
    "tpep_pickup_datetime" AS pickup_datetime,
    "tpep_dropoff_datetime" AS dropoff_datetime,
    "trip_distance" AS trip_distance
FROM NYC_TAXI_ELT.RAW.YELLOW_TAXI_TRIPS
LIMIT 5;

-- 17. Inspection of timestamp boundaries
-- Observed minimum pickup timestamp: 2008-12-31 23:01:42.000
-- Investigate as a potential source data anomaly
-- Do not modify RAW records during investigation
SELECT
    MIN("tpep_pickup_datetime") AS min_pickup_datetime,
    MAX("tpep_pickup_datetime") AS max_pickup_datetime
FROM NYC_TAXI_ELT.RAW.YELLOW_TAXI_TRIPS;

