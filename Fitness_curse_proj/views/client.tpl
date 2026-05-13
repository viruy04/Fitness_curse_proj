<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
    <style>
        body {
            font-family: Arial;
            background: #eef2f7;
            padding: 30px;
        }
        .wrapper {
            display: flex;
            gap: 30px;
            align-items: flex-start;
        }
        .card {
            width: 420px;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        label {
            display: block;
            margin-top: 10px;
            font-size: 14px;
            color: #555;
        }
        input {
            width: 100%;
            padding: 8px;
            margin: 4px 0 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            padding: 10px;
            background: #4CAF50;
            color: white;
            border: none;
            border-radius: 8px;
            margin-top: 10px;
            cursor: pointer;
        }
        .error {
            color: #d32f2f;
            background: #ffebee;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 12px;
            border: 1px solid #ffcdd2;
            font-size: 14px;
        }
        .msg {
            color: #2e7d32;
            background: #e8f5e9;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 12px;
            border: 1px solid #c8e6c9;
            font-size: 14px;
        }
        .sub {
            border: 1px solid #ddd;
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 12px;
            background: #fafafa;
        }
    </style>
</head>
<body>

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