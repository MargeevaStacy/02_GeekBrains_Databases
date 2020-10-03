-- 3. СКРИПТЫ ТИПОВЫХ ВЫБОРОК

-- ТИПОВАЯ ВЫБОРКА №1
/* Пользователи сервиса Lostfilm могут добавлять сериал в список Избранных. Каждую серию сериала можно отметить как просмотренную.
В личном кабинете пользователя ведется статистика по: (1) числу избранных сериалов и числу непросмотренных серий избранных сериалов, (2) числу просмотренных серий всего и числу часов, затраченных на их просмотр. 
Возьмем как пример пользователя с id = 1 и посмотрим на его статистику использования сервиса.*/

WITH user_stats AS (
SELECT fv.user_id
       , s.film_id
       , f.series
       , COUNT(fv.series_id) total_series_viewed -- всего просмотренных серий
       , ROUND(SUM(fs.lenght) / 60, 1) total_hours_spent -- число часов, затраченных на просмотр серий
       , CASE WHEN uf.status = 1 THEN 1 ELSE 0 END favorite_films_marker -- 1 - если фильм есть в списке избранных пользователя, 0 - если нет
       , COUNT(CASE WHEN uf.status = 1 THEN fv.series_id ELSE NULL END) favorite_films_series_viewed -- число просмотренных серий избранных сериалов
FROM lostfilm.fact_film_views fv
JOIN lostfilm.dim_film_series fs ON fv.series_id = fs.id
JOIN lostfilm.dim_film_seasons s ON fs.season_id = s.id
LEFT JOIN lostfilm.fact_user_films uf ON s.film_id = uf.film_id AND uf.user_id = 1 -- left join, т.к. можно смотреть серии и без добавления сериала в список избранных + есть опция включить сериал в список избранных, а потом его удалить, а серии уже просмотрены
JOIN (
      SELECT film_id
             , SUM(series_num) series -- считаем число серий по каждому фильму
      FROM lostfilm.dim_film_seasons
      GROUP BY 1) f
      ON s.film_id = f.film_id
WHERE fv.user_id = 1
GROUP BY 1, 2)

SELECT u.nickname
       , MAX(CONCAT(u.first_name, ' ', u.last_name)) user_name -- max используется для того, чтобы избежать группировки по этому полю
       , MAX(u.birthday_at) birthday_at
       , MAX(u.gender) gender
       , SUM(us.favorite_films_marker) favorite_films -- число избранных сериалов
       , SUM(CASE WHEN us.favorite_films_marker = 1 THEN us.series - us.favorite_films_series_viewed ELSE NULL END) favorite_films_series_not_viewed -- число непросмотренных серий избранных сериалов
       , SUM(us.total_series_viewed) total_series_viewed -- число просмотренных серий
       , SUM(us.total_hours_spent) total_hours_spent -- число часов, затраченных на просмотр всех серий
FROM user_stats us
JOIN lostfilm.dim_users u ON us.user_id = u.id
GROUP BY 1



-- ТИПОВАЯ ВЫБОРКА №2
/* Найдем Топ-3 комментируемых сериала. */

SELECT f.id film_id
       , MAX(f.name_eng) name_eng
       , MAX(f.name_ru) name_ru
       , COUNT(fuc.id) comments
FROM lostfilm.dim_films f
JOIN lostfilm.dim_film_seasons s ON f.id = s.film_id
JOIN lostfilm.dim_film_series fs ON fs.season_id = s.id
JOIN lostfilm.fact_user_comments fuc ON fuc.series_id = fs.id
GROUP BY 1
ORDER BY 4 DESC
LIMIT 3



-- ТИПОВАЯ ВЫБОРКА №3
/* Самый распространенный вопрос, которым задается каждый любитель сериалов, — «А КОГДА?» — когда же выйдет следующая серия любимого шоу.
Поэтому расписание выхода новых серий — самый полезный функционал для зрителей. Создадим типовую выборку для реализации этой задачи. */

SELECT f.name_eng
       , f.name_ru
       , CONCAT(fs.series_id, ' серия ', s.season_id, ' сезона') coming_series
       , CASE WHEN fs.premiere_date = CURRENT_DATE() THEN 'Выходит сегодня'
            WHEN fs.premiere_date = CURRENT_DATE() + INTERVAL '1' DAY THEN 'Выходит завтра'
            WHEN fs.premiere_date = CURRENT_DATE() + INTERVAL '2' DAY THEN 'Выходит через 2 дня'
            ELSE concat('Выходит ', fs.premiere_date) END when_series_comes
