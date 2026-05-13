<!DOCTYPE html>
<html>
<head>
    <title>Вход</title>
    <link rel="stylesheet" href="/static/content/login.css">
</head>

<body>

<div class="logo">
    <img src="/static/img/logo.jpg">
</div>

<div class="login-box">

    <div class="login-header">Войти в систему</div>

    % if error:
        <div class="error">{{error}}</div>
    % end

    <form action="/login" method="post">

        <div class="field">
            <label>Логин</label>
            <input name="login" type="text">
        </div>

        <div class="field">
            <label>Пароль</label>
            <input name="password" type="password">
        </div>

        <button type="submit">Войти</button>

    </form>

</div>

</body>
</html>