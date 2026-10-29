# NYC Taxi Python ELT Pipeline

A cloud and SQL-based project that continues from the previous project about ETL using Python from ingestion to persistence. In this project, AWS CLI is configured and utilised to send the source data to a S3 bucket after authenticating an IAM user.

## Architecture

TLC Parquet → S3 → Snowflake → dbt → Airflow