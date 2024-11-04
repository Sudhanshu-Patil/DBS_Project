--Create a new login entries

CREATE OR REPLACE PROCEDURE create_new_login(
    email_in IN VARCHAR2,
    password_in IN VARCHAR2,
    login_id_out OUT NUMBER
)
IS
    user_id_int NUMBER;
BEGIN
    SELECT user_id INTO user_id_int
    FROM users
    WHERE email = email_in AND passkey = password_in;

    INSERT INTO login(user_id)
    VALUES (user_id_int)
    RETURNING login_id INTO login_id_out;
END;
/



--Create a new user

CREATE OR REPLACE PROCEDURE create_new_user(
    name_in IN VARCHAR2,
    email_in IN VARCHAR2,
    bio_in IN VARCHAR2,
    password_in IN VARCHAR2,
    user_id_out OUT NUMBER,
    login_id_out OUT NUMBER
)
IS
BEGIN
    -- Insert the new user and retrieve the generated user_id
    INSERT INTO users(username, email, bio, passkey)
    VALUES(name_in, email_in, bio_in, password_in)
    RETURNING user_id INTO user_id_out;

    -- Insert a login record for the new user and retrieve the generated login_id
    INSERT INTO login(user_id)
    VALUES(user_id_out)
    RETURNING login_id INTO login_id_out;

    -- Output messages for debugging
    DBMS_OUTPUT.PUT_LINE('User Created with ID: ' || user_id_out);
    DBMS_OUTPUT.PUT_LINE('Login Created with ID: ' || login_id_out);
END;
/



-- Procedure for user to update his details

CREATE OR REPLACE PROCEDURE update_user_details(
    user_id_in IN NUMBER,
    name_in IN VARCHAR2,
    email_in IN VARCHAR2,
    bio_in IN VARCHAR2
)
IS
BEGIN
    UPDATE users
    SET username = name_in, email = email_in, bio = bio_in
    WHERE user_id = user_id_in;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No user found with the specified ID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('User Details Updated');
    END IF;
END;
/



-- Procedure to update his password

CREATE OR REPLACE PROCEDURE update_user_password(
    user_id_in IN NUMBER,
    password_in IN VARCHAR2
)
IS
BEGIN
    UPDATE users
    SET passkey = password_in
    WHERE user_id = user_id_in;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No user found with the specified ID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Password Updated');
    END IF;
END;
/


-- Procedure to show user his posts

