-- Select
SELECT *
FROM employee_demographics;

SELECT first_name,
last_name,
birth_date,
age,
age + 10
FROM employee_demographics;

SELECT DISTINCT gender
FROM employee_demographics;

SELECT *
FROM employee_salary
WHERE first_name = 'Leslie'
;

SELECT *
FROM employee_salary
WHERE salary >= 50000
;

SELECT *
FROM employee_demographics
WHERE gender != 'Female'
;

-- AND Or not -- Logical Operators

SELECT *
FROM employee_demographics
WHERE birth_date > '1985-01-01'
OR gender = 'male'
;

-- LIKE STATEMENT
-- % and _
SELECT *
FROM employee_demographics
WHERE first_name LIKE 'Jer%'
;

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'A__'
;

-- Group By
SELECT gender, AVG(age), MAX(age), min(age), COUNT(age)
FROM employee_demographics
GROUP BY gender
;

-- Order By
SELECT *
FROM employee_demographics
ORDER BY first_name DESC
;

SELECT *
FROM employee_demographics
ORDER BY gender, age DESC
;

-- HAVING
SELECT occupation, AVG(salary)
FROM employee_salary
WHERE occupation LIKE '%manager%' # filter row level
GROUP BY occupation
HAVING AVG(salary) > 75000 # filter aggregate function level
;

-- Limit
SELECT *
FROM employee_demographics
ORDER BY age DESC
LIMIT 3, 1
;

-- Aliasing
SELECT gender, AVG(age) AS avg_age
FROM employee_demographics
GROUP BY gender
HAVING avg_age > 40;
;

-- INNER JOINS
SELECT dem.employee_id, age, occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- OUTER JOINS
SELECT *
FROM employee_demographics AS dem
RIGHT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- SELF JOIN
SELECT emp1.employee_id AS emp_santa,
emp1.first_name AS first_name_santa,
emp1.last_name AS last_name_santa,
emp2.employee_id AS emp_name,
emp2.first_name AS first_name_emp,
emp1.last_name AS last_name_emp 
FROM employee_salary emp1
JOIN employee_salary emp2
	ON emp1.employee_id + 1 = emp2.employee_id
;

-- Joining multiple tables together
SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments pd
	ON sal.dept_id = pd.department_id
;

SELECT *
FROM parks_departments;

-- Union
SELECT first_name, last_name, 'Old Man' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Lady' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Highly Paid Employee' AS Label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name
;


-- String Functions
SELECT LENGTH('skyfall');

SELECT first_name, LENGTH(first_name)
FROM employee_demographics
ORDER BY 2
;

SELECT UPPER('sky'); # Uppercase
SELECT LOWER('sky'); # Lowercase

SELECt first_name, UPPER(first_name)
FROM employee_demographics
;

SELECT TRIM('      sky     '); # Trim deletes leading and trailing white spaces

SELECT LTRIM('    sky    '); # Left Trim
SELECT RTRIM('    sky    '); # Right Trim

SELECT first_name, 
LEFT(first_name, 4), #select first 4 chars
RIGHT(first_name, 4), #select right 4 chars
SUBSTRING(first_name, 3, 2), #start from third position then 2 after that
birth_date,
SUBSTRING(birth_date, 6, 2) AS birth_month
FROM employee_demographics
;

SELECT first_name, REPLACE(first_name, 'a', 'z') #replace a with z
FROM employee_demographics
;

SELECT LOCATE('x', 'Maxine'); #locates position of char

SELECT first_name, LOCATE('an', first_name)
FROM employee_demographics;

SELECT first_name, last_name,
CONCAT(first_name, ' ', last_name) AS full_name #merges things inside columns together
FROM employee_demographics
;

# Case Statement
SELECT first_name,
last_name,
age,
CASE
	WHEN age <= 30 THEN 'Young'
    WHEN age BETWEEN 31 and 50 THEN 'Old'
    WHEN age >= 50 THEN "On Death's Door"
END AS Age_Bracket
FROM employee_demographics;

SELECT first_name, last_name, salary,
CASE
	WHEN salary < 50000 THEN salary + (salary * 0.05)
    WHEN salary > 50000 THEN salary + (salary * 0.07)
END AS new_salary,
CASE
	WHEN dept_id = 6 THEN salary * .10
END
FROM employee_salary
;

SELECT *
FROM employee_salary
;

