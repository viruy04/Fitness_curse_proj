import hashlib
import psycopg2

conn = psycopg2.connect(
    dbname="postgres",
    user="postgres",
    password="060321",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

cur.execute("""
    SELECT id, password
    FROM fitness_postgres."юзеры"
""")

users = cur.fetchall()

for user_id, password in users:

    if len(password) == 64:
        continue

    hashed = hashlib.sha256(
        password.encode()
    ).hexdigest()

    cur.execute("""
        UPDATE fitness_postgres."юзеры"
        SET password = %s
        WHERE id = %s
    """, (hashed, user_id))

conn.commit()

cur.close()
conn.close()

print("Пароли успешно захешированы")
