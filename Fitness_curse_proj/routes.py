from bottle import route, template, request
from bottle import route, view, request
from datetime import datetime
from db import get_connection
import psycopg2.extras


# =========================
# LOGIN PAGE
# =========================
@route('/')
@route('/login')
@view('login')
def login_page():
    return dict(title='Вход', error='')


# =========================
# LOGIN CHECK
# =========================
@route('/login', method='POST')
@view('client')
def login_check():

    login = request.forms.get('login')
    password = request.forms.get('password')

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    cur.execute("""
        SELECT id, role, id_клиента
        FROM fitness_postgres."юзеры"
        WHERE login=%s AND password=%s
    """, (login, password))

    user = cur.fetchone()

    if not user:
        cur.close()
        conn.close()
        return dict(title='Вход', error='Неверный логин или пароль')

    client_id = user['id_клиента']

    cur.execute("""
        SELECT "ID_клиента",
               "Фамилия",
               "Имя",
               "Отчество",
               "Телефон",
               "Электронная_почта"
        FROM fitness_postgres."клиенты"
        WHERE "ID_клиента"=%s
    """, (client_id,))

    client = cur.fetchone()

    # абонементы клиента
    cur.execute("""
    SELECT
        ак."ID_абонемента",
        та."Название" AS "Тип",
        та."Цена",
        та."Срок_дней",
        ак."Дата_активации"
    FROM fitness_postgres."абонементы_клиентов" ак
    JOIN fitness_postgres."типы_абонементов" та
        ON ак."ID_типа_абонемента" = та."ID_типа_абонемента"
    JOIN fitness_postgres."договоры" д
        ON ак."ID_договора" = д."ID_договора"
    WHERE д."ID_клиента" = %s
    """, (client_id,))

    subscriptions = cur.fetchall()

    cur.close()
    conn.close()

    return dict(
    title='ЛК клиента',
    client=client,
    subscriptions=subscriptions
    )


# =========================
# UPDATE CLIENT (БЕЗ REDIRECT)
# =========================
@route('/client/update', method='POST')
@view('client')
def update_client():

    client_id = request.forms.get('id')
    phone = request.forms.get('phone')
    email = request.forms.get('email')

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # обновление
    cur.execute("""
        UPDATE fitness_postgres."клиенты"
        SET "Телефон"=%s,
            "Электронная_почта"=%s
        WHERE "ID_клиента"=%s
    """, (phone, email, client_id))

    conn.commit()

    # заново получаем данные (ВАЖНО — как в твоём стиле JSON-подхода)
    cur.execute("""
        SELECT "ID_клиента",
               "Фамилия",
               "Имя",
               "Отчество",
               "Телефон",
               "Электронная_почта"
        FROM fitness_postgres."клиенты"
        WHERE "ID_клиента"=%s
    """, (client_id,))

    client = cur.fetchone()

    # абонементы клиента
    cur.execute("""
    SELECT *
    FROM fitness_postgres.мои_абонементы
    WHERE "ID_абонемента" IN (

        SELECT "ID_абонемента"
        FROM fitness_postgres."абонементы_клиентов"
        WHERE "ID_договора" IN (

            SELECT "ID_договора"
            FROM fitness_postgres."договоры"
            WHERE "ID_клиента" = %s
            )
    )
""", (client_id,))

    subscriptions = cur.fetchall()

    cur.close()
    conn.close()

    return dict(
        title='ЛК клиента',
        client=client,
        subscriptions=subscriptions,
        success='Данные обновлены'
    )

@route('/client/<client_id:int>/subscriptions')
@view('subscriptions')
def my_subscriptions(client_id):

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    cur.execute("""
        SELECT *
        FROM fitness_postgres.мои_абонементы
        WHERE "ID_абонемента" IN (
            SELECT "ID_абонемента"
            FROM fitness_postgres."абонементы_клиентов"
            WHERE "ID_договора" IN (
                SELECT "ID_договора"
                FROM fitness_postgres."договоры"
                WHERE "ID_клиента" = %s
            )
        )
    """, (client_id,))

    subs = cur.fetchall()

    cur.close()
    conn.close()

    return dict(
        title="Мои абонементы",
        subs=subs
    )