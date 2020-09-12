-- Задание 2: Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.

SELECT dayname(date_format(birthday_at, '2020-%m-%d')) weekdays,
       count(id) users
FROM users
GROUP BY 1
ORDER BY dayofweek(date_format(birthday_at, '2020-%m-%d'))
