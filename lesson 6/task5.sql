-- Задание 5: Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- Определим наименьшую активность как число различного рода объектов, созданных пользователем в системе: посты, комментарии, фотки.

SELECT u.id,
       u.name,
       u.surname,
       u.gender,
       u.birthday,
       u.hometown,
       count(p.id) posts,
       count(p2.id) photos,
       count(c.id) comments,
       count(p.id) + count(p2.id) + count(c.id) activity_score
FROM users u
LEFT JOIN posts p on u.id = p.user_id
LEFT JOIN photos p2 on u.id = p2.user_id
LEFT JOIN comments c on u.id = c.user_id
GROUP BY 1,2,3,4,5,6
ORDER BY 10
LIMIT 10
