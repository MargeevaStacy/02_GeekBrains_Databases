/* Задание 1: В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
 */

-- Беру только id и name, т.к. структура таблиц users отличается в shop и sample БД, таблица sample.users состоит только из 2х столбцов - id, name.
-- Т.к. id в таблице sample.users НЕ auto-increment, то для генерации правильного уникального id используется select max(id) + 1 as id from sample.users

start transaction;

insert into sample.users (id, name)
select (select max(id) + 1 as id from sample.users), name from shop.users where id = 1;

delete from shop.users where id = 1;

commit;
