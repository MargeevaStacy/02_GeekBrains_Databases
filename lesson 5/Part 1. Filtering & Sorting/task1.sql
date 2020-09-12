-- Задание 1: Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

UPDATE users
SET
	created_at = now(),
	updated_at = now()
WHERE created_at is null and updated_at is null
