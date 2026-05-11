from bottle import route, view, request
from datetime import datetime
from db import get_connection
from bottle import route, view, request, template


# Главная страница = логин
@route('/')
@view('login')
def home():

    return dict(
        error="",
        year=datetime.now().year
    )


# Проверка входа
@route('/login', method='POST')
@view('cabinet')
def login_check():

    login = request.forms.get('login')
    password = request.forms.get('password')

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT *
        FROM fitness_postgres.users
        WHERE login = %s
        AND password = %s
    """, (login, password))

    user = cur.fetchone()

    print(user)

    if user:

        client_id = user[3]

        cur.execute("""
            SELECT
                "Фамилия",
                "Имя",
                "Отчество",
                "Телефон",
                "Электронная_почта"
            FROM fitness_postgres."клиенты"
            WHERE "ID_клиента" = %s
        """, (client_id,))

        client = cur.fetchone()

        cur.close()
        conn.close()

        return dict(
            client=client,
            year=datetime.now().year
        )

    cur.close()
    conn.close()

    return dict(
        error="Неверный логин или пароль",
        year=datetime.now().year
    )

# Личный кабинет
@route('/cabinet')
@view('cabinet')
def cabinet():

    return dict(
        client=None,
        year=datetime.now().year
    )