#Subqueries

SELECT *
FROM employee_demographics
WHERE employee_id IN (
	SELECT employee_id
    FROM employee_salary
    WHERE dept_id = 1)
;

SELECT first_name, salary,
	(SELECT AVG(salary)
    FROM employee_salary)
FROM employee_salary
;

SELECT gender, AVG(age), MAX(age), COUNT(age)
FROM employee_demographics
GROUP BY gender
;

SELECT gender, AVG(`MAX(age)`)
FROM
	(SELECT gender, AVG(age), MAX(age), COUNT(age)
	FROM employee_demographics
	GROUP BY gender) AS agg_table
GROUP BY gender
;

SELECT AVG(max_age) #calculates average maximum age of employees
FROM
(SELECT gender,
AVG(age) AS avg_age,
MAX(age) AS max_age,
MIN(age) AS min_age,
COUNT(age) I
FROM employee_demographics
GROUP BY gender) AS Agg_table
;

-- Window Functions
SELECT gender, AVG(salary) AS avg_salary # average salary for all genders
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender;


SELECT dem.first_name, dem.last_name, gender, AVG(salary) OVER(PARTITION BY gender) # average salary by gender
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

SELECT dem.first_name, dem.last_name, gender, salary, #Salary adds each row
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS Rolling_Total 
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary, #Salary adds each row
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num, # rank assign same number for duplicates, next number positionally
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num # rank assign same number for duplicates, next number numerically
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

-- CTE (common table expression)
# Readability and more complex calculations

WITH CTE_Example AS
(
SELECT gender, AVG(salary) avg_sal, MAX(salary) max_sal, MIN(salary) min_sal, COUNT(salary) count_sal
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_sal) # Average salary for male and female
FROM CTE_Example
;

-- Same thing but as a subquery
SELECT AVG(avg_sal)
FROM (
SELECT gender, AVG(salary) avg_sal, MAX(salary) max_sal, MIN(salary) min_sal, COUNT(salary) count_sal
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
) example_subquery
;

# Two CTEs joined
WITH CTE_Example AS
(
SELECT employee_id, gender, birth_date
FROM employee_demographics
WHERE birth_date > '1985-01-01'
),
CTE_Example2 AS
(
SELECT employee_id, salary
FROM employee_salary
WHERE salary > 50000
)
SELECT *
FROM CTE_Example
JOIN CTE_Example2
	ON CTE_Example.employee_id = CTE_Example2.employee_id
;

-- Temp Table

# Method 1
CREATE TABLE temp_table
(first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
);

INSERT INTO temp_table
VALUES('Alex', 'Freberg', 'Lord of the Rings')
;

SELECT *
FROM temp_table;

# Method 2
CREATE TEMPORARY TABLE salary_over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT *
FROM salary_over_50k;

-- Stored Procedures

CREATE PROCEDURE large_salaries()
SELECT *
FROM Employee_salary
WHERE salary >= 50000
;

CALL large_salaries();

DELIMITER $$
CREATE PROCEDURE large_salaries2()
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary >= 50000;
	SELECT *
	FROM employee_salary
	WHERE salary >= 10000;
END $$
DELIMITER ;

CALL large_salaries2();

# Parameters
DELIMITER $$
CREATE PROCEDURE large_salaries3(employee_id_param INT)
BEGIN
	SELECT salary
	FROM employee_salary
    WHERE employee_id = employee_id_param
	;
END $$
DELIMITER ;

CALL large_salaries3(1);

-- Trigger
DELIMITER $$
CREATE TRIGGER employee_ insert 
	AFTER INSERT ON employee_salary 
	FOR EACH ROW 
BEGIN 
	INSERT INTO employee_demographics (employee_id, first_name, last_name) 
	VALUES (NEW.employee_id, NEW.first _name, NEW. last _name); 
END $$ 
DELIMITER ; 

INSERT INTO employee_salary (employee_id, first_name, last. _name, occupation, salary, dept_id) 
VALUES(13, 'Jean-Ralphio', 'Saperstein', 'Exntertainment 720 CEO',1000000, NULL);

-- Events
DELIMITER $$ 
CREATE EVENT delete_retirees 
ON SCHEDULE EVERY 30 SECOND 
DO 
BEGIN 
	DELETE 
	FROM employee_demographics 
	WHERE age >= 60; 
END $$ 
DELIMITER ;

