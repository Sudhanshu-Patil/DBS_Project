-- Hash tags followed by user
CREATE OR REPLACE PROCEDURE hash_tags_followed_by_user(
    user_id IN NUMBER
)
IS
    hashtag_cursor SYS_REFCURSOR;
BEGIN
    OPEN hashtag_cursor FOR
        SELECT hashtag_id, hashtag_name
        FROM hashtags
        WHERE hashtag_id IN (
            SELECT hashtag_id
            FROM hashtag_follow
            WHERE user_id = user_id
        );
    -- Example output (for testing purposes)
    LOOP
        FETCH hashtag_cursor INTO hashtag_id, hashtag_name;
        EXIT WHEN hashtag_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Hashtag ID: ' || hashtag_id || ', Name: ' || hashtag_name);
    END LOOP;
    CLOSE hashtag_cursor;
END;
/

-- Hash tags not followed by user
CREATE OR REPLACE PROCEDURE hash_tags_not_followed_by_user(
    user_id IN NUMBER
)
IS
    hashtag_cursor SYS_REFCURSOR;
BEGIN
    OPEN hashtag_cursor FOR
        SELECT hashtag_id, hashtag_name
        FROM hashtags
        WHERE hashtag_id NOT IN (
            SELECT hashtag_id
            FROM hashtag_follow
            WHERE user_id = user_id
        );
    -- Example output (for testing purposes)
    LOOP
        FETCH hashtag_cursor INTO hashtag_id, hashtag_name;
        EXIT WHEN hashtag_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Hashtag ID: ' || hashtag_id || ', Name: ' || hashtag_name);
    END LOOP;
    CLOSE hashtag_cursor;
END;
/

-- Retrieve all posts for a user's feed
CREATE OR REPLACE PROCEDURE show_user_feed (
    user_id_in IN NUMBER,
    posts_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN posts_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        JOIN follows f ON u.user_id = f.followee_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        WHERE f.follower_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at,
                 ph.photo_url, v.video_url, u.username, u.profile_photo_url
        ORDER BY p.created_at DESC;
END;
/

--Retreive details of post
CREATE OR REPLACE PROCEDURE show_post_details (
    post_id_in IN NUMBER,
    post_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN post_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        WHERE p.post_id = post_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at,
                 ph.photo_url, v.video_url, u.username, u.profile_photo_url;
END;
/

-- Retrieve all comments for a post with likes
CREATE OR REPLACE PROCEDURE show_comments_for_post (
    post_id_in IN NUMBER,
    comments_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN comments_cursor FOR
        SELECT c.comment_id, c.comment_text, c.created_at,
               u.user_id, u.username, u.profile_photo_url,
               COUNT(cl.user_id) AS likes
        FROM comments c
        JOIN users u ON c.user_id = u.user_id
        LEFT JOIN comment_likes cl ON c.comment_id = cl.comment_id
        WHERE c.post_id = post_id_in
        GROUP BY c.comment_id, c.comment_text, c.created_at,
                 u.user_id, u.username, u.profile_photo_url
        ORDER BY c.created_at DESC;
END;
/

-- Retrieve all hashtags for a post
CREATE OR REPLACE PROCEDURE show_hashtags_for_post (
    post_id_in IN NUMBER,
    hashtags_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN hashtags_cursor FOR
        SELECT h.hashtag_id, h.hashtag_name
        FROM hashtags h
        JOIN post_tags pt ON h.hashtag_id = pt.hashtag_id
        WHERE pt.post_id = post_id_in;
END;
/

--Retrieve all users and pfp
CREATE OR REPLACE PROCEDURE retrieve_all_users_and_pfp (
    users_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN users_cursor FOR
        SELECT user_id, username, profile_photo_url
        FROM users;
END;
/

CREATE OR REPLACE PROCEDURE show_user_details(
    user_id_in IN NUMBER,
    user_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN user_cursor FOR
        SELECT username, email, bio, created_at
        FROM users
        WHERE user_id = user_id_in;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No user found with the specified ID.');
END;
/


--Retrieve all posts based on hashtags followed by user
CREATE OR REPLACE PROCEDURE retrieve_posts_by_followed_hashtags (
    user_id_in IN NUMBER,
    posts_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN post_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        JOIN post_tags pt ON p.post_id = pt.post_id
        JOIN hashtag_follow hf ON pt.hashtag_id = hf.hashtag_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        WHERE hf.user_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at,
                 ph.photo_url, v.video_url, u.username, u.profile_photo_url
        ORDER BY p.created_at DESC;
END;
/

--Add a comment
CREATE OR REPLACE PROCEDURE add_comment (
    user_id_in IN NUMBER,
    post_id_in IN NUMBER,
    comment_text_in IN VARCHAR2
)
IS
BEGIN
    INSERT INTO comments (comment_text, post_id, user_id)
    VALUES (comment_text_in, post_id_in, user_id_in);
END;
--Retrieve USERS liking a post
CREATE OR REPLACE PROCEDURE retrieve_users_liking_post (
    post_id_in IN NUMBER,
    users_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN users_cursor FOR
        SELECT u.user_id, u.username, u.profile_photo_url
        FROM users u
        JOIN post_likes pl ON u.user_id = pl.user_id
        WHERE pl.post_id = post_id_in;
END;
/
