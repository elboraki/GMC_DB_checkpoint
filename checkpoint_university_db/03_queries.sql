-- =====================================================================
-- Required Queries
-- =====================================================================

-- ---------------------------------------------------------------------
-- Query 1: Retrieve all students enrolled in the course "Database Systems".
-- ---------------------------------------------------------------------
SELECT  s.student_id,
        s.name,
        s.email,
        s.age
FROM    Students   s
JOIN    Enrollments e ON e.student_id = s.student_id
JOIN    Courses    c ON c.course_id   = e.course_id
WHERE   c.title = 'Database Systems';

-- ---------------------------------------------------------------------
-- Query 2: List all courses along with the names of their instructors.
-- ---------------------------------------------------------------------
SELECT  c.course_id,
        c.title          AS course_title,
        c.credits,
        i.name           AS instructor_name,
        i.department
FROM    Courses     c
JOIN    Instructors i ON i.instructor_id = c.instructor_id
ORDER BY c.course_id;

-- ---------------------------------------------------------------------
-- Query 3: Find students who are not enrolled in any course.
-- ---------------------------------------------------------------------
SELECT  s.student_id,
        s.name,
        s.email
FROM    Students s
LEFT JOIN Enrollments e ON e.student_id = s.student_id
WHERE   e.student_id IS NULL;

-- ---------------------------------------------------------------------
-- Query 4: Update the email address of a student.
--   Example: update Alice Johnson's email.
-- ---------------------------------------------------------------------
UPDATE Students
SET    email = 'alice.j@newmail.edu'
WHERE  student_id = 1;

-- Verify the update:
SELECT student_id, name, email FROM Students WHERE student_id = 1;

-- ---------------------------------------------------------------------
-- Query 5: Delete a course by its ID.
--   Example: remove the course with course_id = 3 (Discrete Mathematics).
--   Related Enrollments rows are removed automatically (ON DELETE CASCADE).
-- ---------------------------------------------------------------------
DELETE FROM Courses
WHERE  course_id = 3;

-- Verify the deletion:
SELECT * FROM Courses;