FROM lostfilm.fact_user_films uf 
JOIN lostfilm.dim_film_seasons s ON uf.film_id = s.film_id
JOIN lostfilm.dim_film_series fs ON fs.season_id = s.id AND fs.premiere_date >= current_date()
JOIN lostfilm.dim_films f ON uf.film_id = f.id
WHERE uf.user_id = 1
      AND uf.status = 1 -- status = 1, когда сериал все еще находится в списке избранных, 0 - когда был удален из списка избранных
ORDER BY fs.premiere_date



-- 4. ПРЕДСТАВЛЕНИЯ


-- ПРЕДСТАВЛЕНИЕ №1
/* Главная страница Lostfilm сервиса (https://www.lostfilm.tv/series/ или https://www.lostfilm.run/series/) позволяет пользователю найти сериал по определенному критерию:
(1) жанр, (2) год выхода, (3) канал, (4) тип, (5) первая буква английского или русского названия сериала, (6) статус сериала - Новый, Снимающийся, Завершенный, Идущий

Вьюшка lostfilm.main_page_view будет использоваться каждый раз, когда пользователь захочет найти сериал, используя вышеупомянутые критерии. */

DROP VIEW IF EXISTS lostfilm.main_page_view;
CREATE VIEW lostfilm.main_page_view AS (
SELECT f.name_eng
       , f.name_ru
       , s.name status
       , YEAR(premiere_date) premier_year
       , c.name channel
       , g.name genre
       , t.name `type`
       , CASE WHEN YEAR(premiere_date) < 2000 THEN 'до 2000'
              WHEN YEAR(premiere_date) BETWEEN 2001 AND 2005 THEN '2001-2005'
              WHEN YEAR(premiere_date) BETWEEN 2006 AND 2010 THEN '2006-2010'
              WHEN YEAR(premiere_date) BETWEEN 2011 AND 2015 THEN '2011-2015'
              ELSE CONCAT('2016-', YEAR(CURRENT_DATE())) END premier_year_for_filter
       , SUBSTRING(f.name_ru, 1, 1) name_ru_first_letter
       , SUBSTRING(f.name_eng, 1, 1) name_eng_first_letter
       , CASE WHEN f.status_id = 1 THEN 'Новые'
              WHEN f.status_id IN (32, 33) THEN 'Снимающиеся'
              WHEN f.status_id = 34 THEN 'Завершенные'
              ELSE 'Идут' END status_for_filter
FROM lostfilm.dim_films f
JOIN lostfilm.dim_film_genres fg ON f.id = fg.film_id
JOIN lostfilm.dim_genres g ON fg.genre_id = g.id 
JOIN lostfilm.dim_film_types ft ON f.id = ft.film_id
JOIN lostfilm.dim_types t ON ft.type_id = t.id 
JOIN lostfilm.dim_statuses s ON f.status_id = s.id
JOIN lostfilm.dim_channels c ON f.channel_id = c.id);



-- ПРЕДСТАВЛЕНИЕ №2
/* Пользователи сервиса Lostfilm могут ставить оценки просмотренным сериям от 1 до 10 баллов. Оценку можно менять. Из оценок пользователей складывается общая оценка серии и сериала.

Вьюшка lostfilm.film_rating_view рассчитывает рейтинг каждого сериала, сезона сериала и каждой серии на основании оценок пользователей, выставленных сериям сериала в lostfilm.fact_film_views. */

DROP VIEW IF EXISTS lostfilm.film_rating_view;
CREATE VIEW lostfilm.film_rating_view AS (
SELECT f.name_eng film_name_eng
       , f.name_ru film_name_ru
       , s.season_id season
       , fs.series_id series
       , ROUND(AVG(fv.series_rating) OVER (PARTITION BY s.film_id), 1) film_rating
       , ROUND(AVG(fv.series_rating) OVER (PARTITION BY s.film_id, s.season_id), 1) season_rating
       , fv.series_rating  
FROM lostfilm.dim_film_seasons s
LEFT JOIN lostfilm.dim_film_series fs ON s.id = fs.season_id
LEFT JOIN (
           SELECT series_id
                  , ROUND(AVG(rating), 1) series_rating
           FROM lostfilm.fact_film_views
           WHERE rating > 0
           GROUP BY 1
           ) fv 
           ON fs.id = fv.series_id
JOIN lostfilm.dim_films f ON s.film_id = f.id);



-- ПРЕДСТАВЛЕНИЕ №3
/* В типовых запросах зачастую используется не одна какая-то сущность (например, сериал), а вся иерархия объектов 'сериал - сезон - серия'.
Поэтому имеет смысл создать вью lostfilm.film_components_view, которая показывает мэппинг 'сериал - сезон - серия' и которая упростит написание типовых запросов. */

