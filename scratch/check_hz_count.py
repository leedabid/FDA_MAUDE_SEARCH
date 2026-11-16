import os, sys
sys.path.insert(0, os.path.abspath("."))
from server.db_engine import get_sqlite_conn

with get_sqlite_conn() as conn:
    cnt = conn.execute('SELECT count(*) FROM maude_hazards').fetchone()[0]
    print(f"maude_hazards count: {cnt}")
