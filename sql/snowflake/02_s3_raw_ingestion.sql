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

SELECT CURRENT_WAREHOUSE() AS active_warehouse;

SELECT *
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@NYC_TAXI_ELT.RAW.NYC_TAXI_S3_STAGE',
        FILE_FORMAT => 'NYC_TAXI_ELT.RAW.NYC_TLC_PARQUET_FORMAT'
    )
);
