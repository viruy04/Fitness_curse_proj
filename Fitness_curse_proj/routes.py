from bottle import route, view
from datetime import datetime
from db import get_connection

@route('/')
@route('/home')
@view('index')
def home():
    conn = get_connection()
    cur = conn.cursor()

    # список таблиц в нужной схеме
    cur.execute("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'fitness_postgres'
        ORDER BY table_name;
    """)

    tables = cur.fetchall()

    cur.close()
    conn.close()

    return dict(
        tables=tables,
        year=datetime.now().year
    )