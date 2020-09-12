-- Задание 1: Подсчитайте средний возраст пользователей в таблице users.

SELECT round(avg(TIMESTAMPDIFF(YEAR,birthday_at ,current_date()))) avg_age
FROM users
