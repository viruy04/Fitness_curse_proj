<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>

    <link rel="stylesheet" href="/static/content/style_header.css">
    <link rel="stylesheet" href="/static/content/schedule.css">
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

<div class="page-controls">
    <a class="back-link" href="/client/{{client_id}}">← Назад</a>
    <div class="page-title">Расписание тренировок</div>
    <div style="width: 100px;"></div>
</div>


<div class="schedule-container">
% for s in schedule:

<div class="card">

    <h2>{{s['Тип_тренировки']}}</h2>

    <div class="info-row">
        <span class="info-label">Уровень</span>
        <span class="info-value">{{s['Уровень_сложности']}}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Стоимость</span>
        <span class="info-value">{{s['Базовая_стоимость']}} ₽</span>
    </div>

    <div class="info-row">
        <span class="info-label">Дата</span>
        <span class="info-value">{{s['Дата']}}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Время</span>
        <span class="info-value">{{s['Время']}}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Длительность</span>
        <span class="info-value">{{s['Длительность']}}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Мест</span>
        <span class="info-value">{{s['Количество_мест']}}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Зал</span>
        <span class="info-value">{{s['Тип_зала']}}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Филиал</span>
        <span class="info-value">{{s['Филиал']}}</span>
    </div>

    <div class="buttons">

        <form action="/group-training/signup" method="post">

            <input type="hidden" name="training_id" value="{{s['ID_занятия']}}">
            <input type="hidden" name="client_id" value="{{client_id}}">
            <input type="hidden" name="subscription_id" value="{{sub_ids[0] if sub_ids else ''}}">

            % if not s['is_registered']:
                <button class="btn green" type="submit"
                        onclick="return confirm('Записаться?')">
                    Записаться
                </button>
            % else:
                <button class="btn green" disabled>Записаться</button>
            % end

        </form>


        <form action="/group-training/cancel" method="post">

            <input type="hidden" name="training_id" value="{{s['ID_занятия']}}">
            <input type="hidden" name="client_id" value="{{client_id}}">
            <input type="hidden" name="subscription_id" value="{{sub_ids[0] if sub_ids else ''}}">

            % if s['is_registered']:
                <button class="btn red" type="submit"
                        onclick="return confirm('Отменить запись?')">
                    Отменить
                </button>
            % else:
                <button class="btn red" disabled>Отменить</button>
            % end

        </form>

    </div>

</div>

% end

</div>

</body>
</html>