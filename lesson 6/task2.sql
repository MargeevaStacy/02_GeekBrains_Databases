/* Задание 2: Пусть задан некоторый пользователь.
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

Решение: возьмем пользователя №70, найдем его друзей, найдем все поступившие от друзей сообщения и все отправленные друзьям сообщения.
Затем выявим, с кем наш пользователь чаще всего общался из друзей.*/

SELECT m.user_id,
       m.messages
FROM (
		SELECT case when from_user_id = 70 then to_user_id
            		when to_user_id = 70 then from_user_id
               end user_id,
               count(id) messages
		FROM messages
        WHERE from_user_id = 70 or to_user_id = 70
        GROUP BY 1
) m -- считаем число сообщений, отправленных пользователем №70 и полученных пользователем №70, по каждому пользователю, с которым велась переписка
JOIN (
		SELECT case when initiator_user_id = 70 then target_user_id
                  when target_user_id = 70 then initiator_user_id
             end friend_id
      FROM friend_requests
      WHERE status = 'approved' and (initiator_user_id = 70 or target_user_id = 70)
) fr -- ищем список друзей пользователя №70
		on m.user_id = fr.friend_id
ORDER BY 2 desc
LIMIT 1


-- Пыталась написать запрос на базе вложенных запросов, чтобы в результате выводился не 1 пользователь, а несколько,
-- в случае если несколько пользователей отправили одно и то же число сообщений.
-- Но не нашла решения, где можно обойтись без window функции или временных табличек или CTE.


select r.user_id
from (
		select m.user_id,
      		   rank() over (order by m.messages desc) rank_num
from (
		select case when from_user_id = 70 then to_user_id
            		when to_user_id = 70 then from_user_id
               end user_id,
               count(id) messages
		from messages
        where from_user_id = 70 or to_user_id = 70
        group by 1
) m -- считаем число сообщений, отправленных пользователем №70 и полученных пользователем №70, по каждому пользователю, с которым велась переписка
join (
		select case when initiator_user_id = 70 then target_user_id
                  when target_user_id = 70 then initiator_user_id
             end friend_id
      from friend_requests
      where status = 'approved' and (initiator_user_id = 70 or target_user_id = 70)
) fr -- ищем список друзей пользователя №70
		on m.user_id = fr.friend_id
) r
where r.rank_num = 1
