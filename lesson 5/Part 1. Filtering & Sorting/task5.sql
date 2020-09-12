/* Задание 5: Из таблицы catalogs извлекаются записи при помощи запроса.
SELECT * FROM catalogs WHERE id IN (5, 1, 2). Отсортируйте записи в порядке, заданном в списке IN.
 */

SELECT *
FROM catalogs
WHERE id IN (5, 1, 2)
ORDER BY id = 5 desc, id = 1 desc, id = 2 desc
