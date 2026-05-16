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
        <a href="/manager/{{manager['ID_сотрудника']}}">Расписание</a>
        <a href="/manager/contracts/{{manager['ID_сотрудника']}}">Договоры</a>
        <a href="/login" onclick="return confirm('Вы уверены, что хотите выйти?')">Выход</a>
    </div>

</header>

<main style="margin-top: 120px; padding: 0 40px;">

    <h2>Новый договор</h2>

    % if success:
        <p style="color: green;">{{success}}</p>
    % end
    % if error:
        <p style="color: red;">{{error}}</p>
    % end

    <form action="/manager/contracts/create" method="post">
        <input type="hidden" name="employee_id" value="{{manager['ID_сотрудника']}}">

        <label>Клиент:
            <select name="client_id">
                % for cl in clients:
                    <option value="{{cl['ID_клиента']}}">{{cl['Имя']}}</option>
                % end
            </select>
        </label>

        <button type="submit">Создать договор</button>
    </form>

    <h2>Список договоров</h2>

    % if contracts:
        <table border="1">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Клиент</th>
                    <th>Дата заключения</th>
                    <th>Дата окончания</th>
                    <th>Состояние</th>
                </tr>
            </thead>
            <tbody>
                % for c in contracts:
                    <tr>
                        <td>{{c['ID_договора']}}</td>
                        <td>{{c['Клиент']}}</td>
                        <td>{{c['Дата_заключения']}}</td>
                        <td>{{c['Дата_окончания'] or '—'}}</td>
                        <td>{{c['Состояние']}}</td>
                    </tr>
                % end
            </tbody>
        </table>
    % else:
        <p>Договоров пока нет.</p>
    % end

</main>

</body>
</html>