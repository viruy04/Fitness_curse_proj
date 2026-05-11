<!DOCTYPE html>
<html>
<head>
    <title>{{title}}</title>

    <style>
        body {
            font-family: Arial;
            background: #eef2f7;
            padding: 30px;
        }

        .card {
            width: 420px;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        input {
            width: 100%;
            padding: 8px;
            margin: 6px 0;
            border: 1px solid #ccc;
            border-radius: 6px;
        }

        button {
            width: 100%;
            padding: 10px;
            background: #4CAF50;
            color: white;
            border: none;
            border-radius: 8px;
            margin-top: 10px;
        }

        .msg {
            color: green;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>

<div class="card">

    <h2>Личный кабинет</h2>

    % if defined('success'):
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
        <input name="phone" value="{{client['Телефон']}}">

        <label>Email</label>
        <input name="email" value="{{client['Электронная_почта']}}">

        <button type="submit">Сохранить</button>

    </form>

    % end

</div>

</body>
</html>