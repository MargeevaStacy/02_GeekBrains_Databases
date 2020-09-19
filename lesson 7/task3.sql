-- Задание 3: Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
-- Поля from, to и label содержат английские названия городов, поле name — русское.
-- Выведите список рейсов flights с русскими названиями городов.


DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
   id SERIAL PRIMARY KEY,
  `from` VARCHAR(255),
  `to` VARCHAR(255)
);

INSERT INTO flights
(`from`, `to`)
VALUES ('moscow', 'omsk'), ('novgorod', 'kazan'), ('irkutsk', 'moscow'), ('omsk', 'irkutsk'), ('moscow', 'kazan');


DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  label VARCHAR(255),
  name VARCHAR(255)
);

INSERT INTO cities
(label, name)
VALUES ('moscow', 'Москва'), ('irkutsk', 'Иркутск'), ('novgorod', 'Новгород'), ('kazan', 'Казань'), ('omsk', 'Омск');

-- Вариант 1
SELECT id,
       (SELECT name FROM cities WHERE flights.from = cities.label) `from`,
       (SELECT name FROM cities WHERE flights.to = cities.label) `to`
FROM flights


-- Вариант 2
SELECT id,
       c.name `from`,
       c2.name `to`
FROM flights f
LEFT JOIN cities c ON f.`from` = c.label
LEFT JOIN cities c2 ON f.`to` = c2.label
