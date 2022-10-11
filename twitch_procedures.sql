USE twitch;

-- #1
-- Процедура заканчивает стрим (прямой эфир) и добавляет запись стрима в медиа
DROP PROCEDURE IF EXISTS twitch.sp_add_media_after_live;

DELIMITER $$
$$
CREATE PROCEDURE twitch.sp_add_media_after_live(media_id BIGINT, channel BIGINT, bodyy VARCHAR(255),
extensionn VARCHAR(100), sizee BIGINT, OUT tran_result VARCHAR(100))
BEGIN
	DECLARE `_rollback` BIT DEFAULT 0;
	DECLARE code varchar(100);
	DECLARE error_string varchar(100); 


	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
 		SET `_rollback` = 1;
 		GET stacked DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		SET tran_result = concat('Произошла шибка: ', code, ' Текст ошибки: ', error_string);
	END;

	START TRANSACTION;
	UPDATE live SET 
	is_live = 0,
	streaming_category_id = NULL
	WHERE channel_id = channel AND is_live = 1;

	INSERT media (id, media_type_id, user_id, body, extension, `size`)
	VALUES (media_id, 2, channel, bodyy, extensionn, sizee);
	
	
	IF `_rollback` THEN
		SET tran_result = 'Rollbacked';
		ROLLBACK;
	ELSE
		SET tran_result = 'Committed';
		COMMIT;
	END IF;
END$$
DELIMITER ;
CALL sp_add_media_after_live(51, 2, 'adsd', 'mp4', 341345, @tran_result);
SELECT @tran_result;


-- #2
-- Процедура удаляет или изменяет сообщение
DROP PROCEDURE IF EXISTS twitch.sp_delete_or_update_message;

DELIMITER $$
$$
CREATE PROCEDURE twitch.sp_delete_or_update_message(choice TINYINT, message_id BIGINT, 
new_body TEXT)
BEGIN
	IF choice = 1 THEN 
		UPDATE twitch.messages SET 
		body = new_body
		WHERE id = message_id;
	ELSEIF choice = 0 THEN 
		DELETE FROM messages 
		WHERE id = message_id;
	ELSE 
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = 'You must choose only 1 (update) or 0 (delete)';
	END IF;
END$$
DELIMITER ;
CALL sp_delete_or_update_message(1, 3, 'asdasdsad'); -- проверка обновления
CALL sp_delete_or_update_message(0, 3, NULL); -- проверка удаления
CALL sp_delete_or_update_message(2, 3, NULL); -- проверка ошибки

-- #3 
-- Функция высчитывает соотношение количества выбранного типа медиа к другим типам
DROP FUNCTION IF EXISTS twitch.media_type_ratio;

DELIMITER $$
$$
CREATE FUNCTION twitch.media_type_ratio(media_type_name VARCHAR(50))
RETURNS FLOAT READS SQL DATA
BEGIN
	DECLARE video BIGINT; 
	DECLARE photo BIGINT; 
	DECLARE GIF BIGINT;

	SET video = (
		SELECT count(*) 
		FROM media
		WHERE media_type_id = 2
		);
	
	SET photo = (
		SELECT count(*) 
		FROM media
		WHERE media_type_id = 1
		); 
	
	SELECT count(*)
	INTO  GIF
	FROM media
	WHERE media_type_id = 3; 

	IF media_type_name = 'video' THEN
		RETURN video / (photo+GIF);
		
	ELSEIF media_type_name = 'photo' THEN
		RETURN photo / (video+GIF);
		
	ELSEIF media_type_name = 'GIF' THEN
		RETURN GIF / (photo+video);	
		
	ELSE 
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = 'You must choose only "video", "photo", or "GIF"';
	END IF;
END$$
DELIMITER ;
SELECT media_type_ratio('video');
SELECT media_type_ratio('photo');
SELECT media_type_ratio('GIF');















































































