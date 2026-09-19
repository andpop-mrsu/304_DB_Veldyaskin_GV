import csv
import os
import re

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATASET_DIR = os.path.join(BASE_DIR, 'dataset')
SQL_FILE = os.path.join(BASE_DIR, 'db_init.sql')

def escape_sql(val):
    """Экранирование значений для безопасной вставки в SQL"""
    if val is None or str(val).strip() == '':
        return 'NULL'
    return "'" + str(val).replace("'", "''") + "'"

def extract_year(title):
    """Извлекает год из строки вида 'Название (1995)'"""
    match = re.search(r'\((\d{4})\)\s*$', str(title).strip())
    if match:
        return match.group(1)
    return 'NULL'

def main():
    with open(SQL_FILE, 'w', encoding='utf-8') as out:
        out.write("PRAGMA journal_mode = MEMORY;\n")
        out.write("PRAGMA synchronous = OFF;\n")
        out.write("PRAGMA foreign_keys = OFF;\n\n")

        out.write("DROP TABLE IF EXISTS users;\n")
        out.write("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT, gender TEXT, register_date TEXT, occupation TEXT);\n\n")

        out.write("DROP TABLE IF EXISTS movies;\n")
        out.write("CREATE TABLE movies (id INTEGER PRIMARY KEY, title TEXT, year INTEGER, genres TEXT);\n\n")

        out.write("DROP TABLE IF EXISTS ratings;\n")
        out.write("CREATE TABLE ratings (id INTEGER PRIMARY KEY, user_id INTEGER, movie_id INTEGER, rating REAL, timestamp INTEGER);\n\n")

        out.write("DROP TABLE IF EXISTS tags;\n")
        out.write("CREATE TABLE tags (id INTEGER PRIMARY KEY, user_id INTEGER, movie_id INTEGER, tag TEXT, timestamp INTEGER);\n\n")


        users_file = os.path.join(DATASET_DIR, 'users.csv')
        if not os.path.exists(users_file):
            users_file = os.path.join(DATASET_DIR, 'users.txt')
            
        if os.path.exists(users_file):
            out.write("BEGIN TRANSACTION;\n")
            with open(users_file, 'r', encoding='utf-8') as f:
                sample = f.read(1024)
                f.seek(0)
                delimiter = ';' if ';' in sample else (',' if ',' in sample else '|')
                reader = csv.DictReader(f, delimiter=delimiter)
                for row in reader:
                    uid = row.get('id') or row.get('userId') or row.get('user_id')
                    out.write(f"INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES "
                              f"({escape_sql(uid)}, {escape_sql(row.get('name', ''))}, {escape_sql(row.get('email', ''))}, "
                              f"{escape_sql(row.get('gender', ''))}, {escape_sql(row.get('register_date', ''))}, {escape_sql(row.get('occupation', ''))});\n")
            out.write("COMMIT;\n\n")

        movies_file = os.path.join(DATASET_DIR, 'movies.csv')
        if not os.path.exists(movies_file):
            movies_file = os.path.join(DATASET_DIR, 'movies.txt')
            
        if os.path.exists(movies_file):
            out.write("BEGIN TRANSACTION;\n")
            with open(movies_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    mid = row.get('movieId') or row.get('id') or row.get('movie_id')
                    title = row.get('title', '')
                    genres = row.get('genres', '')
                    year = extract_year(title)
                    out.write(f"INSERT INTO movies (id, title, year, genres) VALUES "
                              f"({escape_sql(mid)}, {escape_sql(title)}, {year}, {escape_sql(genres)});\n")
            out.write("COMMIT;\n\n")

        ratings_file = os.path.join(DATASET_DIR, 'ratings.csv')
        if not os.path.exists(ratings_file):
            ratings_file = os.path.join(DATASET_DIR, 'ratings.txt')
            
        if os.path.exists(ratings_file):
            out.write("BEGIN TRANSACTION;\n")
            with open(ratings_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    uid = row.get('userId') or row.get('user_id')
                    mid = row.get('movieId') or row.get('movie_id')
                    out.write(f"INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES "
                              f"({escape_sql(uid)}, {escape_sql(mid)}, {escape_sql(row.get('rating', ''))}, {escape_sql(row.get('timestamp', ''))});\n")
            out.write("COMMIT;\n\n")

        tags_file = os.path.join(DATASET_DIR, 'tags.csv')
        if not os.path.exists(tags_file):
            tags_file = os.path.join(DATASET_DIR, 'tags.txt')
            
        if os.path.exists(tags_file):
            out.write("BEGIN TRANSACTION;\n")
            with open(tags_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    uid = row.get('userId') or row.get('user_id')
                    mid = row.get('movieId') or row.get('movie_id')
                    out.write(f"INSERT INTO tags (user_id, movie_id, tag, timestamp) VALUES "
                              f"({escape_sql(uid)}, {escape_sql(mid)}, {escape_sql(row.get('tag', ''))}, {escape_sql(row.get('timestamp', ''))});\n")
            out.write("COMMIT;\n\n")

        print(f" Скрипт {SQL_FILE} успешно сгенерирован!")

if __name__ == '__main__':
    main()