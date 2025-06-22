#!/bin/bash

# Usage:
# ./pg_migrate_parallel.sh <SRC_DB_HOST> <SRC_DB_PASSWORD> <DST_DB_HOST> <DST_DB_PASSWORD> <DB_NAME> [JOBS]
# Example:
# ./pg_migrate_parallel.sh src.example.com srcpass dst.example.com dstpass mydb 4

set -e

SRC_DB_HOST="$1"
SRC_DB_PASSWORD="$2"
DST_DB_HOST="$3"
DST_DB_PASSWORD="$4"
DB_NAME="$5"
JOBS="${6:-$(nproc)}"  # Default: use all available CPUs

DUMP_DIR="./pg_dumpdir"
LOG_FILE="migration.log"

if [ $# -lt 5 ]; then
  echo "Usage: $0 <SRC_DB_HOST> <SRC_DB_PASSWORD> <DST_DB_HOST> <DST_DB_PASSWORD> <DB_NAME> [JOBS]"
  exit 1
fi

# Ensure dnf is available (Amazon Linux 2023+)
if ! command -v dnf >/dev/null 2>&1; then
  echo "dnf package manager is required." | tee -a "$LOG_FILE"
  exit 1
fi

# Ensure nohup is installed
if ! command -v nohup >/dev/null 2>&1; then
  echo "Installing coreutils for nohup..." | tee -a "$LOG_FILE"
  sudo dnf install -y coreutils
fi

# Ensure pg_dump and pg_restore are installed
if ! command -v pg_dump >/dev/null 2>&1 || ! command -v pg_restore >/dev/null 2>&1; then
  echo "Installing PostgreSQL client tools..." | tee -a "$LOG_FILE"
  sudo dnf install -y postgresql16
fi

# Initialize log file
: > "$LOG_FILE"

# Start timing
START_TIME=$(date +%s)

# Function to calculate and print duration
print_duration() {
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  HOURS=$((DURATION / 3600))
  MINUTES=$(((DURATION % 3600) / 60))
  SECONDS=$((DURATION % 60))
  printf "Migration completed. Total time: %02d:%02d:%02d\n" $HOURS $MINUTES $SECONDS | tee -a "$LOG_FILE"
}

# Trap EXIT to always print duration
trap print_duration EXIT

# Dump from source (directory format, parallel)
export PGPASSWORD="$SRC_DB_PASSWORD"
echo "Starting parallel pg_dump from $SRC_DB_HOST..." | tee -a "$LOG_FILE"
rm -rf "$DUMP_DIR"

# Execute dump with real-time error display and correct pipe status
if ! pg_dump -h "$SRC_DB_HOST" -U postgres -d "$DB_NAME" -F d -j "$JOBS" -b -v -f "$DUMP_DIR" 2>&1 | tee -a "$LOG_FILE"; then
  echo "pg_dump failed with exit code ${PIPESTATUS[0]}. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
  exit 1
fi

# Check if destination database exists, create if not
export PGPASSWORD="$DST_DB_PASSWORD"
echo "Checking destination database..." | tee -a "$LOG_FILE"

# Execute database check with error handling and correct pipe status
DB_EXISTS=$(psql -h "$DST_DB_HOST" -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>&1 | tee -a "$LOG_FILE"; exit ${PIPESTATUS[0]})
PSQL_EXIT=$?

if [ $PSQL_EXIT -ne 0 ]; then
  echo "Database check failed with exit code $PSQL_EXIT. Assuming database doesn't exist." | tee -a "$LOG_FILE"
  DB_EXISTS=""
fi

if [ "$DB_EXISTS" != "1" ]; then
  echo "Database $DB_NAME does not exist on $DST_DB_HOST. Creating..." | tee -a "$LOG_FILE"
  if ! createdb -h "$DST_DB_HOST" -U postgres "$DB_NAME" 2>&1 | tee -a "$LOG_FILE"; then
    echo "Database creation failed with exit code ${PIPESTATUS[0]}" | tee -a "$LOG_FILE"
    exit 1
  fi
else
  echo "Database $DB_NAME already exists on $DST_DB_HOST." | tee -a "$LOG_FILE"
fi

# Restore to destination (parallel)
echo "Starting parallel pg_restore to $DST_DB_HOST..." | tee -a "$LOG_FILE"

# Execute restore with real-time error display and correct pipe status
if ! pg_restore -h "$DST_DB_HOST" -U postgres -d "$DB_NAME" -j "$JOBS" -v "$DUMP_DIR" 2>&1 | tee -a "$LOG_FILE"; then
  echo "pg_restore failed with exit code ${PIPESTATUS[0]}. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
  exit 1
fi
