import argparse, os
from google.cloud import bigquery

def load_csv_gcs_to_bq(
    project_id: str,
    dataset: str,
    table: str,
    gcs_uri: str,
    location: str = "EU",
    schema_path: str | None = None,
    replace: bool = False,
):
    client = bigquery.Client(project=project_id, location=location)

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        autodetect=(schema_path is None),
        time_partitioning=bigquery.TimePartitioning(
            type_=bigquery.TimePartitioningType.DAY
        ),
        write_disposition=(
            bigquery.WriteDisposition.WRITE_TRUNCATE
            if replace else bigquery.WriteDisposition.WRITE_APPEND
        ),
        field_delimiter=",",
    )

    if schema_path:
        import json
        with open(schema_path, "r") as f:
            fields = [bigquery.SchemaField(**fld) for fld in json.load(f)]
        job_config.schema = fields

    table_id = f"{project_id}.{dataset}.{table}"
    job = client.load_table_from_uri(gcs_uri, table_id, job_config=job_config)
    job.result()

    table_obj = client.get_table(table_id)
    print(f"Loaded {table_obj.num_rows} rows into {table_id}")

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--project", required=True)
    p.add_argument("--dataset", default="bronze")
    p.add_argument("--table", default="insurance_claims_raw")
    p.add_argument("--gcs_uri", required=True)
    p.add_argument("--location", default="EU")
    p.add_argument("--schema", default=None)
    p.add_argument("--replace", action="store_true")
    args = p.parse_args()

    load_csv_gcs_to_bq(
        project_id=args.project,
        dataset=args.dataset,
        table=args.table,
        gcs_uri=args.gcs_uri,
        location=args.location,
        schema_path=args.schema,
        replace=args.replace,
    )
