import logging
import subprocess
import json
import os
from google.cloud import storage

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(name)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

def dump_rds_to_file(config):
    """Dump RDS Aurora PostgreSQL to a file using pg_dump."""
    dump_file = "rds_dump.sql"
    cmd = [
        "pg_dump",
        "-h", config["source"]["endpoint"],
        "-p", str(config["source"]["port"]),
        "-U", config["source"]["username"],
        "-d", config["source"]["database"],
        "-f", dump_file
    ]
    # Set PGPASSWORD in environment or use .pgpass
    env = os.environ.copy()
    env["PGPASSWORD"] = config["source"]["password"]
    try:
        subprocess.run(cmd, check=True, env=env)
        logger.info("Successfully dumped RDS to file")
        return dump_file
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to dump RDS: {e}")
        raise

def upload_to_gcs(dump_file, bucket_name):
    """Upload dump file to Google Cloud Storage."""
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(dump_file)
    blob.upload_from_filename(dump_file)
    logger.info(f"Uploaded {dump_file} to GCS bucket {bucket_name}")
    return f"gs://{bucket_name}/{dump_file}"

def import_to_cloud_sql(gcs_path, config):
    """Import dump from GCS to Cloud SQL."""
    project = config["gcp"]["project_id"]
    instance = config["gcp"]["instance_name"]
    database = config["gcp"]["database_name"]
    cmd = [
        "gcloud", "sql", "import", "sql",
        instance,
        gcs_path,
        "--database=" + database,
        "--project=" + project
    ]
    try:
        subprocess.run(cmd, check=True)
        logger.info("Successfully imported to Cloud SQL")
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to import to Cloud SQL: {e}")
        raise

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Migrate RDS Aurora PostgreSQL to Cloud SQL')
    parser.add_argument('--config', required=True, help='Path to JSON config file')
    args = parser.parse_args()

    with open(args.config) as f:
        config = json.load(f)

    dump_file = dump_rds_to_file(config)
    gcs_path = upload_to_gcs(dump_file, config["gcp"]["bucket_name"])
    import_to_cloud_sql(gcs_path, config)

if __name__ == '__main__':
    main()
