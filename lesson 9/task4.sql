/* Задание 4: Пусть имеется любая таблица с календарным полем created_at.
Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
 */

delete orders
from orders
left join (select id
           from orders
           order by created_at desc
           limit 5) last_orders
on orders.id = last_orders.id
where last_orders.id is null
