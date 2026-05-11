<!DOCTYPE html>
<html>
<head>
    <title>Админ панель</title>
</head>
<body>

<h2>Админ-панель</h2>

<h3>Клиенты</h3>
% for c in clients:
<p>{{c}}</p>
% end

<h3>Абонементы</h3>
% for a in abonements:
<p>{{a}}</p>
% end

<h3>Расписание</h3>
% for s in schedule:
<p>{{s}}</p>
% end

</body>
</html>