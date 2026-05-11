% rebase('layout.tpl', title='Вход', year=year)

<h1>Вход в личный кабинет</h1>

<form method="post" action="/login">

    <p>
        <label>Логин</label><br>
        <input type="text" name="login">
    </p>

    <p>
        <label>Пароль</label><br>
        <input type="password" name="password">
    </p>

    <p>
        <button type="submit">Войти</button>
    </p>

</form>

% if defined('error') and error:
    <p style="color:red;">
        {{error}}
    </p>
% end