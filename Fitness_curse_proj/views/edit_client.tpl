<!DOCTYPE html>
<html>
<head>
    <title>Редактирование</title>
    <style>
        body {
            font-family: Arial;
            background: #eef1f5;
            padding: 30px;
        }

        .box {
            background: white;
            padding: 20px;
            border-radius: 12px;
            width: 350px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        input {
            width: 100%;
            padding: 8px;
            margin: 8px 0;
        }

        button {
            width: 100%;
            padding: 10px;
            background: #2196F3;
            color: white;
            border: none;
            border-radius: 8px;
        }

        button:hover {
            background: #1976D2;
        }
    </style>
</head>
<body>

<div class="box">

    <h2>Редактирование профиля</h2>

    <form action="/client/update" method="post">

        <input type="hidden" name="id" value="{{client[0]}}">

        <label>Телефон</label>
        <input name="phone" value="{{client[4]}}">

        <label>Email</label>
        <input name="email" value="{{client[5]}}">

        <button type="submit">Сохранить</button>

    </form>

</div>

</body>
</html>