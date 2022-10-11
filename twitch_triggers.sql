USE twitch;

-- #1
-- триггеры логов
-- 1)
DROP TRIGGER IF EXISTS users_logs_after_insert;
DELIMITER $$
$$
CREATE TRIGGER users_logs_after_insert
AFTER INSERT
ON users FOR EACH ROW
BEGIN 
	INSERT INTO twitch.logs (id, table_name, username, email, created_at) 
    VALUES (NEW.id, (SELECT TABLE_NAME FROM information_schema.TABLES 
	WHERE TABLE_SCHEMA = 'twitch' AND TABLE_NAME = 'users'), NEW.username, NEW.email, NOW());
END 
$$
DELIMITER ;
INSERT users VALUES 
(12,'willms.rafael','Impedit rerum qui et id sunt.','trutrford@example.com',767746); -- проверка

-- 2)
DROP TRIGGER IF EXISTS chat_messages_logs_after_insert;
DELIMITER $$
$$
CREATE TRIGGER chat_messages_logs_after_insert
AFTER INSERT
ON chat_messages FOR EACH ROW
BEGIN 
	INSERT INTO twitch.logs (id, table_name, chat_id, from_user_id, body, created_at) 
    VALUES (NEW.id, (SELECT TABLE_NAME FROM information_schema.TABLES 
	WHERE TABLE_SCHEMA = 'twitch' AND TABLE_NAME = 'chat_messages'),
	NEW.chat_id, NEW.from_user_id, NEW.body, NEW.created_at);
END 
$$
DELIMITER ;
INSERT chat_messages (chat_id, from_user_id, body, created_at) VALUES 
(1,5,'nditiis quibusdam. Voluptate in quam nam fuga a.','2019-12-25 01:30:46'); -- проверка

-- 3)
DROP TRIGGER IF EXISTS messages_logs_after_insert;
DELIMITER $$
$$
CREATE TRIGGER messages_logs_after_insert
AFTER INSERT
ON messages FOR EACH ROW
BEGIN 
	INSERT INTO twitch.logs (id, table_name, from_user_id, to_user_id, body, created_at) 
    VALUES (NEW.id, (SELECT TABLE_NAME FROM information_schema.TABLES 
	WHERE TABLE_SCHEMA = 'twitch' AND TABLE_NAME = 'messages'),
	NEW.from_user_id, NEW.to_user_id, NEW.body, NEW.created_at); 
END 
$$
DELIMITER ;
INSERT messages (from_user_id, to_user_id, body, created_at) VALUES 
(1,6,'ure velit rerum esse. Impedit ver voluptatum at.','2019-09-07 11:50:31'); -- проверка

-- 4)
DROP TRIGGER IF EXISTS users_logs_before_delete;
DELIMITER $$
$$
CREATE TRIGGER users_logs_before_delete
BEFORE DELETE
ON users FOR EACH ROW
BEGIN 
	INSERT INTO twitch.logs (id, table_name, username, email, created_at, is_deleted) 
    VALUES (OLD.id, (SELECT TABLE_NAME FROM information_schema.TABLES 
	WHERE TABLE_SCHEMA = 'twitch' AND TABLE_NAME = 'users'), OLD.username, OLD.email, NOW(), 1);
END $$
DELIMITER ;
DELETE FROM users
WHERE id = 12; -- проверка


-- #2
-- триггер проверяющий правильность email'a
DROP TRIGGER IF EXISTS check_users_email;
DELIMITER $$
$$
CREATE TRIGGER check_users_email
BEFORE INSERT
ON users FOR EACH ROW
begin
    IF NEW.email NOT LIKE '%@%' THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Your email is invalid. Email must contain "@"';
    END IF;
END$$
DELIMITER ;
INSERT users VALUES 
(11,'emmie69','Soluta adipisci quia non.','chaya58xample.net',NULL); -- проверка

































