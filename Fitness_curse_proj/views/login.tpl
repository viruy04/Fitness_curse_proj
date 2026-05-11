<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
</head>
<body>

<h2>Вход</h2>

% if error:
<p style="color:red">{{error}}</p>
% end

<form action="/login" method="post">
    <input name="login" placeholder="Логин"><br><br>
    <input name="password" type="password" placeholder="Пароль"><br><br>
    <button type="submit">Войти</button>
</form>

</body>
</html>