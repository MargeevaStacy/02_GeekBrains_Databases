-- Задание 4: Определить кто больше поставил лайков (всего) - мужчины или женщины?
-- Решение построено на подсчеты лайков постов из таблицы likes_posts, где profile_id - это id пользователя, поставившего лайк
-- Ответ: женщины

select u.gender,
       count(lp.id) likes
from users u
join likes_posts lp on u.id = lp.profile_id
group by 1
order by 2 desc
limit 1
