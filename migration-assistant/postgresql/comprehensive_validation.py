import psycopg2
import os
import sys

def get_tables(conn_params):
    """Get all user tables including unlogged and partitioned tables"""
    query = """
    SELECT n.nspname AS schema, c.relname AS table_name
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'p')
      AND n.nspname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY n.nspname, c.relname;
    """
    try:
        with psycopg2.connect(**conn_params) as conn:
            with conn.cursor() as cur:
                cur.execute(query)
                return set(cur.fetchall())
    except Exception as e:
        print(f"Error connecting or querying database: {e}", file=sys.stderr)
        sys.exit(1)

def compare_tables(src_params, dst_params):
    src_tables = get_tables(src_params)
    dst_tables = get_tables(dst_params)

    missing_tables = src_tables - dst_tables
    extra_tables = dst_tables - src_tables

    print(f"Source tables: {len(src_tables)}")
    print(f"Destination tables: {len(dst_tables)}")
    
    if missing_tables:
        print("\nTables missing in destination database:")
        for schema, table in sorted(missing_tables):
            print(f"  - {schema}.{table}")
    else:
        print("\nNo missing tables in destination")
        
    if extra_tables:
        print("\nExtra tables in destination database:")
        for schema, table in sorted(extra_tables):
            print(f"  - {schema}.{table}")
    else:
        print("\nNo extra tables in destination")
        
    return len(missing_tables) == 0

if __name__ == '__main__':
    src_params = {
        'host': os.getenv('SRC_DB_HOST'),
        'database': os.getenv('DB_NAME'),
        'user': 'postgres',
        'password': os.getenv('SRC_DB_PASSWORD')
    }
    dst_params = {
        'host': os.getenv('DST_DB_HOST'),
        'database': os.getenv('DB_NAME'),
        'user': 'postgres',
        'password': os.getenv('DST_DB_PASSWORD')
    }
    
    if not compare_tables(src_params, dst_params):
        sys.exit(1)