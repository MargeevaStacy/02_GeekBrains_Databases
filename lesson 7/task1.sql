-- Задание 1: Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

-- Добавим несколько строк в таблицу orders, заказы сделают все пользователи, кроме №4 и №6
INSERT INTO orders
(user_id)
VALUES (1), (2), (3), (3), (3), (5), (1), (1), (2), (2), (2), (3), (1);

-- Все пользователи, сделавшие хотя бы 1 заказ. Вариант 1
SELECT *
FROM users
WHERE EXISTS (SELECT * FROM orders WHERE users.id = orders.user_id)

-- Все пользователи, сделавшие хотя бы 1 заказ. Вариант 2
SELECT DISTINCT u.*
FROM users u
JOIN orders o ON u.id = o.user_id
