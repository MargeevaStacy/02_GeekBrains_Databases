-- Задание 1: Проанализировать запросы, которые выполнялись на занятии, определить возможные корректировки и/или улучшения (JOIN пока не применять).

-- Пример поиска друзей пользователя, использованный на уроке
select *
from (
      select case when initiator_user_id = 1 and status = 'approved' then target_user_id
                  when target_user_id = 1 and status = 'approved' then initiator_user_id
             end friend_id
      from friend_requests fr) as fr_list
where friend_id is not null

-- Можно немного упростить - вынести все повторяющиеся элементы в where clause - чтобы убрать подзапрос
select case when initiator_user_id = 1 and status = 'approved' then target_user_id
            when target_user_id = 1 and status = 'approved' then initiator_user_id
       end friend_id
from friend_requests
where status = 'approved' and (initiator_user_id = 1 or target_user_id = 1)