CREATE OR REPLACE PROCEDURE show_user_posts(
    user_id_in IN NUMBER,
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
        WHERE p.user_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at, ph.photo_url, v.video_url, u.username, u.profile_photo_url;
END;
/



-- Procedure to show user his comments on a specific post

CREATE OR REPLACE PROCEDURE show_user_comments_on_post(
    user_id_in IN NUMBER,
    post_id_in IN NUMBER
)
IS
BEGIN
    FOR comment IN (
        SELECT comment_id, comment_text, created_at
        FROM comments
        WHERE user_id = user_id_in AND post_id = post_id_in
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Comment ID: ' || comment.comment_id);
        DBMS_OUTPUT.PUT_LINE('Comment Content: ' || comment.comment_text);
        DBMS_OUTPUT.PUT_LINE('Comment Created At: ' || comment.created_at);
    END LOOP;
END;
/

-- Procedure to show user his followers

CREATE OR REPLACE PROCEDURE show_user_followers(
    user_id_in IN NUMBER,
    followers_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN followers_cursor FOR
        SELECT u.user_id AS follower_id, u.username, u.profile_photo_url, u.created_at
        FROM users u
        WHERE u.user_id IN (
            SELECT f.follower_id
            FROM follows f
            WHERE f.followee_id = user_id_in
        );
END;
/

-- Procedure to show user his liked posts

CREATE OR REPLACE PROCEDURE show_user_liked_posts(
    user_id_in IN NUMBER
)
IS
BEGIN
    FOR post IN (
        SELECT post_id, caption, created_at
        FROM post
        WHERE post_id IN (
            SELECT post_id
            FROM post_likes
            WHERE user_id = user_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Post ID: ' || post.post_id);
        DBMS_OUTPUT.PUT_LINE('Post Caption: ' || post.caption);
        DBMS_OUTPUT.PUT_LINE('Post Created At: ' || post.created_at);
    END LOOP;
END;
/


-- Procedure to show user his liked comments

CREATE OR REPLACE PROCEDURE show_user_liked_comments(
    user_id_in IN NUMBER
)
IS
BEGIN
    FOR comment IN (
        SELECT comment_id, comment_text, created_at
        FROM comments
        WHERE comment_id IN (
            SELECT comment_id
            FROM comment_likes
            WHERE user_id = user_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Comment ID: ' || comment.comment_id);
        DBMS_OUTPUT.PUT_LINE('Comment Content: ' || comment.comment_text);
        DBMS_OUTPUT.PUT_LINE('Comment Created At: ' || comment.created_at);
    END LOOP;
END;
/

-- Procedure to show create a new post

CREATE OR REPLACE PROCEDURE create_new_post(
    user_id_in IN NUMBER,
    caption_in IN VARCHAR2
)
IS
    post_id NUMBER;
BEGIN
    INSERT INTO post(user_id, caption)
    VALUES(user_id_in, caption_in)
    RETURNING post_id INTO post_id;

    DBMS_OUTPUT.PUT_LINE('Post Created with ID: ' || post_id);
END;
/

--Procedure to show add a video to a post

CREATE OR REPLACE PROCEDURE add_video_to_post(
    post_id_in IN NUMBER,
    video_url_in IN VARCHAR2
)
IS
    video_id NUMBER;
BEGIN
    INSERT INTO videos(video_url, post_id)
    VALUES(video_url_in, post_id_in)
    RETURNING video_id INTO video_id;

    DBMS_OUTPUT.PUT_LINE('Video Added with ID: ' || video_id);
END;
/
--Procedure to show add a photo to a post

CREATE OR REPLACE PROCEDURE add_photo_to_post(
    post_id_in IN NUMBER,
    photo_url_in IN VARCHAR2
)
IS
    photo_id NUMBER;
BEGIN
    INSERT INTO photos(photo_url, post_id)
    VALUES(photo_url_in, post_id_in)
    RETURNING photo_id INTO photo_id;

    DBMS_OUTPUT.PUT_LINE('Photo Added with ID: ' || photo_id);
END;
/
--Procedure to show add a location to a post
CREATE OR REPLACE PROCEDURE add_location_to_post(
    post_id_in IN NUMBER,
    location_in IN VARCHAR2
)
IS
BEGIN
    INSERT INTO location(location_name, post_id)
    VALUES(location_in, post_id_in);

    DBMS_OUTPUT.PUT_LINE('Location Added to Post');
END;
/


-- Procedure to show create a new comment on a post

CREATE OR REPLACE PROCEDURE create_new_comment(
    user_id_in IN NUMBER,
    post_id_in IN NUMBER,
    comment_text_in IN VARCHAR2
)
IS
    comment_id NUMBER;
BEGIN
    INSERT INTO comments(user_id, post_id, comment_text)
    VALUES(user_id_in, post_id_in, comment_text_in)
    RETURNING comment_id INTO comment_id;

    DBMS_OUTPUT.PUT_LINE('Comment Created with ID: ' || comment_id);
END;
/

-- Procedure to show create a new like on a post

CREATE OR REPLACE PROCEDURE like_post(
    user_id_in IN NUMBER,
    post_id_in IN NUMBER
)
IS
    like_id NUMBER;
BEGIN
    INSERT INTO post_likes(user_id, post_id)
    VALUES(user_id_in, post_id_in)
    RETURNING user_id INTO like_id;

    DBMS_OUTPUT.PUT_LINE('Post Liked with ID: ' || like_id);
END;
/

-- Procedure to show delete a like on a post

CREATE OR REPLACE PROCEDURE unlike_post(
    user_id_in IN NUMBER,
    post_id_in IN NUMBER
)
IS
BEGIN
    DELETE FROM post_likes
    WHERE user_id = user_id_in AND post_id = post_id_in;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No like found for the specified user and post.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Like Removed');
    END IF;
END;
/
-- Procedure to show create a new like on a comment

CREATE OR REPLACE PROCEDURE like_comment(
    user_id_in IN NUMBER,
    comment_id_in IN NUMBER
)
IS
    like_id NUMBER;
BEGIN
    INSERT INTO comment_likes(user_id, comment_id)
    VALUES(user_id_in, comment_id_in)
    RETURNING user_id INTO like_id;

    DBMS_OUTPUT.PUT_LINE('Comment Liked with ID: ' || like_id);
END;
/

--Show user what hashtag he can follow

CREATE OR REPLACE PROCEDURE show_hashtags
IS
    hashtag_id NUMBER;
    hashtag_name VARCHAR2(255);
    hashtag_created_at TIMESTAMP;
BEGIN
    FOR hashtag IN (
        SELECT hashtag_id, hashtag_name, created_at
        FROM hashtags
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Hashtag ID: ' || hashtag.hashtag_id);
        DBMS_OUTPUT.PUT_LINE('Hashtag Name: ' || hashtag.hashtag_name);
        DBMS_OUTPUT.PUT_LINE('Hashtag Created At: ' || hashtag.created_at);
    END LOOP;
END;
/

--Prodecure for user to follow a hashtag

CREATE OR REPLACE PROCEDURE follow_hashtag(
    user_id_in IN NUMBER,
    hashtag_id_in IN NUMBER
)
IS
    follow_id NUMBER;
BEGIN
    INSERT INTO hashtag_follow(user_id, hashtag_id)
    VALUES(user_id_in, hashtag_id_in)
    RETURNING user_id INTO follow_id;

    DBMS_OUTPUT.PUT_LINE('Hashtag Followed with ID: ' || follow_id);
END;
/

--Procedure to show user his followed hashtags

CREATE OR REPLACE PROCEDURE show_user_followed_hashtags(
    user_id_in IN NUMBER,
    hashtag_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN hashtag_cursor FOR
        SELECT h.hashtag_id, h.hashtag_name, h.created_at
        FROM hashtags h
        JOIN hashtag_follow hf ON h.hashtag_id = hf.hashtag_id
        WHERE hf.user_id = user_id_in;
END;
/


--Procedure to show user his posts with a specific hashtag
--Not working
CREATE OR REPLACE PROCEDURE show_user_posts_with_hashtag(
    user_id_in IN NUMBER,
    hashtag_id_in IN NUMBER,
    post_cursor OUT SYS_REFCURSOR
)
IS
    post_id NUMBER;
    post_content VARCHAR2(255);
    post_created_at TIMESTAMP;
BEGIN
    OPEN post_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count
        FROM post p
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        JOIN post_tags pt ON p.post_id = pt.post_id
        WHERE pt.hashtag_id = hashtag_id_in AND p.user_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at, ph.photo_url, v.video_url;
END;
/


--Procedure to show user his feed with a specific hashtag
CREATE OR REPLACE PROCEDURE show_user_feed_with_hashtag(
    user_id_in IN NUMBER,
    hashtag_id_in IN NUMBER,
    feed_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN feed_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        JOIN post_tags pt ON p.post_id = pt.post_id
        WHERE pt.hashtag_id = hashtag_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at, ph.photo_url, v.video_url, u.username, u.profile_photo_url;
END;
/

--Procedure to show feed with his followed hashtags

CREATE OR REPLACE PROCEDURE show_user_feed_with_followed_hashtags(
    user_id_in IN NUMBER,
    page_size IN NUMBER DEFAULT 10,
    page_number IN NUMBER DEFAULT 1,
    feed_cursor OUT SYS_REFCURSOR
)
IS
    offset_rows NUMBER;
BEGIN
    offset_rows := (page_number - 1) * page_size;

    OPEN feed_cursor FOR
        SELECT p.post_id, p.user_id, p.caption, p.created_at,
               ph.photo_url, v.video_url, COUNT(pl.post_id) AS like_count,
               u.username, u.profile_photo_url
        FROM post p
        JOIN users u ON p.user_id = u.user_id
        LEFT JOIN photos ph ON p.post_id = ph.post_id
        LEFT JOIN videos v ON p.post_id = v.post_id
        LEFT JOIN post_likes pl ON p.post_id = pl.post_id
        JOIN post_tags pt ON p.post_id = pt.post_id
        JOIN hashtag_follow hf ON pt.hashtag_id = hf.hashtag_id
        WHERE hf.user_id = user_id_in
        GROUP BY p.post_id, p.user_id, p.caption, p.created_at, ph.photo_url, v.video_url, u.username, u.profile_photo_url
        ORDER BY p.created_at DESC
        OFFSET offset_rows ROWS FETCH NEXT page_size ROWS ONLY;
END;
/

--Procedure to follow a user

CREATE OR REPLACE PROCEDURE follow_user(
    follower_id_in IN NUMBER,
    followee_id_in IN NUMBER
)
IS
    follow_id NUMBER;
BEGIN
    INSERT INTO follows(follower_id, followee_id)
    VALUES(follower_id_in, followee_id_in)
    RETURNING follower_id INTO follow_id;

    DBMS_OUTPUT.PUT_LINE('User Followed with ID: ' || follow_id);
END;
/

--Procedure to unfollow a user
CREATE OR REPLACE PROCEDURE unfollow_user(
    follower_id_in IN NUMBER,
    followee_id_in IN NUMBER
)
IS
BEGIN
    DELETE FROM follows
    WHERE follower_id = follower_id_in AND followee_id = followee_id_in;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No follow relationship found for the specified users.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('User Unfollowed');
    END IF;
END;
/

--delete post

CREATE OR REPLACE PROCEDURE delete_post(
    post_id_in IN NUMBER
)
IS
BEGIN
    DELETE FROM post
    WHERE post_id = post_id_in;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No post found with the specified ID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Post Deleted');
    END IF;
END;
/

--delete comment

CREATE OR REPLACE PROCEDURE delete_comment(
    comment_id_in IN NUMBER
)
IS
BEGIN
    DELETE FROM comments
    WHERE comment_id = comment_id_in;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No comment found with the specified ID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Comment Deleted');
    END IF;
END;
/

--delete user

CREATE OR REPLACE PROCEDURE delete_user(
    user_id_in IN NUMBER
)
IS
BEGIN
    DELETE FROM users
    WHERE user_id = user_id_in;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No user found with the specified ID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('User Deleted');
    END IF;
END;
/