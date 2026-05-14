<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
    <link rel="stylesheet" href="/static/content/client.css">
</head>
<body>
<!-- Шапка -->
<header class="topbar">

    <div class="topbar-left">
        <img src="/static/img/logo.png" alt="logo">
    </div>

    <div class="topbar-right">
        <a href="/client/{{client['ID_клиента']}}/subscriptions">
            Абонементы
        </a>

        <a href="/client/{{client['ID_клиента']}}">
            Личный кабинет
        </a>

        <a href="/login">
            Выход
        </a>
    </div>

</header>

<div class="wrapper">

    <!-- Личная информация -->
    <div class="card">
        <h2>Личный кабинет</h2>

        % if defined('error') and error:
            <div class="error">{{error}}</div>
        % end
        % if defined('success') and success:
            <div class="msg">{{success}}</div>
        % end

        % if client:
        <form action="/client/update" method="post">
            <input type="hidden" name="id" value="{{client['ID_клиента']}}">

            <label>Фамилия</label>
            <input value="{{client['Фамилия']}}" disabled>

            <label>Имя</label>
            <input value="{{client['Имя']}}" disabled>

            <label>Отчество</label>
            <input value="{{client['Отчество']}}" disabled>

            <label>Телефон</label>
            <input name="phone" 
                   value="{{form_phone if defined('form_phone') else client['Телефон']}}" 
                   placeholder="+7 (XXX) XXX-XX-XX"
                   oninput="this.value = this.value.replace(/[^+\d\s()-]/g, '')">

            <label>Email</label>
            <input name="email" 
                   value="{{form_email if defined('form_email') else client['Электронная_почта']}}" 
                   placeholder="example@mail.ru">

            <button type="submit">Сохранить</button>

            % if has_active_subscription:
                <a href="/schedule/{{client['ID_клиента']}}" style="text-decoration: none; display: block;">
                    <button type="button" style="background: #2196F3;">Расписание тренировок</button>
                </a>
            % else:
                <button type="button" disabled style="background: gray; cursor: not-allowed;">
                    Расписание тренировок (недоступно)
                </button>
            % end
        </form>
        % end
    </div>

    <!-- Абонементы -->
    <div class="card">
        <h2>Мои абонементы</h2>

        % if subscriptions:
            % for sub in subscriptions:
                <div class="sub">
                    <b>Тип:</b> {{sub['Тип']}}<br><br>
                    <b>Цена:</b> {{sub['Цена']}} ₽<br><br>
                    <b>Срок:</b> {{sub['Срок_дней']}} дней<br><br>
                    <b>Дата активации:</b> {{sub['Дата_активации']}}<br><br>

                    % if sub['is_expired']:
                        <span style="color:red;">Статус: истёк</span>
                    % elif sub['is_active']:
                        <span style="color:green;">Статус: активен</span>
                    % else:
                        <span style="color:gray;">Статус: не активирован</span>
                    % end
                </div>
            % end
        % else:
            <p>Абонементов нет</p>
        % end
    </div>

</div>

</body>
</html>