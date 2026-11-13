-- Включаем поддержку внешних ключей
PRAGMA foreign_keys = ON;

-- 1. Добавляем 5 новых пользователей (я + 4 соседа)
-- Дата регистрации определяется системным временем через date('now')
INSERT INTO users (name, email, gender, reg_date, occupation) VALUES
('Вельдяскин Г.В.', 'veldyaskin@student.mrsu.ru', 'male', date('now'), 'student'),
(' Воронин А.С.', 'ivanov@student.mrsu.ru', 'male', date('now'), 'student'),
('Денисов М.С.', 'petrova@student.mrsu.ru', 'female', date('now'), 'student'),
('Ефимкин К.Д.', 'sidorov@student.mrsu.ru', 'male', date('now'), 'student'),
('Зюзин В.В.', 'smirnova@student.mrsu.ru', 'female', date('now'), 'student');

-- 2. Добавляем 3 новых фильма разных жанров
INSERT INTO movies (title, release_year, genres) VALUES
('Дюна: Часть вторая (Dune: Part Two)', 2024, 'Action|Adventure|Sci-Fi'),
('Оппенгеймер (Oppenheimer)', 2023, 'Biography|Drama|History'),
('Человек-паук: Паутина вселенных (Spider-Man: Across the Spider-Verse)', 2023, 'Animation|Action|Adventure');

-- 3. Добавляем 3 отзыва от "Вельдяскин Г.В." на эти новые фильмы
-- Мы НЕ указываем ID вручную! Мы динамически находим их через подзапросы.
-- strftime('%s', 'now') получает текущий timestamp UNIX.

INSERT INTO ratings (userId, movieId, rating, timestamp)
SELECT 
    (SELECT userId FROM users WHERE name = 'Вельдяскин Г.В.'),
    (SELECT movieId FROM movies WHERE title = 'Дюна: Часть вторая (Dune: Part Two)'),
    5.0,
    strftime('%s', 'now');

INSERT INTO ratings (userId, movieId, rating, timestamp)
SELECT 
    (SELECT userId FROM users WHERE name = 'Вельдяяскин Г.В.'),
    (SELECT movieId FROM movies WHERE title = 'Оппенгеймер (Oppenheimer)'),
    4.5,
    strftime('%s', 'now');

INSERT INTO ratings (userId, movieId, rating, timestamp)
SELECT 
    (SELECT userId FROM users WHERE name = 'Вельдяскин Г.В.'),
    (SELECT movieId FROM movies WHERE title = 'Человек-паук: Паутина вселенных (Spider-Man: Across the Spider-Verse)'),
    5.0,
    strftime('%s', 'now');