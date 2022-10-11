USE twitch;

-- #1
/*Пользователи отправившие сообщения в чат выбранного пользователя и являющиеся 
его платным подписчиком (subscriptions), а также количество сообщений отправленных ими в его чат*/
SELECT cm.from_user_id, COUNT(*) FROM chat_messages cm
JOIN follows_subscriptions f_s ON cm.from_user_id = f_s.from_user_id 
WHERE chat_id = 1 AND f_s.target_channel_id = 1 AND f_s.status = 'subscriber'
GROUP BY cm.from_user_id;


-- #2
/*Количество подписчиков (follows) у каналов, которые сейчас ведут прямой эфир и категория
которую они сейчас стримят*/
SELECT c.name, l.channel_id, COUNT(*) FROM follows_subscriptions fs 
JOIN live l ON l.channel_id = fs.target_channel_id 
JOIN categories c ON c.id = l.streaming_category_id 
WHERE l.is_live = 1 AND fs.status = 'follower'
GROUP BY l.channel_id;

-- #3
/*Среднее количество всех сообщений отправленных пользователями в чаты*/
SELECT AVG(total_chat_messages) AS avg_chat_messages 
FROM (
SELECT u.id, u.username, COUNT(*) AS total_chat_messages FROM users u
JOIN chat_messages cm ON u.id = cm.from_user_id
GROUP BY u.id
ORDER BY total_chat_messages DESC) AS cat
;


-- #4
/*Категории являющиеся киберспортивными, по которым в данный момент ведется стрим, и также 
псевдоним пользователя ведущего стрим*/
SELECT u.id, u.username, c.name FROM categories c 
JOIN esports e ON c.id = e.category_id 
JOIN live l ON l.streaming_category_id = e.category_id 
JOIN channels ch ON l.channel_id = ch.user_id 
JOIN users u ON ch.user_id = u.id 
;


-- #5 
/*Количество подписчиков (follows) у платных подписчиков (subscriptions) выбранного пользователя*/
SELECT u.id, u.username, COUNT(*) FROM follows_subscriptions fs 
JOIN channels c ON fs.target_channel_id = c.user_id 
JOIN follows_subscriptions fs2 ON fs2.from_user_id = c.user_id 
JOIN users u ON c.user_id = u.id 
WHERE fs2.target_channel_id = 1 AND fs2.status = 'subscriber' AND fs.status = 'follower'
GROUP BY fs.target_channel_id
;


-- #6
/*Количество сообщений выбранному пользователю отправленных после или в 2021 году
от его подписчиков (follows) подписавшихся на него после или в 2019 году*/
SELECT u.id, u.username, COUNT(*) FROM messages m 
JOIN follows_subscriptions fs ON m.from_user_id = fs.from_user_id 
JOIN users u ON u.id = fs.from_user_id 
WHERE fs.created_at >= '2019-01-01 00:00:00' AND m.created_at >= '2021-01-01 00:00:00'
AND m.to_user_id = 2 AND fs.target_channel_id = 2 AND fs.status = 'follower'
GROUP BY u.id 
;





















































