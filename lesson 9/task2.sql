/* Задание 2: Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее
название каталога name из таблицы catalogs.
 */

create view shop.product_names as
select p.name product_name,
       c.name catalog_name
from products p
left join catalogs c on p.catalog_id = c.id
