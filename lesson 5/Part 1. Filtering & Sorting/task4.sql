/* Задание 4: Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае.
Месяцы заданы в виде списка английских названий (may, august)
 */

SELECT *
FROM users
WHERE date_format(birthday_at, '%M') in ('May', 'August')
