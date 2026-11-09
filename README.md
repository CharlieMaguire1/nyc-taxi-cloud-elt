# NYC Taxi Cloud ELT

A cloud-based data engineering project that uses the January 2023 NYC Yellow Taxi Parquet dataset to implement an ELT architecture with AWS S3, Snowflake, SQL and dbt, with Apache Airflow planned for orchestration.

This project uses the same source dataset as my separate NYC Taxi Python ETL project, allowing me to demonstrate two different approaches to data processing: Python-based ETL and warehouse-centred ELT.

The focus is on secure cloud ingestion, SQL transformations, data quality, reproducibility and orchestration.

## Architecture

NYC TLC Parquet → AWS S3 (RAW) → Snowflake (RAW) → dbt (staging, intermediate, marts)

Apache Airflow is planned to orchestrate the pipeline.

## Implementation Status

### Completed
- Uploaded the January 2023 NYC Yellow Taxi Parquet file to AWS S3.
- Configured an AWS IAM role with read-only access to the required S3 location.
- Created a Snowflake storage integration and external stage.
- Verified access to the staged Parquet file.
- Created reusable Parquet file formats.
- Enabled Parquet logical type interpretation to correctly infer pickup and drop-off timestamps.
- Verified 19 source columns and generated the RAW table column definitions.
- Version-controlled the initial Snowflake infrastructure SQL scripts.

### In Progress
- Creating the Snowflake RAW table.
- Loading source records and reconciling the results against the expected 3,066,766 records.

### Planned
- dbt staging and intermediate transformations.
- SQL-based data quality tests and quarantine handling.
- Analytics marts for downstream reporting.
- Apache Airflow orchestration and monitoring.

## Repository Structure

```text
sql/
└── snowflake/
    ├── 01_environment_setup.sql
    └── 02_s3_raw_ingestion.sql
```

Additional SQL and dbt components will be added as the pipeline develops.