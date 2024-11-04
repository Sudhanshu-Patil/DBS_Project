--Triggers for the database

-- Trigger for the table 'users'
CREATE OR REPLACE TRIGGER users_trigger
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    SELECT user_id_seq.NEXTVAL
    INTO :NEW.user_id
    FROM dual;
END;
/

--Trigger for the table 'posts'
CREATE OR REPLACE TRIGGER posts_trigger
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    SELECT post_id_seq.NEXTVAL
    INTO :NEW.post_id
    FROM dual;
END;
/


--Premium user trigger if more posts than 3
CREATE OR REPLACE TRIGGER premium_user_trigger
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    IF :NEW.user_id IN (SELECT user_id FROM posts GROUP BY user_id HAVING COUNT(*) > 3) THEN
        UPDATE users
        SET is_premium = 1
        WHERE user_id = :NEW.user_id;
    END IF;
END;