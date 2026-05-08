from bottle import route, view
from datetime import datetime
from db import get_connection

@route('/')
@route('/home')
@view('index')
def home():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT current_schema();")
    schema = cur.fetchone()[0]

    cur.close()
    conn.close()

    return dict(
        year=datetime.now().year,
        schema=schema
    )