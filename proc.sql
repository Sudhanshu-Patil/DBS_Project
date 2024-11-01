--Create a new login entries

CREATE OR REPLACE PROCEDURE create_new_login(
    email_in IN VARCHAR(255),
    password_in IN VARCHAR(255),
    login_id_out OUT NUMBER
)
IS
    user_id_int NUMBER;
BEGIN
    SELECT user_id INTO user_id_int
    FROM users
    WHERE email = email_in AND password = password_in;

    INSERT INTO login(user_id)
    VALUES(user_id_int)
    RETURNING login_id INTO login_id_out;

END;



--Create a new user

CREATE OR REPLACE PROCEDURE create_new_user(
    name_in IN VARCHAR(255),
    email_in IN VARCHAR(255),
    bio_in IN VARCHAR(255),
    password_in IN VARCHAR(255),
    user_id_out OUT NUMBER,
    login_id_out OUT NUMBER
)
IS
    user_id NUMBER;
    login_id NUMBER;
BEGIN
    INSERT INTO users(name, email, bio)
    VALUES(name_in, email_in, bio_in)
    RETURNING user_id INTO user_id;
    REFERENCES users(user_id)

    INSERT INTO login(user_id)
    VALUES(user_id)
    RETURNING login_id INTO login_id;


    DBMS_OUTPUT.PUT_LINE('User Created with ID: ' || user_id);
    user_id_out := user_id;
    login_id_out := login_id;
END;

-- Procedure to show user his details

CREATE OR REPLACE PROCEDURE show_user_details(
    user_id_in IN NUMBER
)
IS
    user_name VARCHAR(255);
    user_email VARCHAR(255);
    user_bio VARCHAR(255);
    user_created_at TIMESTAMP;
BEGIN
    SELECT name, email, bio, created_at
    INTO user_name, user_email, user_bio, user_created_at
    FROM users
    WHERE user_id = user_id_in;

    DBMS_OUTPUT.PUT_LINE('User Name: ' || user_name);
    DBMS_OUTPUT.PUT_LINE('User Email: ' || user_email);
    DBMS_OUTPUT.PUT_LINE('User Bio: ' || user_bio);
    DBMS_OUTPUT.PUT_LINE('User Created At: ' || user_created_at);
END;

-- Procedure for user to update his details

CREATE OR REPLACE PROCEDURE update_user_details(
    user_id_in IN NUMBER,
    name_in IN VARCHAR(255),
    email_in IN VARCHAR(255),
    bio_in IN VARCHAR(255)
)
IS
BEGIN
    UPDATE users
    SET name = name_in, email = email_in, bio = bio_in
    WHERE user_id = user_id_in;

    DBMS_OUTPUT.PUT_LINE('User Details Updated');
END;


-- Procedure to update his password

CREATE OR REPLACE PROCEDURE update_user_password(
    user_id_in IN NUMBER,
    password_in IN VARCHAR(255)
)
IS
BEGIN
    UPDATE users
    SET password = password_in
    WHERE user_id = user_id_in;

    DBMS_OUTPUT.PUT_LINE('Password Updated');
END;

-- Procedure to show user his posts

CREATE OR REPLACE PROCEDURE show_user_posts(
    user_id_in IN NUMBER
)
IS
    post_id NUMBER;
    post_content VARCHAR(255);
    post_created_at TIMESTAMP;
