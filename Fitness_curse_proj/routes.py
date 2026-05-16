from bottle import route, view, request, template, redirect
from datetime import datetime
import re
from db import get_connection
import psycopg2.extras


@route('/')
@route('/login')
@view('login')
def login_page():
    return dict(title='Вход', error='')

@route('/login', method='POST')
def login_check():

    login = request.forms.get('login', '').strip()
    password = request.forms.get('password', '').strip()

    if not login or not password:
        return template('login',
                         title='Вход',
                         error='Пожалуйста заполните поля')

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    cur.execute("""
        SELECT id,
               role,
               id_клиента,
               id_сотрудника
        FROM fitness_postgres."юзеры"
        WHERE login=%s AND password=%s
    """, (login, password))

    user = cur.fetchone()

    cur.close()
    conn.close()

    if not user:
        return template('login',
                         title='Вход',
                         error='Неверный логин или пароль')

    # КЛИЕНТ
    if user['role'] == 'клиент':
        client_data = load_client_page(user['id_клиента'])
        return template('client', **client_data)

    # МЕНЕДЖЕР
    elif user['role'] == 'менеджер':
        manager_data = load_manager_page(user['id_сотрудника'])
        return template('manager', **manager_data)

    return "Неизвестная роль"

# ЛК
@route('/client/<client_id:int>')
@view('client')
def client_page(client_id):
    return load_client_page(client_id)


