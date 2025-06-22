import re

with open('migration.log', 'r') as logfile:
    log_content = logfile.read()

pattern = re.compile(r'pg_restore: creating TABLE ([\w\.]+)')
restored_tables = pattern.findall(log_content)

print(restored_tables)