BEGIN
    FOR post IN (
        SELECT post_id, content, created_at
        FROM post
        WHERE user_id = user_id_in
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Post ID: ' || post.post_id);
        DBMS_OUTPUT.PUT_LINE('Post Content: ' || post.content);
        DBMS_OUTPUT.PUT_LINE('Post Created At: ' || post.created_at);
    END LOOP;
END;


-- Procedure to show user his comments on a specific post

CREATE OR REPLACE PROCEDURE show_user_comments_on_post(
    user_id_in IN NUMBER,
    post_id_in IN NUMBER
)
IS
    comment_id NUMBER;
    comment_content VARCHAR(255);
    comment_created_at TIMESTAMP;
BEGIN
    FOR comment IN (
        SELECT comment_id, content, created_at
        FROM comments
        WHERE user_id = user_id_in AND post_id = post_id_in
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Comment ID: ' || comment.comment_id);
        DBMS_OUTPUT.PUT_LINE('Comment Content: ' || comment.content);
        DBMS_OUTPUT.PUT_LINE('Comment Created At: ' || comment.created_at);
    END LOOP;
END;

-- Procedure to show user his followers

CREATE OR REPLACE PROCEDURE show_user_followers(
    user_id_in IN NUMBER
)
IS
    follower_id NUMBER;
    follower_name VARCHAR(255);
    follower_email VARCHAR(255);
    follower_created_at TIMESTAMP;
BEGIN
    FOR follower IN (
        SELECT follower_id, name, email, created_at
        FROM users
        WHERE user_id IN (
            SELECT follower_id
            FROM follows
            WHERE followee_id = user_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Follower ID: ' || follower.follower_id);
        DBMS_OUTPUT.PUT_LINE('Follower Name: ' || follower.name);
        DBMS_OUTPUT.PUT_LINE('Follower Email: ' || follower.email);
        DBMS_OUTPUT.PUT_LINE('Follower Created At: ' || follower.created_at);
    END LOOP;
END;

-- Procedure to show user his feed based on the people he follows

CREATE OR REPLACE PROCEDURE show_user_feed(
    user_id_in IN NUMBER
)
IS
    post_id NUMBER;
    post_content VARCHAR(255);
    post_created_at TIMESTAMP;
BEGIN
    FOR post IN (
        SELECT post_id, content, created_at
        FROM post
        WHERE user_id IN (
            SELECT followee_id
            FROM follows
            WHERE follower_id = user_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Post ID: ' || post.post_id);
        DBMS_OUTPUT.PUT_LINE('Post Content: ' || post.content);
        DBMS_OUTPUT.PUT_LINE('Post Created At: ' || post.created_at);
    END LOOP;
END;

-- Procedure to show user his liked posts

CREATE OR REPLACE PROCEDURE show_user_liked_posts(
    user_id_in IN NUMBER
)
IS
    post_id NUMBER;
    post_content VARCHAR(255);
    post_created_at TIMESTAMP;
BEGIN
    FOR post IN (
        SELECT post_id, content, created_at
        FROM post
        WHERE post_id IN (
            SELECT post_id
            FROM post_likes
            WHERE user_id = user_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Post ID: ' || post.post_id);
        DBMS_OUTPUT.PUT_LINE('Post Content: ' || post.content);
        DBMS_OUTPUT.PUT_LINE('Post Created At: ' || post.created_at);
    END LOOP;
END;

-- Procedure to show user his liked comments

CREATE OR REPLACE PROCEDURE show_user_liked_comments(
    user_id_in IN NUMBER
)
IS
    comment_id NUMBER;
    comment_content VARCHAR(255);
    comment_created_at TIMESTAMP;
BEGIN
    FOR comment IN (
        SELECT comment_id, content, created_at
        FROM comments
        WHERE comment_id IN (
            SELECT comment_id
            FROM comment_likes
            WHERE user_id = user_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Comment ID: ' || comment.comment_id);
        DBMS_OUTPUT.PUT_LINE('Comment Content: ' || comment.content);
        DBMS_OUTPUT.PUT_LINE('Comment Created At: ' || comment.created_at);
    END LOOP;
END;

-- Procedure to show create a new post

CREATE OR REPLACE PROCEDURE create_new_post(
    user_id_in IN NUMBER,
    content_in IN VARCHAR(255)
)
IS
    post_id NUMBER;
BEGIN
    INSERT INTO post(user_id, content)
    VALUES(user_id_in, content_in)
    RETURNING post_id INTO post_id;

    DBMS_OUTPUT.PUT_LINE('Post Created with ID: ' || post_id);
END;

-- Procedure to show create a new comment on a post

CREATE OR REPLACE PROCEDURE create_new_comment(
    user_id_in IN NUMBER,
    post_id_in IN NUMBER,
    content_in IN VARCHAR(255)
)
IS
    comment_id NUMBER;
BEGIN
    INSERT INTO comments(user_id, post_id, content)
    VALUES(user_id_in, post_id_in, content_in)
    RETURNING comment_id INTO comment_id;

    DBMS_OUTPUT.PUT_LINE('Comment Created with ID: ' || comment_id);
END;

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

--Show user what hashtag he can follow

CREATE OR REPLACE PROCEDURE show_hashtags()
IS
    hashtag_id NUMBER;
    hashtag_name VARCHAR(255);
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

--Prodecure for user to follow a hashtag

CREATE OR REPLACE PROCEDURE follow_hashtag(
    user_id_in IN NUMBER,
    hashtag_id_in IN NUMBER
)
IS
    follow_id NUMBER;
BEGIN
    INSERT INTO hastag_follow(user_id, hashtag_id)
    VALUES(user_id_in, hashtag_id_in)
    RETURNING user_id INTO follow_id;

    DBMS_OUTPUT.PUT_LINE('Hashtag Followed with ID: ' || follow_id);
END;

--Procedure to show user his followed hashtags

CREATE OR REPLACE PROCEDURE show_user_followed_hashtags(
    user_id_in IN NUMBER
)
IS
    hashtag_id NUMBER;
    hashtag_name VARCHAR(255);
    hashtag_created_at TIMESTAMP;
BEGIN
    FOR hashtag IN (
        SELECT hashtag_id, hashtag_name, created_at
        FROM hashtags
        WHERE hashtag_id IN (
            SELECT hashtag_id
            FROM hastag_follow
            WHERE user_id = user_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Hashtag ID: ' || hashtag.hashtag_id);
        DBMS_OUTPUT.PUT_LINE('Hashtag Name: ' || hashtag.hashtag_name);
        DBMS_OUTPUT.PUT_LINE('Hashtag Created At: ' || hashtag.created_at);
    END LOOP;
END;

--Procedure to show user his posts with a specific hashtag

CREATE OR REPLACE PROCEDURE show_user_posts_with_hashtag(
    user_id_in IN NUMBER,
    hashtag_id_in IN NUMBER
)
IS
    post_id NUMBER;
    post_content VARCHAR(255);
    post_created_at TIMESTAMP;
BEGIN
    FOR post IN (
        SELECT post_id, content, created_at
        FROM post
        WHERE post_id IN (
            SELECT post_id
            FROM post_tags
            WHERE hashtag_id = hashtag_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Post ID: ' || post.post_id);
        DBMS_OUTPUT.PUT_LINE('Post Content: ' || post.content);
        DBMS_OUTPUT.PUT_LINE('Post Created At: ' || post.created_at);
    END LOOP;
END;

--Procedure to show user his feed with a specific hashtag

CREATE OR REPLACE PROCEDURE show_user_feed_with_hashtag(
    user_id_in IN NUMBER,
    hashtag_id_in IN NUMBER
)
IS
    post_id NUMBER;
    post_content VARCHAR(255);
    post_created_at TIMESTAMP;
BEGIN
    FOR post IN (
        SELECT post_id, content, created_at
        FROM post
        WHERE user_id IN (
            SELECT followee_id
            FROM follows
            WHERE follower_id = user_id_in
        )
        AND post_id IN (
            SELECT post_id
            FROM post_tags
            WHERE hashtag_id = hashtag_id_in
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Post ID: ' || post.post_id);
        DBMS_OUTPUT.PUT_LINE('Post Content: ' || post.content);
        DBMS_OUTPUT.PUT_LINE('Post Created At: ' || post.created_at);
    END LOOP;
END;

--Procedure to show feed with his followed hashtags

CREATE OR REPLACE PROCEDURE show_user_feed_with_followed_hashtags(
    user_id_in IN NUMBER
)
IS
    post_id NUMBER;
    post_content VARCHAR(255);
    post_created_at TIMESTAMP;
BEGIN
    FOR post IN (
        SELECT post_id, content, created_at
        FROM post
        WHERE post_id IN (
            SELECT post_id
            FROM post_tags
            WHERE hashtag_id IN (
                SELECT hashtag_id
                FROM hastag_follow
                WHERE user_id = user_id_in
            )
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Post ID: ' || post.post_id);
        DBMS_OUTPUT.PUT_LINE('Post Content: ' || post.content);
        DBMS_OUTPUT.PUT_LINE('Post Created At: ' || post.created_at);
    END LOOP;
END;





