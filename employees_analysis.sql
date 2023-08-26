/*Task 1 Покажите среднюю зарплату сотрудников за каждый год */

SELECT DISTINCT year(from_date) AS YEAR,
round(AVG(salary) OVER(PARTITION BY year(from_date)),2)
FROM salaries;

/*Task2 Покажите среднюю зарплату сотрудников по каждому отделу. Примечание: 
только текущие отделы и текущую заработную плату*/

SELECT DISTINCT dept_name,
round(AVG(salary) OVER(PARTITION BY dept_emp.dept_no),2) AS avg_salary
FROM salaries
	LEFT JOIN dept_emp USING(emp_no)
	INNER JOIN  departments USING(dept_no)
WHERE curdate() < salaries.to_date AND curdate() < dept_emp.to_date;

/*Task3 Покажите среднюю зарплату сотрудников по каждому отделу за каждый год.
Примечание: для средней зарплаты отдела X в году Y нам нужно взять среднее
значение всех зарплат в году Y сотрудников, которые были в отделе X в году Y.*/

SELECT DISTINCT dept_name, year(salaries.from_date) AS 'YEAR',
round(AVG(salary) OVER(PARTITION BY dept_emp.dept_no , year(salaries.from_date)),2) AS 'AVG_salary'
FROM salaries
	LEFT JOIN dept_emp on(salaries.emp_no=dept_emp.emp_no AND 
			( salaries.from_date BETWEEN dept_emp.from_date AND dept_emp.to_date) )
	LEFT JOIN departments USING(dept_no);
    
#Task 4 Покажите для каждого года самый крупный отдел (по количеству сотрудников) в этом году и его среднюю зарплату

SELECT dept_no, departments, year,max_count,avg_salary
FROM
	(SELECT dept_emp.dept_no,
    dept_name AS departments, 
    year(salaries.from_date) as year ,
    COUNT(salaries.emp_no) as max_count,
    round( AVG(salary),2) as avg_salary,
	RANK () OVER(PARTITION BY  year(from_date) ORDER BY COUNT(emp_no) DESC) as r
		FROM salaries
			LEFT JOIN dept_emp on(salaries.emp_no=dept_emp.emp_no AND 
			( salaries.from_date BETWEEN dept_emp.from_date AND dept_emp.to_date) )
			LEFT JOIN departments on (departments.dept_no=dept_emp.dept_no ) 
	GROUP BY year(from_date), dept_no) as rnc
WHERE r=1;

#Task 5 Покажите подробную информацию о менеджере, который дольше всех исполняет свои обязанности
   
SELECT s.emp_no,s.salary,s.from_date,s.to_date ,t.title,de.dept_no,dept_name,concat(first_name,last_name) AS name,e.birth_date,gender
FROM salaries AS s
	LEFT JOIN titles AS t ON (s.emp_no = t.emp_no AND s.from_date BETWEEN t.from_date AND t.to_date)
	LEFT JOIN dept_emp AS de ON (s.emp_no= de.emp_no)
	LEFT JOIN departments USING(dept_no)
	LEFT JOIN employees AS e ON (s.emp_no  = e.emp_no)
WHERE s.emp_no = ( SELECT dept_manager.emp_no
				   FROM dept_manager 
				   WHERE curdate()< to_date
				   ORDER BY DATEDIFF(CURDATE(), from_date) DESC
				   LIMIT 1)
   ;
