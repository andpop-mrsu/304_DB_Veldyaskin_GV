-- Включаем поддержку внешних ключей в SQLite
PRAGMA foreign_keys = ON;

.mode csv

-- ==========================================
-- 1. Таблица пользователей (users)
-- ==========================================
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    userId INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL, -- Нельзя двух пользователей с одинаковым e-mail
    gender TEXT CHECK(gender IN ('male', 'female')) NOT NULL, -- Только мужской или женский
    reg_date TEXT DEFAULT (date('now')), -- Значение по умолчанию
    occupation TEXT
);

-- users.txt имеет разделитель "|", меняем его перед импортом
.separator "|"
.import --skip 1 users.txt users

-- ==========================================
-- 2. Таблица фильмов (movies)
-- ==========================================
.separator ","
DROP TABLE IF EXISTS movies;
CREATE TABLE movies (
    movieId INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    genres TEXT,
    release_year INTEGER -- Выделено для индексации и логической целостности
);

.import --skip 1 movies.csv movies

-- Извлекаем год выпуска из названия (например, "Toy Story (1995)" -> 1995)
-- Это выполняется мгновенно и обеспечивает корректную 3НФ
UPDATE movies SET release_year = CAST(substr(title, -5, 4) AS INTEGER) WHERE title LIKE '%(____)';

-- ==========================================
-- 3. Таблица оценок (ratings)
-- ==========================================
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
    userId INTEGER,
    movieId INTEGER,
    rating REAL CHECK(rating >= 0 AND rating <= 5), -- Рейтинг от 0 до 5 включительно
    timestamp INTEGER,
    PRIMARY KEY (userId, movieId),
    -- При удалении пользователя его отзывы удаляются автоматически (CASCADE)
    FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE,
    -- Нельзя удалить фильм, если по нему есть отзывы (RESTRICT)
    FOREIGN KEY (movieId) REFERENCES movies(movieId) ON DELETE RESTRICT
);

.import --skip 1 ratings.csv ratings

-- ==========================================
-- 4. Индексы для ускорения поиска
-- ==========================================
CREATE INDEX idx_users_name ON users(name);
CREATE INDEX idx_movies_title ON movies(title);
CREATE INDEX idx_movies_year ON movies(release_year);