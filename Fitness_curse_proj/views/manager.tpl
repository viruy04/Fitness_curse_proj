<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
    <link rel="stylesheet" href="/static/content/manager.css">
    <link rel="stylesheet" href="/static/content/style_header.css">
</head>

<body>
<header class="topbar">
    <div class="topbar-left">
        <img src="/static/img/logo.jpg" alt="logo">
    </div>
    <div class="topbar-right">
        <a href="/manager/{{manager['ID_сотрудника']}}">Расписание</a>
        <a href="#" onclick="alert('Раздел в разработке'); return false;">Договоры</a>
        <a href="/login" onclick="return confirm('Вы уверены, что хотите выйти?')">Выход</a>
    </div>
</header>

% if success:
<div class="success">{{success}}</div>
% end

% if error:
<div class="error">{{error}}</div>
% end

<div class="top-cards">
    <div class="card">
        <h1>Личный кабинет менеджера</h1>
    
        <div class="manager-name">
            {{manager['Фамилия']}} {{manager['Имя']}}
            % if manager['Отчество']:
            {{manager['Отчество']}}
            % end
        </div>

        <div class="manager-details">
            <div class="manager-detail">
                <span class="detail-label">Филиал:</span>
                <b>{{manager['Филиал']}}</b>
            </div>
            <div class="manager-detail">
                <span class="detail-label">Адрес:</span>
                <b>{{manager['Адрес']}}</b>
            </div>
            <div class="manager-detail">
                <span class="detail-label">Время работы:</span>
                <b>
                    % if manager['Время_открытия'] and manager['Время_закрытия']:
                    {{manager['Время_открытия'].strftime('%H:%M')}} — {{manager['Время_закрытия'].strftime('%H:%M')}}
                    % else:
                    —
                    % end
                </b>
            </div>
            <div class="manager-detail">
                <span class="detail-label">Телефон:</span>
                <b>{{manager['Телефон']}}</b>
            </div>
            <div class="manager-detail">
                <span class="detail-label">Дата рождения:</span>
                <b>
                    % if manager['Дата_рождения']:
                    {{manager['Дата_рождения'].strftime('%d.%m.%Y')}}
                    % else:
                    —
                    % end
                </b>
            </div>
        </div>

        <div class="manager-responsibilities">
            <b>Обязанности:</b> отвечает за составление расписания, его изменения и составление договоров
        </div>
    </div>

    <div class="card">
        <h2>Добавить занятие</h2>
        <form action="/manager/add-training" method="post">
            <input type="hidden" name="employee_id" value="{{manager['ID_сотрудника']}}">
            <label>Тренировка</label>
            <select name="training_id">
                % for t in trainings:
                <option value="{{t['ID_тренировки']}}">
                    {{t['Тренировка']}} — {{t['Сложность']}}
                    % if t['Длительность']:
                    ({{t['Длительность']}})
                    % end
                </option>
                % end
            </select>
            <label>Зал</label>
            <select name="hall_id">
                % for h in halls:
                <option value="{{h['ID_зала']}}">Зал #{{h['ID_зала']}}</option>
                % end
            </select>
            <label>Тренер</label>
            <select name="trainer_id">
                % for tr in trainers:
                <option value="{{tr['ID_сотрудника']}}">{{tr['Фамилия']}} {{tr['Имя']}}</option>
                % end
            </select>
            <label>Дата и время</label>
            <input type="datetime-local" name="datetime_start" required>
            <label>Количество мест</label>
            <input type="number" name="places" required>
            <button type="submit">Добавить занятие</button>
        </form>
    </div>
</div>

<div class="card schedule-card">
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
                <form class="edit-form" action="/manager/update-training" method="post">
                    <input type="hidden" name="employee_id" value="{{manager['ID_сотрудника']}}">
                    <input type="hidden" name="session_id" value="{{s['ID_занятия']}}">
                    <input type="datetime-local" name="datetime_start" value="{{s['Дата_и_время_начала'].strftime('%Y-%m-%dT%H:%M')}}">
                    <input type="number" name="places" value="{{s['Количество_мест']}}" required>
                    <button type="submit">Сохранить</button>
                </form>
            </td>
        </tr>
        % end
    </table>
</div>

</body>
</html>