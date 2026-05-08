import psycopg2

def get_connection():
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="060321",
        host="localhost",
        port="5432"
    )
    conn.cursor().execute("SET search_path TO fitness_postgres")
    return conn