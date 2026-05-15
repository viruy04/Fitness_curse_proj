<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>

    <style>

        body{
            font-family: Arial;
            background:#f5f5f5;
            padding:40px;
        }

        .card{
            background:white;
            padding:20px;
            border-radius:14px;
            margin-bottom:20px;
            box-shadow:0 2px 10px rgba(0,0,0,0.08);
        }

        table{
            width:100%;
            border-collapse:collapse;
            margin-top:15px;
        }

        th, td{
            padding:12px;
            border-bottom:1px solid #ddd;
            text-align:left;
        }

        input, select{
            padding:10px;
            border-radius:8px;
            border:1px solid #ccc;
            margin-bottom:10px;
            width:100%;
        }

        button{
            padding:10px 16px;
            border:none;
            border-radius:8px;
            cursor:pointer;
            background:#111;
            color:white;
        }

        h1,h2{
            margin-top:0;
        }

        .edit-form{
            display:flex;
            gap:10px;
            align-items:center;
        }

    </style>

</head>
<body>
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

<div class="card">

    <h1>Личный кабинет менеджера</h1>

    <p>
        <b>
            {{manager['Фамилия']}} {{manager['Имя']}}
            % if manager['Отчество']:
                {{manager['Отчество']}}
            % end
        </b>
    </p>

    <p>
        Филиал:
        <b>{{manager['Филиал']}}</b>
    </p>

</div>


<div class="card">

    <h2>Добавить занятие</h2>

    <form action="/manager/add-training" method="post">

        <input type="hidden"
               name="employee_id"
               value="{{manager['ID_сотрудника']}}">

        <label>Тренировка</label>

        <select name="training_id">

            % for t in trainings:

                <option value="{{t['ID_тренировки']}}">

                    {{t['Тренировка']}}
                    —
                    {{t['Сложность']}}

                    % if t['Длительность']:
                        ({{t['Длительность']}})
                    % end

                </option>

            % end

        </select>


        <label>Зал</label>

        <select name="hall_id">

            % for h in halls:

                <option value="{{h['ID_зала']}}">
                    Зал #{{h['ID_зала']}}
                </option>

            % end

        </select>


        <label>Тренер</label>

        <select name="trainer_id">

            % for tr in trainers:

                <option value="{{tr['ID_сотрудника']}}">
                    {{tr['Фамилия']}} {{tr['Имя']}}
                </option>

            % end

        </select>


        <label>Дата и время</label>

        <input type="datetime-local"
               name="datetime_start"
               required>

        <label>Количество мест</label>

        <input type="number"
               name="places"
               required>

        <button type="submit">
            Добавить занятие
        </button>

    </form>

</div>



<div class="card">

    <h2>Расписание филиала</h2>

    <table>

        <tr>
            <th>ID</th>
            <th>Тренировка</th>
            <th>Сложность</th>
            <th>Дата</th>
            <th>Тренер</th>
            <th>Зал</th>
            <th>Мест</th>
            <th>Редактирование</th>
        </tr>

        % for s in schedule:

        <tr>

            <td>{{s['ID_занятия']}}</td>

            <td>{{s['Тренировка']}}</td>

            <td>{{s['Сложность']}}</td>

            <td>{{s['Дата_и_время_начала']}}</td>

            <td>{{s['Тренер']}}</td>

            <td>Зал #{{s['ID_зала']}}</td>

            <td>{{s['Количество_мест']}}</td>

            <td>

                <form class="edit-form"
                      action="/manager/update-training"
                      method="post">

                    <input type="hidden"
                           name="employee_id"
                           value="{{manager['ID_сотрудника']}}">

                    <input type="hidden"
                           name="session_id"
                           value="{{s['ID_занятия']}}">

                    <input type="datetime-local"
                           name="datetime_start"
                           value="{{s['Дата_и_время_начала'].strftime('%Y-%m-%dT%H:%M')}}">

                    <input type="number"
                           name="places"
                           value="{{s['Количество_мест']}}"
                           required>

                    <button type="submit">
                        Сохранить
                    </button>

                </form>

            </td>

        </tr>

        % end

    </table>

</div>

</body>
</html>