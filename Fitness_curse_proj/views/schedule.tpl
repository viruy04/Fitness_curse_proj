% for s in schedule:

<div class="card">

    <h2>{{s['Тип_тренировки']}}</h2>

    <b>Уровень:</b> {{s['Уровень_сложности']}}<br><br>
    <b>Стоимость:</b> {{s['Базовая_стоимость']}} ₽<br><br>
    <b>Дата:</b> {{s['Дата']}}<br><br>
    <b>Время:</b> {{s['Время']}}<br><br>
    <b>Длительность:</b> {{s['Длительность']}}<br><br>
    <b>Мест:</b> {{s['Количество_мест']}}<br><br>
    <b>Зал:</b> {{s['Тип_зала']}}<br><br>
    <b>Филиал:</b> {{s['Филиал']}}<br><br>

    <!-- выбор абонемента -->
    <form action="/group-training/signup" method="post">

        <input type="hidden" name="training_id" value="{{s['ID_занятия']}}">

        <select name="subscription_id">

            % for sub in sub_ids:
                <option value="{{sub}}">{{sub}}</option>
            % end

        </select>

       % if not s['is_registered']:
            <button type="submit">Записаться</button>
        % else:
            <button disabled>Записаться</button>
        % end

    </form>

    <form action="/group-training/cancel" method="post">

        <input type="hidden" name="training_id" value="{{s['ID_занятия']}}">

        <select name="subscription_id">

            % for sub in sub_ids:
                <option value="{{sub}}">{{sub}}</option>
            % end

        </select>

        % if s['is_registered']:
            <button type="submit">Отменить</button>
        % else:
            <button disabled>Отменить</button>
        % end

    </form>

</div>

% end