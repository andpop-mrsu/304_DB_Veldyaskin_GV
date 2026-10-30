.mode csv
.separator ","

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (userId INTEGER, movieId INTEGER, rating REAL, timestamp INTEGER);
.import --skip 1 ratings.csv ratings

DROP TABLE IF EXISTS movies;
CREATE TABLE movies (movieId INTEGER, title TEXT, genres TEXT);
.import --skip 1 movies.csv movies

.mode list
.separator "|"

DROP TABLE IF EXISTS users;
CREATE TABLE users (userId INTEGER, name TEXT, email TEXT, gender TEXT, reg_date TEXT, occupation TEXT);
.import --skip 1 users.txt users