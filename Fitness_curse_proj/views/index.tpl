% rebase('layout.tpl', title='Tables', year=year)

<h1>Таблицы схемы fitness_postgres</h1>

<ul>
% for t in tables:
    <li>{{t[0]}}</li>
% end
</ul>