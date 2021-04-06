-- Create stored procedure that calculate a bonus for employees --
USE employees; 
drop procedure if exists employee_bonus;
delimiter $$

CREATE PROCEDURE employee_bonus(
	IN employees_number int, 
	OUT employees_bonus int 
)
BEGIN 
	DECLARE employees_title varchar(50);
	DECLARE employee_salary int;

SELECT s.salary-- e.emp_no, e.first_name, e.last_name, t.title, s.salary 
INTO employee_salary
FROM salaries s
-- INNER JOIN employees e ON e.emp_no = s.emp_no 
-- INNER JOIN titles t ON t.emp_no = s.emp_no 
WHERE s.emp_no = employees_number;

SELECT t.title
INTO employees_title
FROM titles t
WHERE t.emp_no = employees_number;

IF employees_title LIKE 'Senior%' THEN
	SET  employees_bonus = employee_salary * 0.15;
ELSE 
	SET employees_bonus = employee_salary *0.10;
END IF;

END $$

call employee_bonus(10007, @percent_bonus);
select @percent_bonus;


-- This stored procedure creates a curson that points at employees' titles --

delimiter $$ 
CREATE PROCEDURE title_cursor(

INOUT  titles varchar(30)
)
BEGIN
	DECLARE employee_number int;
	DECLARE employee_titles varchar(50);
	DECLARE title_cursor CURSOR FOR SELECT title FROM titles;
	
OPEN title_cursor;

read_loop: LOOP 
	FETCH title_cursor INTO employee_titles;
	IF done THEN 
		LEAVE read_loop;
	
	END IF;
	
SET titles = concat(employee_title, ";" , titles);
END LOOP read_loop;
CLOSE title_cursor;

END $$ 
CALL PROCEDURE title_cursor 

-- Stored Procedure that returns average salary --
delimiter $$
CREATE PROCEDURE average_salary_by_dept(
	IN emp_salary int 
)
BEGIN 
	DECLARE avg_salary int (30);

	SELECT s.emp_no , avg(s.salary), d.dept_name
	FROM salaries s 
	INNER JOIN dept_emp de ON de.emp_no = s.emp_no 
	INNER JOIN departments d ON d.dept_no = de.dept_no 
	WHERE s.salary = emp_salary;

	IF emp_salary < 45000
	  THEN SET avg_salary = 'Low';
	ELSEIF emp_salary >= 450000 AND emp_salary <= 60000
	  THEN SET avg_salary = 'Average';
	ELSE 
	  SET avg_Salary = 'High';
END IF;

END $$

-- Store procedure that returns employees by gender and department
delimiter $$
CREATE PROCEDURE employees_Gender_Dept(
	IN employee_department varchar(30),
	employee_gender char(10)
)
BEGIN
	DECLARE department varchar(30);
	
	
	SELECT e.emp_no, e.first_name, e.last_name, e.gender, d.dept_name
	FROM employees e
	INNER JOIN dept_emp de ON de.emp_no = e.emp_no 
	INNER JOIN departments d ON d.dept_no = de.dept_no 
	WHERE e.gender = employee_gender AND d.dept_name = employee_department;	

END $$

-- Store procedure that calculates total years in the job --
delimiter $$
CREATE PROCEDURE years_in_job (
	IN employee_number INT, 
	OUT years_in_job INT
	)
BEGIN
	DECLARE start_year int;
	DECLARE end_year int;

	SELECT year(de.from_date), year(de.to_date)
	INTO start_year, end_year
	FROM dept_emp de 
	WHERE de.emp_no = employee_number
	LIMIT 1;

	IF end_year = 9999 THEN
		SET end_year = year(now());
	END IF;

	 SELECT end_year - start_year INTO years_in_job;
END $$ 
