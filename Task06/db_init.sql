-- Лабораторная работа 6. Учёт успеваемости студентов ФМиИТ.
-- Выполнить один раз в пустой базе SQLite.
PRAGMA foreign_keys = ON;
BEGIN;

CREATE TABLE programs (
    program_id INTEGER PRIMARY KEY,
    code TEXT NOT NULL UNIQUE CHECK (length(trim(code)) > 0),
    name TEXT NOT NULL CHECK (length(trim(name)) > 0),
    duration_years INTEGER NOT NULL DEFAULT 4
        CHECK (typeof(duration_years) = 'integer' AND duration_years BETWEEN 1 AND 9)
);

CREATE TABLE student_groups (
    group_id INTEGER PRIMARY KEY,
    program_id INTEGER NOT NULL REFERENCES programs(program_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    admission_year INTEGER NOT NULL
        CHECK (typeof(admission_year) = 'integer' AND admission_year BETWEEN 1900 AND 9999),
    group_suffix INTEGER NOT NULL
        CHECK (typeof(group_suffix) = 'integer' AND group_suffix BETWEEN 1 AND 99),
    UNIQUE (program_id, admission_year, group_suffix),
    UNIQUE (group_id, program_id)
);

CREATE TABLE students (
    student_id INTEGER PRIMARY KEY,
    group_id INTEGER NOT NULL,
    program_id INTEGER NOT NULL,
    last_name TEXT NOT NULL CHECK (length(trim(last_name)) > 0),
    first_name TEXT NOT NULL CHECK (length(trim(first_name)) > 0),
    patronymic TEXT CHECK (patronymic IS NULL OR length(trim(patronymic)) > 0),
    birth_date TEXT NOT NULL CHECK (
        birth_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
        AND birth_date >= '1900-01-01'
        AND date(birth_date, '+0 days') IS NOT NULL
        AND date(birth_date, '+0 days') = birth_date
    ),
    sex TEXT NOT NULL CHECK (sex IN ('М', 'Ж')),
    FOREIGN KEY (group_id, program_id) REFERENCES student_groups(group_id, program_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    UNIQUE (student_id, program_id)
);

CREATE TABLE disciplines (
    discipline_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE CHECK (length(trim(name)) > 0)
);

CREATE TABLE curriculum (
    program_id INTEGER NOT NULL REFERENCES programs(program_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    discipline_id INTEGER NOT NULL REFERENCES disciplines(discipline_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    lecture_hours INTEGER NOT NULL DEFAULT 0
        CHECK (typeof(lecture_hours) = 'integer' AND lecture_hours >= 0),
    practice_hours INTEGER NOT NULL DEFAULT 0
        CHECK (typeof(practice_hours) = 'integer' AND practice_hours >= 0),
    assessment_type TEXT NOT NULL CHECK (assessment_type IN ('exam', 'credit')),
    CHECK (lecture_hours > 0 OR practice_hours > 0),
    PRIMARY KEY (program_id, discipline_id),
    UNIQUE (program_id, discipline_id, assessment_type)
);

-- Одна итоговая запись на студента и дисциплину. Баллы по шкале 0–100.
-- Составные внешние ключи проверяют направление студента и вид аттестации.
CREATE TABLE results (
    student_id INTEGER NOT NULL,
    discipline_id INTEGER NOT NULL,
    program_id INTEGER NOT NULL,
    assessment_type TEXT NOT NULL,
    points INTEGER NOT NULL CHECK (typeof(points) = 'integer' AND points BETWEEN 0 AND 100),
    exam_grade INTEGER,
    credit_passed INTEGER,
    PRIMARY KEY (student_id, discipline_id),
    FOREIGN KEY (student_id, program_id) REFERENCES students(student_id, program_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    FOREIGN KEY (program_id, discipline_id, assessment_type)
        REFERENCES curriculum(program_id, discipline_id, assessment_type)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CHECK (
        (assessment_type = 'exam' AND typeof(exam_grade) = 'integer'
            AND exam_grade BETWEEN 2 AND 5 AND credit_passed IS NULL)
        OR
        (assessment_type = 'credit' AND exam_grade IS NULL
            AND typeof(credit_passed) = 'integer' AND credit_passed IN (0, 1))
    )
);

CREATE INDEX students_by_group ON students(group_id, program_id);
CREATE INDEX curriculum_by_discipline ON curriculum(discipline_id);
CREATE INDEX results_by_curriculum ON results(program_id, discipline_id, assessment_type);

-- Учебный год начинается 1 сентября, время берётся с машины приложения.
-- Номер группы сохраняет двузначный суффикс, курс ограничен сроком обучения.
-- Для исторического отчёта курс вычисляется по году начала нужного учебного года.
CREATE VIEW current_groups AS
WITH academic_year AS (
    SELECT CAST(strftime('%Y', 'now', 'localtime') AS INTEGER)
         - (strftime('%m', 'now', 'localtime') < '09') AS start_year
),
group_courses AS (
    SELECT g.group_id, g.program_id, g.admission_year, g.group_suffix,
           y.start_year AS academic_start_year,
           MIN(y.start_year - g.admission_year + 1, p.duration_years) AS course
    FROM student_groups AS g
    JOIN programs AS p USING (program_id)
    CROSS JOIN academic_year AS y
    WHERE g.admission_year <= y.start_year
)
SELECT group_id, program_id, admission_year, academic_start_year, course,
       course * 100 + group_suffix AS group_number
FROM group_courses;

INSERT INTO programs (program_id, code, name) VALUES
    (1, '01.03.02', 'Прикладная математика и информатика'),
    (2, '02.03.03', 'Математическое обеспечение и администрирование информационных систем');

INSERT INTO student_groups (group_id, program_id, admission_year, group_suffix) VALUES
    (1, 1, 2018, 3),
    (2, 1, 2024, 1),
    (3, 2, 2024, 2);

-- Фамилии взяты из предоставленного списка; остальные анкетные данные
-- и результаты аттестации используются как тестовые.
INSERT INTO students
    (student_id, group_id, program_id, last_name, first_name, patronymic, birth_date, sex)
VALUES
    (1, 1, 1, 'Арискин', 'Артём', 'Ильич', '2000-03-14', 'М'),
    (2, 1, 1, 'Байол', 'Мария', 'Денисовна', '2000-06-20', 'Ж'),
    (3, 1, 1, 'Башмаков', 'Иван', 'Олегович', '2000-01-12', 'М'),
    (4, 1, 1, 'Берман', 'Антон', 'Павлович', '2000-02-29', 'М'),
    (5, 2, 1, 'Вельдяскин', 'Лев', 'Андреевич', '2006-04-16', 'М'),
    (6, 2, 1, 'Кочкарова', 'Софья', NULL, '2006-05-21', 'Ж'),
    (7, 3, 2, 'Петров', 'Максим', 'Сергеевич', '2006-08-09', 'М'),
    (8, 3, 2, 'Сидорова', 'Дарья', 'Алексеевна', '2006-02-11', 'Ж'),
    (9, 2, 1, 'Воронин', 'Андрей', 'Иванович', '2006-03-04', 'М'),
    (10, 2, 1, 'Денисов', 'Никита', 'Антонович', '2006-06-19', 'М'),
    (11, 2, 1, 'Ефимкин', 'Роман', 'Игоревич', '2006-07-08', 'М'),
    (12, 2, 1, 'Зюзин', 'Павел', 'Михайлович', '2005-11-23', 'М'),
    (13, 2, 1, 'Игушкин', 'Фёдор', 'Денисович', '2006-02-18', 'М'),
    (14, 2, 1, 'Кряжев', 'Матвей', 'Артёмович', '2006-01-27', 'М'),
    (15, 2, 1, 'Ксенофонтов', 'Даниил', 'Владимирович', '2005-12-10', 'М');

INSERT INTO disciplines VALUES
    (1, 'Математический анализ'),
    (2, 'Программирование'),
    (3, 'Базы данных'),
    (4, 'Информационные системы');

INSERT INTO curriculum VALUES
    (1, 1, 48, 48, 'exam'),
    (1, 2, 32, 48, 'exam'),
    (1, 3, 16, 32, 'credit'),
    (2, 2, 48, 48, 'exam'),
    (2, 3, 32, 48, 'exam'),
    (2, 4, 16, 32, 'credit');

INSERT INTO results VALUES
    (1, 1, 1, 'exam',   35, 2, NULL),
    (1, 2, 1, 'exam',   71, 4, NULL),
    (1, 3, 1, 'credit', 45, NULL, 0),
    (2, 1, 1, 'exam',   61, 3, NULL),
    (2, 2, 1, 'exam',   81, 4, NULL),
    (2, 3, 1, 'credit', 73, NULL, 1),
    (3, 1, 1, 'exam',   79, 4, NULL),
    (3, 2, 1, 'exam',   91, 5, NULL),
    (3, 3, 1, 'credit', 84, NULL, 1),
    (4, 1, 1, 'exam',   98, 5, NULL),
    (4, 2, 1, 'exam',   97, 5, NULL),
    (4, 3, 1, 'credit', 94, NULL, 1),
    (5, 1, 1, 'exam',   98, 5, NULL),
    (5, 2, 1, 'exam',   86, 4, NULL),
    (5, 3, 1, 'credit', 70, NULL, 1),
    (6, 1, 1, 'exam',   93, 5, NULL),
    (7, 2, 2, 'exam',   77, 4, NULL),
    (7, 3, 2, 'exam',   92, 5, NULL),
    (7, 4, 2, 'credit', 83, NULL, 1),
    (8, 2, 2, 'exam',   68, 3, NULL),
    (8, 3, 2, 'exam',   74, 4, NULL),
    (8, 4, 2, 'credit', 65, NULL, 1);

COMMIT;
