# Лабораторная работа 2. ETL-процесс для SQLite

## Требования к окружению
Для корректной работы скрипта `db_init.bat` на компьютере должны быть установлены:
1. **Python 3.x** (должен быть доступен по команде `python3` в терминале)
2. **SQLite3** (утилита командной строки `sqlite3` должна быть установлена в системе)

## Структура файлов
- `dataset/` — каталог с исходными CSV-файлами:
  - `movies.csv` (movieId, title, genres)
  - `ratings.csv` (userId, movieId, rating, timestamp)
  - `tags.csv` (userId, movieId, tag, timestamp)
- `make_db_init.py` — кроссплатформенная утилита на Python, читающая CSV и генерирующая SQL-скрипт
- `db_init.sql` — генерируемый файл с командами `DROP`, `CREATE TABLE` и `INSERT INTO`
- `db_init.bat` — кроссплатформенный скрипт для автоматического запуска генерации и инициализации БД
- `movies_rating.db` — итоговый файл базы данных SQLite

## Структура таблиц в БД
- `users`: id (INTEGER PRIMARY KEY), name, email, gender, register_date, occupation
- `movies`: id (INTEGER PRIMARY KEY), title, year (извлекается из title), genres
- `ratings`: id (INTEGER PRIMARY KEY AUTOINCREMENT), user_id, movie_id, rating, timestamp
- `tags`: id (INTEGER PRIMARY KEY AUTOINCREMENT), user_id, movie_id, tag, timestamp

## Запуск
Выполните в терминале (Linux/macOS/WSL):
```bash
./db_init.bat