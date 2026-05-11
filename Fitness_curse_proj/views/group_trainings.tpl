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

<h1>Групповые тренировки</h1>

% if trainings:

    % for tr in trainings:

        <div class="card">

            <h2>{{tr['Тип_тренировки']}}</h2>

            <b>Сложность:</b> {{tr['Уровень_сложности']}}<br><br>
            <b>Стоимость:</b> {{tr['Базовая_стоимость']}} ₽<br><br>
            <b>Длительность:</b> {{tr['Длительность']}}<br><br>
            <b>Дата:</b> {{tr['Дата_и_время_начала']}}<br><br>
            <b>Мест:</b> {{tr['Количество_мест']}}<br><br>
            <b>Зал:</b> {{tr['Тип_зала']}}<br><br>
            <b>Филиал:</b> {{tr['Филиал']}}

            <br><br>

            <form action="/group-training/signup" method="post">

                <input type="hidden" name="training_id"
                       value="{{tr['ID_занятия']}}">

                <input type="hidden" name="client_id"
                       value="{{client_id}}">

                <label>Абонемент:</label>
                <br><br>

                <select name="subscription_id">

                    % for sub in subscriptions:
                        <option value="{{sub['ID_абонемента']}}">
                            {{sub['Тип']}}
                        </option>
                    % end

                </select>

                <br><br>

                <button type="submit">
                    Записаться
                </button>

            </form>

        </div>

    % end

% else:
    <p>Тренировок нет</p>
% end

</body>
</html>