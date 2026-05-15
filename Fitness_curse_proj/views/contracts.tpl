<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>

    <link rel="stylesheet" href="/static/content/style_header.css">
</head>

<body>
<header class="topbar">

    <div class="topbar-left">
        <img src="/static/img/logo.jpg" alt="logo">
    </div>

    <div class="topbar-right">

        <a href="/manager/{{manager['ID_сотрудника']}}">
            Расписание
        </a>

        <a href="/manager/contracts/{{manager['ID_сотрудника']}}">
            Договоры
        </a>

        <a href="/login"
           onclick="return confirm('Вы уверены, что хотите выйти?')">
            Выход
        </a>

    </div>

</header>

</body>
</html>