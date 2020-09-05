/* ������� 2: �������� ����������� �������/������� ��� ����, ����� ����� ���� ������������ ����� ��� �����������, ������ � �������������.

�������:
������� 4 �������: objects, object_types, object_statuses, likes
���������� ��� ����� �������� object_id, object_type_id etc., �� ����� �������� �������� � ������ �� ���������� �� dummy values,
������� ������ ��� ����� ���������� id.

������� objects �������� ������� ��� �������, ������� ������������ ����� ��������� � ������� - �����, �����������, �����, ����������, ������.
�.�. � ��� ������, ����� ������������ ���-�� ������� � �������, ��������� object_id � �������������� ����� �������.
����� �������� ������ � ������� objects, ������ � object_id ����������� � ��������������� dim-��, ����. � ������� posts, comments � ��.
���� object_id ���� ��������� � ��� ������� � �������� �������� �����.
���� �������� �������� � object_types �������, ������� - � ������� object_statuses.
������� likes �������� ��� �����, �����-���� ������������ �����������, ��� ���� �������� � ������������, ������������ ���� � ���������� �������.
����� ������ ����� ��������� ��� count(like_id) �� ������� object_id ��� user_id.
*/


drop table if exists object_types;
create table object_types(
	id serial primary key,
	object_type_desc varchar(50) not null, # 'post', 'comment', 'photo', 'song', 'album', 'video' etc.
	created_at datetime default now(),
	updated_at datetime default now(),
	index(object_type_desc)
);

drop table if exists object_statuses;
create table object_statuses(
	id serial primary key,
	object_status_desc varchar(50) not null, # 'visible', 'deleted'
	created_at datetime default now(),
	updated_at datetime default now(),
	index(object_status_desc)
);

drop table if exists objects;
create table objects(
	id serial primary key,
	object_name varchar(250),
	object_type_id bigint unsigned not null,
	object_status_id bigint unsigned not null,
	user_id bigint unsigned not null, # ������������, ��������� ������ (owner �������)
    num_of_likes bigint unsigned default 0, # ����� ������ �������, count(l.like_id) from likes l join objects o on o.id = l.object_id
    num_of_shares bigint unsigned default 0, # ����� ���, ����� �������� ����������, ����� ������� ��������������� �������
    num_of_comments bigint unsigned default 0, # ����� ������������ �������, count(c.id) from comments l join objects o on o.id = c.object_id
	created_at datetime default now(),
	updated_at datetime default now(),
	foreign key (object_type_id) references object_types(id),
	foreign key (object_status_id) references object_statuses(id),
	foreign key (user_id) references users(id),
	index(id),
	index(object_name),
	index(user_id)
);

drop table if exists likes;
create table likes(
	like_id serial primary key,
	user_id bigint unsigned not null, # ��� �������
	object_id bigint unsigned not null, # ��� �������
	like_status ENUM('liked', 'disliked') not null default 'liked', # ����� ��������, � ����� �������� ����
	created_at datetime default now(), 	# ����� �������
	updated_at datetime default now(),
	foreign key (user_id) references users(id),
	foreign key (object_id) references objects(id),
	index(user_id),
	index(object_id)
);


drop table if exists posts;
create table posts(
	id serial primary key,
	user_id bigint unsigned not null,
	object_id bigint unsigned not null,
	body text,
	created_at datetime default current_timestamp,
	updated_at datetime,
	foreign key (user_id) references users(id),
	foreign key (object_id) references objects(id),
	index(user_id),
	index(object_id)
);

drop table if exists comments;
create table comments(
	id serial primary key,
	user_id bigint unsigned not null,
	post_id bigint unsigned not null,
	object_id bigint unsigned not null,
	body text,
	created_at datetime default current_timestamp,
	foreign key (user_id) references users(id),
	foreign key (post_id) references posts(id),
	foreign key (object_id) references objects(id),
	index(user_id),
	index(object_id)
);

drop table if exists photos;
create table photos(
	id serial primary key,
	user_id bigint unsigned not null,
	object_id bigint unsigned not null,
	description varchar(255),
	created_at datetime default current_timestamp,
	foreign key (user_id) references users(id),
	foreign key (object_id) references objects(id),
	index(user_id),
	index(object_id)
);
