DROP DATABASE IF EXISTS twitch;
CREATE DATABASE twitch;
USE twitch;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs(
	id BIGINT UNSIGNED NOT NULL,
	table_name VARCHAR(255) NOT NULL,
	chat_id BIGINT UNSIGNED DEFAULT NULL,
	from_user_id BIGINT UNSIGNED DEFAULT NULL,
	to_user_id BIGINT UNSIGNED DEFAULT NULL,
	body TEXT DEFAULT NULL,
	username VARCHAR(100) DEFAULT NULL,
	email VARCHAR(100) DEFAULT NULL,
	created_at DATETIME NOT NULL,
	is_deleted BIT DEFAULT NULL
) ENGINE=Archive;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    bio VARCHAR(300) DEFAULT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone BIGINT DEFAULT NULL,
    INDEX users_username_idx(username)
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
	id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	media_type_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED,
	body VARCHAR(255),
	extension VARCHAR(100),
	`size` BIGINT,
	created_at TIMESTAMP DEFAULT NOW(),
	INDEX media_user_id_idx(user_id),
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (media_type_id) REFERENCES media_types(id) ON UPDATE CASCADE ON DELETE CASCADE
); 

DROP TABLE IF EXISTS category_types;
CREATE TABLE category_types (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);

DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
	id SERIAL PRIMARY KEY,
	category_type_id BIGINT UNSIGNED NOT NULL,
	name VARCHAR(150),
	category_icon_id BIGINT UNSIGNED DEFAULT NULL,
	INDEX categories_name_idx(name),
	FOREIGN KEY (category_type_id) REFERENCES category_types(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (category_icon_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS esports;
CREATE TABLE esports(
	category_id SERIAL PRIMARY KEY,
	FOREIGN KEY (category_id) REFERENCES categories(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS channels;
CREATE TABLE channels (
	user_id SERIAL PRIMARY KEY,
	channel_picture_id BIGINT UNSIGNED DEFAULT NULL,
	profile_banner_id BIGINT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (channel_picture_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (profile_banner_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS live;
CREATE TABLE live (
	channel_id SERIAL PRIMARY KEY,
	is_live BIT DEFAULT 0,
	streaming_category_id BIGINT UNSIGNED DEFAULT NULL,
	FOREIGN KEY (channel_id) REFERENCES channels(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (streaming_category_id) REFERENCES categories(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS follows_subscriptions;
CREATE TABLE follows_subscriptions(
	from_user_id BIGINT UNSIGNED NOT NULL,
	target_channel_id BIGINT UNSIGNED NOT NULL,
	status ENUM('subscriber', 'follower'), 
	created_at DATETIME DEFAULT NOW(),
	PRIMARY KEY (from_user_id, target_channel_id, status),
	FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (target_channel_id) REFERENCES channels(user_id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS messages; 
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at TIMESTAMP DEFAULT NOW(),
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX messages_from_user_id_idx (from_user_id),
    INDEX messages_to_user_id_idx (to_user_id),
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS chats; -- чат канала, в котором переписываются юзеры
CREATE TABLE chats (
	channel_id SERIAL PRIMARY KEY,
	FOREIGN KEY (channel_id) REFERENCES channels(user_id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS chat_messages; -- сообщения в чате 
CREATE TABLE chat_messages (
	id SERIAL PRIMARY KEY,
	chat_id BIGINT UNSIGNED NOT NULL,
	from_user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at TIMESTAMP DEFAULT NOW(),
	INDEX chat_messages_from_user_id_idx (from_user_id),
	FOREIGN KEY (chat_id) REFERENCES chats(channel_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

























