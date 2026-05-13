<!DOCTYPE html>
<html>
<head>
    <title>{{title}}</title>

    <style>

        body{
            font-family: Arial;
            background:#eef2f7;
            padding:30px;
        }

        .card{
            background:white;
            padding:20px;
            border-radius:12px;
            margin-bottom:20px;
            box-shadow:0 5px 15px rgba(0,0,0,0.1);
        }

        .btn{
            padding:10px 15px;
            border:none;
            border-radius:8px;
            cursor:pointer;
            color:white;
            font-size:15px;
        }

        .green{
            background:#4CAF50;
        }

        .red{
            background:#e74c3c;
        }

        .btn:disabled{
            background:#999;
            cursor:not-allowed;
        }

    </style>
</head>

<body>

<a href="/client/{{client_id}}">Назад</a>

<h1>Расписание тренировок</h1>

% if success:

<div style="
    background:#d4edda;
    color:#155724;
    padding:15px;
    border-radius:10px;
    margin-bottom:20px;
">
    {{success}}
</div>

% end

% if error:

<div style="
    background:#f8d7da;
    color:#721c24;
    padding:15px;
    border-radius:10px;
    margin-bottom:20px;
">
    {{error}}
</div>

% end


% for s in schedule:

<div class="card">

    <h2>{{s['Тип_тренировки']}}</h2>

    <b>Уровень:</b> {{s['Уровень_сложности']}}<br><br>
    <b>Стоимость:</b> {{s['Базовая_стоимость']}} ₽<br><br>
    <b>Дата:</b> {{s['Дата']}}<br><br>
    <b>Время:</b> {{s['Время']}}<br><br>
    <b>Длительность:</b> {{s['Длительность']}}<br><br>
    <b>Мест:</b> {{s['Количество_мест']}}<br><br>
    <b>Зал:</b> {{s['Тип_зала']}}<br><br>
    <b>Филиал:</b> {{s['Филиал']}}<br><br>


    <!-- ЗАПИСАТЬСЯ -->

    <form action="/group-training/signup" method="post" style="display:inline;">

        <input type="hidden" name="training_id" value="{{s['ID_занятия']}}">
        <input type="hidden" name="client_id" value="{{client_id}}">
        <input type="hidden" name="subscription_id" value="{{sub_ids[0]}}">

        % if not s['is_registered']:

            <button
                class="btn green"
                type="submit"
                onclick="return confirm('Записаться на тренировку?')"
            >
                Записаться
            </button>

        % else:

            <button
                class="btn green"
                disabled
            >
                Записаться
            </button>

        % end

    </form>


    <!-- ОТМЕНИТЬ -->

    <form action="/group-training/cancel" method="post" style="display:inline;">

        <input type="hidden" name="training_id" value="{{s['ID_занятия']}}">
        <input type="hidden" name="client_id" value="{{client_id}}">
        <input type="hidden" name="subscription_id" value="{{sub_ids[0]}}">

        % if s['is_registered']:

            <button
                class="btn red"
                type="submit"
                onclick="return confirm('Отменить запись?')"
            >
                Отменить
            </button>

        % else:

            <button
                class="btn red"
                disabled
            >
                Отменить
            </button>

        % end

    </form>

</div>

% end

</body>
</html>