def load_client_page(client_id):

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # клиент
    cur.execute("""
        SELECT "ID_клиента","Фамилия","Имя","Отчество","Телефон","Электронная_почта"
        FROM fitness_postgres."клиенты"
        WHERE "ID_клиента"=%s
    """, (client_id,))
    client = cur.fetchone()

    # абонементы
    cur.execute("""
        SELECT
            ак."ID_абонемента",
            та."Название" AS "Тип",
            та."Цена",
            та."Срок_дней",
            ак."Дата_активации",
            (ак."Дата_активации" IS NOT NULL) AS is_active,
            (ак."Дата_активации" + INTERVAL '1 day' * та."Срок_дней") < NOW() AS is_expired
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
        subscriptions=subscriptions,
        has_active_subscription=any(
            s['is_active'] and not s['is_expired']
            for s in subscriptions
        )
    )

def load_manager_page(employee_id):

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # менеджер
    cur.execute("""
        SELECT
            с."ID_сотрудника",
            с."Фамилия",
            с."Имя",
            с."Отчество",
            с."Дата_рождения",
            с."Телефон",
            с."ID_филиала",
            ф."Название" AS "Филиал",
            ф."Адрес",
            ф."Время_открытия",
            ф."Время_закрытия"
        FROM fitness_postgres."сотрудники" с
        JOIN fitness_postgres."филиалы" ф
            ON с."ID_филиала" = ф."ID_филиала"
        WHERE с."ID_сотрудника" = %s
    """, (employee_id,))

    manager = cur.fetchone()

    # расписание
    cur.execute("""
        SELECT
            рг."ID_занятия",
            тт."Название" AS "Тренировка",
            ус."Название" AS "Сложность",
            рг."Дата_и_время_начала",
            рг."Количество_мест",
            з."ID_зала",
            с."ID_сотрудника",
            с."Фамилия" || ' ' || с."Имя" AS "Тренер"

        FROM fitness_postgres."расписание_групповых" рг

        JOIN fitness_postgres."тренировки" тр
            ON рг."ID_тренировки" = тр."ID_тренировки"

        JOIN fitness_postgres."типы_тренировок" тт
            ON тр."ID_типа_трен" = тт."ID_типа_трен"

        JOIN fitness_postgres."уровни_сложности" ус
            ON тр."ID_сложности" = ус."ID_сложности"

        JOIN fitness_postgres."залы" з
            ON рг."ID_зала" = з."ID_зала"

        JOIN fitness_postgres."сотрудники" с
            ON рг."ID_сотрудника" = с."ID_сотрудника"

        WHERE з."ID_филиала" = %s

        ORDER BY рг."Дата_и_время_начала"
    """, (manager["ID_филиала"],))

    schedule = cur.fetchall()

    # тренировки
    cur.execute("""
        SELECT
            тр."ID_тренировки",
            тт."Название" AS "Тренировка",
            ус."Название" AS "Сложность",
            тр."Длительность"

        FROM fitness_postgres."тренировки" тр

        JOIN fitness_postgres."типы_тренировок" тт
            ON тр."ID_типа_трен" = тт."ID_типа_трен"

        JOIN fitness_postgres."уровни_сложности" ус
            ON тр."ID_сложности" = ус."ID_сложности"

        ORDER BY тт."Название", ус."Название"
    """)

    trainings = cur.fetchall()

    # залы
    cur.execute("""
        SELECT
            "ID_зала"
        FROM fitness_postgres."залы"
        WHERE "ID_филиала" = %s
    """, (manager["ID_филиала"],))

    halls = cur.fetchall()

    # тренеры
    cur.execute("""
        SELECT
            "ID_сотрудника",
            "Фамилия",
            "Имя"
        FROM fitness_postgres."сотрудники"
        WHERE "ID_филиала" = %s
          AND "ID_должности" = 2
        ORDER BY "Фамилия"
    """, (manager["ID_филиала"],))

    trainers = cur.fetchall()

    cur.close()
    conn.close()

    return dict(
        title='ЛК менеджера',
        manager=manager,
        schedule=schedule,
        trainings=trainings,
        halls=halls,
        trainers=trainers,
        success='',
        error=''
    )

# Обновление клиента
@route('/client/update', method='POST')
@view('client')
def update_client():

    client_id = request.forms.get('id')

    phone_raw = request.forms.getunicode('phone', '').strip()
    email_raw = request.forms.getunicode('email', '').strip()

    errors = []

    # Email
    if not email_raw:
        errors.append("Поле Email обязательно.")

    elif not re.match(
        r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
        email_raw
    ):
        errors.append(
            "Некорректный формат Email (пример: name@mail.ru)."
        )

    # Телефон
    if not phone_raw:
        errors.append("Поле Телефон обязательно.")

    elif not re.match(
        r'^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$',
        phone_raw
    ):
        errors.append(
            "Формат телефона должен быть: +7 (XXX) XXX-XX-XX"
        )

    # если ошибки
    if errors:

        data = load_client_page(client_id)

        data['error'] = " ".join(errors)
        data['form_phone'] = phone_raw
        data['form_email'] = email_raw

        return data

    conn = get_connection()
    cur = conn.cursor()

    try:

        cur.execute("""
            UPDATE fitness_postgres."клиенты"
            SET
                "Телефон"=%s,
                "Электронная_почта"=%s
            WHERE "ID_клиента"=%s
        """, (
            phone_raw,
            email_raw,
            client_id
        ))

        conn.commit()

    except Exception as e:

        conn.rollback()

        data = load_client_page(client_id)

        data['error'] = f"Ошибка БД: {e}"

        return data

    finally:

        cur.close()
        conn.close()

    data = load_client_page(client_id)

    data['success'] = "Данные успешно сохранены!"

    return data


# Страница абонементов
@route('/client/<client_id:int>/subscriptions')
@view('subscriptions')
def subscriptions_page(client_id):

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # все типы абонементов
    cur.execute("""
        SELECT
            "ID_типа_абонемента",
            "Название",
            "Описание",
            "Цена",
            "Лимит_посещений_месяц",
            "Срок_дней"
        FROM fitness_postgres."типы_абонементов"
        ORDER BY "Цена"
    """)

    subscriptions = cur.fetchall()

    cur.close()
    conn.close()

    return dict(
        title='Абонементы',
        subscriptions=subscriptions,
        client_id=client_id
    )


# Расписание групповых тренировок
@route('/schedule/<client_id:int>')
@view('schedule')
def schedule(client_id):

    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # сортировка по филиалу
    cur.execute("""
        SELECT "ID_филиала"
        FROM fitness_postgres."клиенты"
        WHERE "ID_клиента" = %s
    """, (client_id,))
    
    client_branch = cur.fetchone()["ID_филиала"]

    cur.execute("""
        SELECT *
        FROM fitness_postgres.тренировки_для_клиента
        WHERE "Дата_и_время_начала" >= NOW()
          AND "Филиал" = (
              SELECT "Название"
              FROM fitness_postgres."филиалы"
              WHERE "ID_филиала" = %s
          )
        ORDER BY "Дата_и_время_начала" DESC
    """, (client_branch,))

    rows = cur.fetchall()

    cur.execute("""
        SELECT ак."ID_абонемента"
        FROM fitness_postgres."абонементы_клиентов" ак
        JOIN fitness_postgres."договоры" д
            ON ак."ID_договора" = д."ID_договора"
        WHERE д."ID_клиента" = %s
    """, (client_id,))

    subs = cur.fetchall()
    sub_ids = [s["ID_абонемента"] for s in subs]

    visit_map = {}

    if sub_ids:
        cur.execute("""
            SELECT "ID_занятия","ID_абонемента","ID_статуса"
            FROM fitness_postgres."посещения_групповых"
            WHERE "ID_абонемента" = ANY(%s)
        """, (sub_ids,))
        visits = cur.fetchall()

        visit_map = {
            (v["ID_занятия"], v["ID_абонемента"]): v["ID_статуса"]
            for v in visits
        }

    schedule_list = []

    for r in rows:

        dt = r["Дата_и_время_начала"]
        dur = r["Длительность"]

        is_registered = any(
            (r["ID_занятия"], sub) in visit_map and visit_map[(r["ID_занятия"], sub)] == 1
            for sub in sub_ids
        )

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
        sub_ids=sub_ids,
        success='',
        error=''
    )


# Запись
@route('/group-training/signup', method='POST')
@view('schedule')
def signup():

    training_id = request.forms.get('training_id')
    subscription_id = request.forms.get('subscription_id')
    client_id = request.forms.get('client_id')

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            CALL fitness_postgres."записаться_на_групповую"(%s,%s)
        """, (training_id, subscription_id))
        conn.commit()
        success = "Вы успешно записались"
        error = ""

    except Exception as e:
        conn.rollback()
        success = ""
        error = str(e)

    cur.close()
    conn.close()

    return schedule(client_id)


