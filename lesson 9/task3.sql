/* Задание 3: Пусть имеется таблица с календарным полем created_at.
В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2018-08-04', '2018-08-16' и '2018-08-17'.
Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1,
если дата присутствует в исходном таблице и 0, если она отсутствует.
 */

drop table if exists dates_given;
create table dates_given (
dates date
) COMMENT 'таблица с датами, указанными в задании';

insert dates_given
values ('2018-08-01'), ('2018-08-04'), ('2018-08-16'), ('2018-08-17');

with recursive dates_range as (
select date('2018-08-01') as all_dates

union all

select date_add(all_dates, interval '1' day)
from dates_range
where all_dates < '2018-08-31')

select *,
       case when t2.dates is not null then 1 else 0 end marker
from dates_range t1
left join dates_given t2 on t1.all_dates = t2.dates
