-- =====================================================================
-- Sample Data Insertion
-- =====================================================================

-- ---------------------------------------------------------------------
-- Students (4 records)
-- ---------------------------------------------------------------------
INSERT INTO Students (name, email, age) VALUES
('Alice Johnson',  'alice.johnson@univ.edu',  20),
('Bob Smith',      'bob.smith@univ.edu',     22),
('Charlie Brown',  'charlie.brown@univ.edu', 19),
('Diana Prince',   'diana.prince@univ.edu',  21);   -- will remain unenrolled

-- ---------------------------------------------------------------------
-- Instructors (3 records)
-- ---------------------------------------------------------------------
INSERT INTO Instructors (name, department) VALUES
('Dr. Alan Turing',     'Computer Science'),
('Dr. Marie Curie',     'Physics'),
('Dr. Ada Lovelace',    'Mathematics');

-- ---------------------------------------------------------------------
-- Courses (3 records)
-- ---------------------------------------------------------------------
INSERT INTO Courses (title, credits, instructor_id) VALUES
('Database Systems',     4, 1),  -- taught by Dr. Alan Turing
('Quantum Mechanics',    3, 2),  -- taught by Dr. Marie Curie
('Discrete Mathematics', 3, 3);  -- taught by Dr. Ada Lovelace

-- ---------------------------------------------------------------------
-- Enrollments (4 records, covering different students and courses)
-- ---------------------------------------------------------------------
INSERT INTO Enrollments (student_id, course_id, grade) VALUES
(1, 1, 'A'),   -- Alice   -> Database Systems
(2, 1, 'B'),   -- Bob     -> Database Systems
(2, 2, 'A'),   -- Bob     -> Quantum Mechanics
(3, 3, 'C');   -- Charlie -> Discrete Mathematics
-- Diana (student_id = 4) is intentionally left without any enrollment.
