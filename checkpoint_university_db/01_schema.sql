-- =====================================================================
-- University Relational Database - Schema Design (DDL)
-- =====================================================================
-- Normalization:
--   1NF: All attributes are atomic (single-valued columns).
--   2NF: All non-key attributes depend on the whole primary key
--        (composite key in Enrollments: each non-key attribute -
--        grade, enrollment_date - depends on BOTH student_id and course_id).
--   3NF: No transitive dependencies. Instructor details are stored only
--        in the Instructors table; Courses references the instructor by
--        instructor_id (foreign key), not by repeating instructor data.
-- =====================================================================

-- Drop existing tables (safe re-run). Order respects foreign keys.
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Instructors;
DROP TABLE IF EXISTS Students;

-- ---------------------------------------------------------------------
-- Students
-- ---------------------------------------------------------------------
CREATE TABLE Students (
    student_id   INT             PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(100)    NOT NULL,
    email        VARCHAR(150)    NOT NULL UNIQUE,
    age          INT             NOT NULL,
    CONSTRAINT chk_student_age   CHECK (age > 17)
);

-- ---------------------------------------------------------------------
-- Instructors
-- ---------------------------------------------------------------------
CREATE TABLE Instructors (
    instructor_id INT            PRIMARY KEY AUTO_INCREMENT,
    name          VARCHAR(100)   NOT NULL,
    department    VARCHAR(100)   NOT NULL
);

-- ---------------------------------------------------------------------
-- Courses
--   - A course is taught by exactly one instructor (1:N Instructor->Courses).
--   - instructor_id is a FK to Instructors.
-- ---------------------------------------------------------------------
CREATE TABLE Courses (
    course_id     INT            PRIMARY KEY AUTO_INCREMENT,
    title         VARCHAR(150)   NOT NULL UNIQUE,
    credits       INT            NOT NULL,
    instructor_id INT            NOT NULL,
    CONSTRAINT chk_course_credits CHECK (credits BETWEEN 1 AND 6),
    CONSTRAINT fk_course_instructor
        FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- Enrollments (junction table for M:N between Students and Courses)
--   - Composite primary key (student_id, course_id) prevents a student
--     from enrolling in the same course twice.
-- ---------------------------------------------------------------------
CREATE TABLE Enrollments (
    student_id      INT          NOT NULL,
    course_id       INT          NOT NULL,
    grade           VARCHAR(2),                       -- nullable until graded
    enrollment_date DATE         NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id)  REFERENCES Courses(course_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT chk_grade
        CHECK (grade IN ('A','B','C','D','E','F') OR grade IS NULL)
);