DROP VIEW IF EXISTS lostfilm.film_components_view;
CREATE VIEW lostfilm.film_components_view AS (
SELECT s.film_id
       , s.id season_id
       , fs.id series_id
FROM lostfilm.dim_film_seasons s
JOIN lostfilm.dim_film_series fs on fs.season_id = s.id);



-- ПРЕДСТАВЛЕНИЕ №4
/* Данная вьюшка будет использоваться в работе триггера. Ее задача - показать, по каким сезонам есть расхождение между:
- числом изначально заявленных серий, зафиксированным в поле series_num в таблице dim_film_season
- и числом реально добавленных серий в dim_film_season

Реальный прецедент есть на сайте LostFilm, когда по сезону указано, что количество вышедших серий: 13 (из 9). */

DROP VIEW IF EXISTS lostfilm.check_series_num_view;
CREATE VIEW lostfilm.check_series_num_view AS (
SELECT s.id season_id
       , s.series_num  -- число заявленных серий в сезоне
       , COUNT(fs.id) series_real  -- число реально добавленных серий на сайт
FROM lostfilm.dim_film_seasons s
LEFT JOIN lostfilm.dim_film_series fs ON s.id = fs.season_id
GROUP BY 1, 2
HAVING s.series_num < count(fs.id));



-- 5. ХРАНИМЫЕ ПРОЦЕДУРЫ И ТРИГГЕРЫ
/* В процессе работы с сайтом встретился интересный момент: показан сезон сериала (например, 1 сезон сериала "Бумажный дом", https://www.lostfilm.run/series/La_Casa_de_Papel/seasons) и указано, что количество вышедших серий: 13 (из 9).
По факту на сайте выложено 13 серий для просмотра, что значит число 9 некорректно и должно быть 13 (из 13).

Для предотвращения подобных ситуаций была разработана 1 процедура и 1 триггер:
1) insert_new_series - процедура для внесения информации о новой серии сериала в таблицу dim_film_series;
2) check_series_num_after_insert - триггер для выявления случаев, когда число серий изначально заявленных в сезоне не соответствует числу реально вышедших серий, и корректировки значения series_num в таблице dim_film_seasons. */


-- ХРАНИМАЯ ПРОЦЕДУРА

DROP PROCEDURE IF EXISTS insert_new_series;
DELIMITER //
CREATE PROCEDURE insert_new_series (IN season_id BIGINT, IN series_id INTEGER, IN name VARCHAR(255), IN premiere_date DATE, IN lenght INTEGER, IN imdb_rating FLOAT(1))
BEGIN
     INSERT INTO lostfilm.dim_film_series (season_id, series_id, name, premiere_date, lenght, imdb_rating) 
     VALUES(season_id, series_id, name, premiere_date, lenght, imdb_rating);
end //
DELIMITER ;   


-- ТРИГГЕР

DROP TRIGGER IF EXISTS check_series_num_after_insert;

DELIMITER //

CREATE TRIGGER check_series_num_after_insert AFTER INSERT ON lostfilm.dim_film_series
FOR EACH ROW
BEGIN 
     IF (SELECT COUNT(*) FROM lostfilm.check_series_num_view) > 0 THEN
     INSERT INTO trigger_logs (season_id, series_num_before_change, series_num_after_change)
     SELECT * FROM lostfilm.check_series_num_view;
    
     UPDATE lostfilm.dim_film_seasons
     SET series_num = series_num + 1
     WHERE id IN (SELECT season_id FROM lostfilm.check_series_num_view);

     END IF;
END //
DELIMITER ;


-- ТЕСТИРОВАНИЕ РАБОТЫ ХРАНИМОЙ ПРОЦЕДУРЫ И ТРИГГЕРА

/*Возьмем сезон 47 и 48 для тестирования. Посмотрим на число серий, прописанных в series_num поле в таблице dim_film_seasons.
47 сезон - 10 серий, 48 сезон - 16 серий.*/

SELECT id
       , series_num 
FROM lostfilm.dim_film_seasons
WHERE id IN (47, 48);


/*Запускаем процедуру на вставление 2х строк - одна новая серия по 47 сезону, одна - по 48. */

CALL insert_new_series(47, 11, 'Test Row 1 for Stored Procedure Check', '2020-10-02', 45, 7.7);
CALL insert_new_series(48, 17, 'Test Row 2 for Stored Procedure Check', '2020-10-02', 45, 7.7);


/*Проверяем таблицу dim_film_seasons и таблицу trigger_logs. Значения series_num в таблице dim_film_seasons увеличились на 1 для сезонов 47 и 48, изменения зафиксированы в лог-файле.*/

SELECT id
       , series_num 
FROM lostfilm.dim_film_seasons
WHERE id IN (47, 48);


SELECT *
FROM trigger_logs;
