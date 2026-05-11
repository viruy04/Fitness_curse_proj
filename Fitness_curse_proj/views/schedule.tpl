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
            display:inline-block;
            padding:10px 15px;
            background:#4CAF50;
            color:white;
            text-decoration:none;
            border-radius:8px;
            margin-bottom:20px;
        }
    </style>
</head>

<body>

<a href="/client/{{client_id}}" class="btn">Назад</a>

<h1>Расписание тренировок</h1>

% if schedule:

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
            <b>Филиал:</b> {{s['Филиал']}}

        </div>

    % end

% else:
    <p>Тренировок нет</p>
% end

</body>
</html>