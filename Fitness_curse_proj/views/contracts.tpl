<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
    <link rel="stylesheet" href="/static/content/style_header.css">
    <link rel="stylesheet" href="/static/content/contracts.css">
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

<main>
    <div class="page-wrapper">

        <div class="card form-card">
            <h2>Новый договор</h2>

            % if success:
                <div class="success">{{success}}</div>
            % end
            % if error:
                <div class="error">{{error}}</div>
            % end

            % if clients:
                <form action="/manager/contracts/create" method="post">
                    <input type="hidden" name="employee_id" value="{{manager['ID_сотрудника']}}">
                    <label>Клиент</label>
                    <select name="client_id">
                        % for cl in clients:
                            <option value="{{cl['ID_клиента']}}">{{cl['Имя']}}</option>
                        % end
                    </select>
                    <button type="submit">Создать договор</button>
                </form>
            % else:
                <p class="empty">Нет клиентов без активного договора.</p>
            % end
        </div>

        <div class="card table-card">
            <h2>Список договоров</h2>

            % if contracts:
                <table>
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
                <p class="empty">Договоров пока нет.</p>
            % end
        </div>

    </div>
</main>
</body>
</html>