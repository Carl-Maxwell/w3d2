
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255)
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY NOT NULL,
  title VARCHAR(255),
  body TEXT,
  author_id INTEGER REFERENCES users
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users,
  question_id INTEGER NOT NULL REFERENCES questions
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY NOT NULL,
  author_id INTEGER NOT NULL REFERENCES users,
  question_id INTEGER NOT NULL REFERENCES questions,
  parent_reply_id INTEGER REFERENCES replies,
  body TEXT
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users,
  question_id INTEGER NOT NULL REFERENCES questions
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Albert', 'Einstein'),
  ('Kurt', 'Godel'),
  ('Adam', 'Smith');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('SQL', 'How do you make tables?', (SELECT id FROM users WHERE fname = 'Albert' AND lname = 'Einstein')),
  ('Ruby', 'How do you create a class?', (SELECT id FROM users WHERE fname = 'Adam' AND lname = 'Smith')),
  ('Ruby', 'How do you create an object?', (SELECT id FROM users WHERE fname = 'Adam' AND lname = 'Smith'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Albert' AND lname = 'Einstein'), (SELECT id FROM questions WHERE title = 'SQL')),
  ((SELECT id FROM users WHERE fname = 'Kurt' AND lname = 'Godel'), (SELECT id FROM questions WHERE title = 'Ruby')),
  ((SELECT id FROM users WHERE fname = 'Adam' AND lname = 'Smith'), (SELECT id FROM questions WHERE title = 'Ruby'));

INSERT INTO
  replies (author_id, question_id, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Kurt' AND lname = 'Godel'), (SELECT id FROM questions WHERE title = 'SQL'), 'You use CREATE TABLE'),
  ((SELECT id FROM users WHERE fname = 'Kurt' AND lname = 'Godel'), (SELECT id FROM questions WHERE title = 'Ruby'), 'You type class Class_name');

INSERT INTO
  replies (author_id, question_id, parent_reply_id, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Albert' AND lname = 'Einstein'), (SELECT id FROM questions WHERE title = 'SQL'), (SELECT id FROM replies WHERE body = 'You use CREATE TABLE'), 'Thank you'),
  ((SELECT id FROM users WHERE fname = 'Adam' AND lname = 'Smith'), (SELECT id FROM questions WHERE title = 'Ruby'), (SELECT id FROM replies WHERE body = 'You type class Class_name'), 'THANK YOU!');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Albert' AND lname = 'Einstein'), (SELECT id FROM questions WHERE title = 'SQL')),
  ((SELECT id FROM users WHERE fname = 'Kurt' AND lname = 'Godel'), (SELECT id FROM questions WHERE title = 'SQL')),
  ((SELECT id FROM users WHERE fname = 'Adam' AND lname = 'Smith'), (SELECT id FROM questions WHERE title = 'Ruby'));
