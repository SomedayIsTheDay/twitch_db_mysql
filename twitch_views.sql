USE twitch;

-- #1 Представление подсчета на сколько каналов каждый пользователь подписался платно и бесплатно
CREATE OR REPLACE VIEW v_subscribers_followers
AS 
SELECT u.id, u.username, status, COUNT(*) FROM users u 
JOIN follows_subscriptions f_s ON u.id = f_s.from_user_id 
GROUP BY u.id, f_s.status 
ORDER BY u.id
;
SELECT * FROM v_subscribers_followers;


-- #2 Представление пользователей, а также отправленных и полученных ими сообщений 
CREATE OR REPLACE VIEW v_users_messages
AS 
SELECT u.id, u.username, m.from_user_id, m.to_user_id, m.body, m.created_at FROM users u 
JOIN messages m ON u.id = m.from_user_id 
UNION ALL 
SELECT u.id, u.username, m.from_user_id, m.to_user_id, m.body, m.created_at FROM users u
JOIN messages m ON u.id = m.to_user_id 
ORDER BY id
;
SELECT * FROM v_users_messages;

























































