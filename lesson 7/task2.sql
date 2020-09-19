-- Задание 2: Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT p.id product_id,
       p.name product_name,
       p.price product_price,
       p.catalog_id,
       c.name catalog_name
FROM products p
JOIN catalogs c ON p.catalog_id = c.id
