<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
    <link rel="stylesheet" href="/static/content/subscriptions.css">
    <link rel="stylesheet" href="/static/content/style_header.css">
</head>

<body>

<!-- Шапка -->
<header class="topbar">

    <div class="topbar-left">
        <img src="/static/img/logo.jpg" alt="logo">
    </div>

    <div class="topbar-right">
        <a href="/client/{{client_id}}/subscriptions">
            Абонементы
        </a>

        <a href="/client/{{client_id}}">
            Личный кабинет
        </a>

        <a href="/login"
            onclick="return confirm('Вы уверены, что хотите выйти?')">
            Выход
        </a>
    </div>

</header>

<div class="page-title">
    Наши абонементы
</div>

<div class="subs-container">

    % for sub in subscriptions:

    <div class="sub-card">

        <div class="sub-name">
            {{sub['Название']}}
        </div>

        <div class="sub-price">
            {{sub['Цена']}} ₽
        </div>

        <div class="sub-info">
            <b>Срок:</b>
            {{sub['Срок_дней']}} дней
        </div>

        <div class="sub-info">
            <b>Лимит посещений:</b>

            % if sub['Лимит_посещений_месяц']:
                {{sub['Лимит_посещений_месяц']}} в месяц
            % else:
                Без ограничений
            % end
        </div>

        <div class="sub-description">
            {{sub['Описание']}}
        </div>

    </div>

    % end

</div>

</body>
</html>