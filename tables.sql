CREATE TABLE users 
(
    user_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    username VARCHAR2(255) UNIQUE NOT NULL,
    profile_photo_url VARCHAR2(255) DEFAULT 'https://picsum.photos/100',
    bio VARCHAR2(255),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
     email VARCHAR(50) NOT NULL
);


  CREATE TABLE post (
	post_id NUMBER  PRIMARY KEY,
    user_id NUMBER NOT NULL,
    caption VARCHAR(200), 
    user_location VARCHAR(50),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id),
);


CREATE TABLE photos (
    photo_id NUMBER PRIMARY KEY,
    photo_url VARCHAR2(255) NOT NULL,
    post_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    photo_size NUMBER(5, 2) CHECK (photo_size < 5),
    FOREIGN KEY(post_id) REFERENCES post(post_id)
);


CREATE TABLE videos (
  video_id NUMBER PRIMARY KEY,
  video_url VARCHAR(255) NOT NULL,
  post_id NUMBER NOT NULL,
   created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
  video_size NUMBER(5,2) CHECK (video_size<10)
  FOREIGN KEY(post_id) REFERENCES post(post_id)

);


CREATE TABLE comments (
    comment_id NUMBER  PRIMARY KEY,
    comment_text VARCHAR(255) NOT NULL,
    post_id NUMBER NOT NULL,
    user_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY(post_id) REFERENCES post(post_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);


CREATE TABLE post_likes (
    user_id NUMBER NOT NULL,
    post_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id),
    PRIMARY KEY(user_id, post_id)
);

CREATE TABLE comment_likes (
    user_id NUMBER NOT NULL,
    comment_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(comment_id) REFERENCES comments(comment_id),
    PRIMARY KEY(user_id, comment_id)
);

CREATE TABLE follows (
    follower_id NUMBER NOT NULL,
    followee_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY(follower_id) REFERENCES users(user_id),
    FOREIGN KEY(followee_id) REFERENCES users(user_id),
    PRIMARY KEY(follower_id, followee_id)
);


CREATE TABLE hashtags (
    hashtag_id  NUMBER PRIMARY KEY,
    hashtag_name VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE hastag_follow (
    user_id NUMBER NOT NULL,
    hashtag_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(hashtag_id) REFERENCES hashtags(hashtag_id),
    PRIMARY KEY(user_id, hashtag_id)
);

CREATE TABLE post_tags (
    post_id NUMBER NOT NULL,
    hashtag_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY(post_id) REFERENCES post(post_id),
    FOREIGN KEY(hashtag_id) REFERENCES hashtags(hashtag_id),
    PRIMARY KEY(post_id, hashtag_id)
);

CREATE TABLE login (
    login_id NUMBER  PRIMARY KEY,
    user_id NUMBER NOT NULL,
    ip VARCHAR2(50) NOT NULL,
    password VARCHAR2(255) NOT NULL,
    login_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);



