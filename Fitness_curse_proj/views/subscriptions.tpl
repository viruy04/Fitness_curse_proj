<!DOCTYPE html>
<html>
<head>
    <title>Абонементы</title>

    <style>
        body { font-family: Arial; background:#f4f6fa; padding:30px; }

        .card {
            background:white;
            padding:20px;
            border-radius:12px;
            width:600px;
        }

        .item {
            border-bottom:1px solid #ddd;
            padding:10px 0;
        }
    </style>
</head>
<body>

<div class="card">

    <h2>Мои абонементы</h2>

    % for s in subs:

        <div class="item">
            <b>{{s['Тип_абонемента']}}</b><br>
            Цена: {{s['Цена']}}<br>
            Срок: {{s['Срок_дней']}} дней<br>
            Продажа: {{s['Дата_продажи']}}<br>
            Активен с: {{s['Дата_активации']}}
        </div>

    % end

</div>

</body>
</html>