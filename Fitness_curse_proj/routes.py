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

@route('/schedule/<client_id:int>')
@view('schedule')
def schedule(client_id):

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # 1. тренировки
    cur.execute("""
        SELECT *
        FROM fitness_postgres.тренировки_для_клиента
        WHERE "Дата_и_время_начала" >= NOW()
        ORDER BY "Дата_и_время_начала"
    """)
    rows = cur.fetchall()

    # 2. абонементы клиента
    cur.execute("""
        SELECT ак."ID_абонемента"
        FROM fitness_postgres."абонементы_клиентов" ак
        JOIN fitness_postgres."договоры" д
            ON ак."ID_договора" = д."ID_договора"
        WHERE д."ID_клиента" = %s
    """, (client_id,))

    subs = cur.fetchall()
    sub_ids = [s["ID_абонемента"] for s in subs]

    # 3. посещения клиента
    if sub_ids:
        cur.execute("""
            SELECT "ID_занятия", "ID_абонемента", "ID_статуса"
            FROM fitness_postgres."посещения_групповых"
            WHERE "ID_абонемента" = ANY(%s)
        """, (sub_ids,))
        visits = cur.fetchall()
    else:
        visits = []

    # карта (занятие, абонемент) -> статус
    visit_map = {
        (v["ID_занятия"], v["ID_абонемента"]): v["ID_статуса"]
        for v in visits
    }

    schedule_list = []

    for r in rows:

        dt = r["Дата_и_время_начала"]
        dur = r["Длительность"]

        # проверка регистрации (1 = записан)
        is_registered = False

        for sub in sub_ids:
            if (r["ID_занятия"], sub) in visit_map and visit_map[(r["ID_занятия"], sub)] == 1:
                is_registered = True
                break

        schedule_list.append({
            "ID_занятия": r["ID_занятия"],
            "Тип_тренировки": r["Тип_тренировки"],
            "Уровень_сложности": r["Уровень_сложности"],
            "Базовая_стоимость": r["Базовая_стоимость"],

            "Длительность": f"{dur.hour}ч {dur.minute}м",

            "Дата": dt.strftime("%d.%m.%Y"),
            "Время": dt.strftime("%H:%M"),

            "Количество_мест": r["Количество_мест"],
            "Тип_зала": r["Тип_зала"],
            "Филиал": r["Филиал"],

            "is_registered": is_registered
        })

    cur.close()
    conn.close()

    return dict(
        title='Расписание тренировок',
        schedule=schedule_list,
        client_id=client_id,
        sub_ids=sub_ids
    )

@route('/group-training/signup', method='POST')
def signup():

    training_id = request.forms.get('training_id')
    subscription_id = request.forms.get('subscription_id')

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            CALL fitness_postgres."записаться_на_групповую"(%s, %s)
        """, (training_id, subscription_id))

        conn.commit()

    except Exception as e:
        conn.rollback()
        print(e)

    cur.close()
    conn.close()

    return "OK"

@route('/group-training/cancel', method='POST')
def cancel():

    training_id = request.forms.get('training_id')
    subscription_id = request.forms.get('subscription_id')

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            CALL fitness_postgres."отменить_запись_на_групповую"(%s, %s)
        """, (training_id, subscription_id))

        conn.commit()

    except Exception as e:
        conn.rollback()
        print(e)

    cur.close()
    conn.close()

    return "OK"