# Отмена записи
@route('/group-training/cancel', method='POST')
@view('schedule')
def cancel():

    training_id = request.forms.get('training_id')
    subscription_id = request.forms.get('subscription_id')
    client_id = request.forms.get('client_id')

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            CALL fitness_postgres."отменить_запись_на_групповую"(%s,%s)
        """, (training_id, subscription_id))
        conn.commit()
        success = "Запись отменена"
        error = ""

    except Exception as e:
        conn.rollback()
        success = ""
        error = str(e)

    cur.close()
    conn.close()

    return schedule(client_id)

@route('/manager/add-training', method='POST')
@view('manager')
def add_training():

    employee_id = request.forms.get('employee_id')

    training_id = request.forms.get('training_id')
    hall_id = request.forms.get('hall_id')
    trainer_id = request.forms.get('trainer_id')
    datetime_start = request.forms.get('datetime_start')
    places = request.forms.get('places')

    success = ''
    error = ''

    conn = get_connection()
    cur = conn.cursor()

    try:

        cur.execute("""
            INSERT INTO fitness_postgres."расписание_групповых"
            (
                "ID_тренировки",
                "ID_зала",
                "ID_сотрудника",
                "Дата_и_время_начала",
                "Количество_мест"
            )
            VALUES (%s,%s,%s,%s,%s)
        """, (
            training_id,
            hall_id,
            trainer_id,
            datetime_start,
            places
        ))

        conn.commit()

        success = "Занятие успешно добавлено"

    except Exception as e:

        conn.rollback()

        error = str(e)

    finally:

        cur.close()
        conn.close()

    data = load_manager_page(employee_id)

    data['success'] = success
    data['error'] = error

    return data

# Обновление тренировки
@route('/manager/update-training', method='POST')
@view('manager')
def update_training():

    training_session_id = request.forms.get('session_id')
    places = request.forms.get('places')
    datetime_start = request.forms.get('datetime_start')
    employee_id = request.forms.get('employee_id')

    success = ''
    error = ''

    conn = get_connection()
    cur = conn.cursor()

    try:

        cur.execute("""
            UPDATE fitness_postgres."расписание_групповых"
            SET
                "Дата_и_время_начала" = %s,
                "Количество_мест" = %s
            WHERE "ID_занятия" = %s
        """, (
            datetime_start,
            places,
            training_session_id
        ))

        conn.commit()

        success = "Изменения сохранены"

    except Exception as e:

        conn.rollback()

        error = str(e)

    finally:

        cur.close()
        conn.close()

    data = load_manager_page(employee_id)

    data['success'] = success
    data['error'] = error

    return data

# Страница менеджера по прямому заходу
@route('/manager/<employee_id:int>')
@view('manager')
def manager_page(employee_id):
    return load_manager_page(employee_id)

# Функция для договоров
def load_contracts_page(employee_id):
    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    # менеджер
    cur.execute("""
        SELECT "ID_сотрудника", "Фамилия", "Имя", "Отчество"
        FROM fitness_postgres."сотрудники"
        WHERE "ID_сотрудника" = %s
    """, (employee_id,))
    manager = cur.fetchone()

    # список договоров
    cur.execute("""
        SELECT
            д."ID_договора",
            к."Фамилия" || ' ' || к."Имя" AS "Клиент",
            д."Дата_заключения",
            д."Дата_окончания",
            с."Название" AS "Состояние"
        FROM fitness_postgres."договоры" д
        JOIN fitness_postgres."клиенты" к
            ON д."ID_клиента" = к."ID_клиента"
        JOIN fitness_postgres."состояние_договора" с
            ON д."ID_состояния" = с."ID_состояния"
        WHERE д."ID_сотрудника" = %s
        ORDER BY д."Дата_заключения" DESC
    """, (employee_id,))
    contracts = cur.fetchall()

    # список клиентов для формы
    cur.execute("""
        SELECT к."ID_клиента", к."Фамилия" || ' ' || к."Имя" AS "Имя"
        FROM fitness_postgres."клиенты" к
        WHERE к."ID_филиала" = (
            SELECT "ID_филиала"
            FROM fitness_postgres."сотрудники"
            WHERE "ID_сотрудника" = %s
        )
        AND NOT EXISTS (
            SELECT 1
            FROM fitness_postgres."договоры" д
            WHERE д."ID_клиента" = к."ID_клиента"
              AND д."ID_состояния" = 1
        )
        ORDER BY к."Фамилия"
    """, (employee_id,))
    clients = cur.fetchall()

    cur.close()
    conn.close()

    success = '✓ Договор успешно создан' if request.query.get('success') else ''

    return dict(
        title='Договоры',
        manager=manager,
        contracts=contracts,
        clients=clients,
        success=success,
        error=''
    )

# Страница договоров
@route('/manager/contracts/<employee_id:int>')
@view('contracts')
def contracts_page(employee_id):
    return load_contracts_page(employee_id)


@route('/manager/contracts/create', method='POST')
def create_contract():
    employee_id = request.forms.get('employee_id')
    client_id = request.forms.get('client_id')

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO fitness_postgres."договоры"
            ("ID_клиента", "ID_сотрудника", "Дата_заключения", "ID_состояния")
            VALUES (%s, %s, CURRENT_DATE, 1)
        """, (client_id, employee_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        data = load_contracts_page(employee_id)
        data['error'] = str(e)
        return template('contracts', **data)
    finally:
        cur.close()
        conn.close()

    redirect(f'/manager/contracts/{employee_id}')