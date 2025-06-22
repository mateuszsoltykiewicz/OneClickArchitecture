import psycopg2

# Source database connection
source_conn = psycopg2.connect(
    host="prod-v2-backup.cwdkm5ftgkny.eu-central-1.rds.amazonaws.com",
    database="df_db",
    user="postgres",
    password="ZrQrQbj7djxAlC3qs5up"
)
source_cur = source_conn.cursor()
source_cur.execute("""
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_schema, table_name
""")
source_tables = set(source_cur.fetchall())

# Destination database connection
dest_conn = psycopg2.connect(
    host="10.27.241.3",
    database="df_db",
    user="postgres",
    password="dfaidfaidfaidfai"
)
dest_cur = dest_conn.cursor()
dest_cur.execute("""
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_schema, table_name
""")
dest_tables = set(dest_cur.fetchall())

# Find missing tables
missing_tables = source_tables - dest_tables

print("Tables missing in destination:")
for schema, table in sorted(missing_tables):
    print(f"{schema}.{table}")

source_conn.close()
dest_conn.close()

