SELECT DATABASE();
use project_job_market_analysis;
show tables;
select * from Market;
USE project_job_market_analysis;

-- 1.States with Most Number of Jobs.

SELECT 
    SUBSTRING_INDEX(Location, ',', -1) AS State,
    COUNT(*) AS NumberOfJobs,
    MIN(Location) AS SampleLocation -- or MAX(Location) depending on your preference
FROM 
    Market
GROUP BY 
    State
ORDER BY 
    NumberOfJobs DESC
LIMIT 1000;

-- 2.Average Minimal and Maximal Salaries in Different States
SELECT 
    SUBSTRING_INDEX(Location, ',', 1) AS State, -- Full name of the location (assuming it's before the comma)
    SUBSTRING_INDEX(Location, ',', -1) AS CountryCode, -- Abbreviation as the country code (assuming it's after the comma)
    AVG((MinSalary + MaxSalary) / 2) AS AvgSalary,
    MIN(MinSalary) AS MinSalary,
    MAX(MaxSalary) AS MaxSalary
FROM (
    SELECT 
        Location,
        CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(Salary_Estimate, '-', 1), '$', -1), 'K', '') AS UNSIGNED) * 1000 AS MinSalary,
        CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(Salary_Estimate, '-', -1), '$', -1), 'K', '') AS UNSIGNED) * 1000 AS MaxSalary
    FROM 
        Market
    WHERE
        Salary_Estimate IS NOT NULL AND
        Salary_Estimate != 'Unknown'
) AS SalaryParsed
GROUP BY 
    State, CountryCode
ORDER BY 
    State;	

-- 3.Average Salary in Different States

SELECT 
    SUBSTRING_INDEX(Location, ',', 1) AS State, -- Full name of the location (assuming it's before the comma)
    AVG((MinSalary + MaxSalary) / 2) AS AvgSalary -- Average of the midpoint of the salary range
FROM (
    SELECT 
        Location,
        CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(Salary_Estimate, '-', 1), '$', -1), 'K', '') AS UNSIGNED) * 1000 AS MinSalary,
        CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(Salary_Estimate, '-', -1), '$', -1), 'K', '') AS UNSIGNED) * 1000 AS MaxSalary
    FROM 
        Market
    WHERE
        Salary_Estimate IS NOT NULL AND
        Salary_Estimate != 'Unknown'
) AS SalaryParsed
GROUP BY 
    State
ORDER BY 
    State
LIMIT 1000;

-- 4.Top 5 Industries with Maximum Number of Data Science Related Job Postings.

SELECT 
    Industry,
    COUNT(*) AS NumJobPostings
FROM 
    Market
WHERE
    Job_Title LIKE '%Data Scientist%' OR
    Job_Title LIKE '%Data Science%' OR
    Job_Title LIKE '%Machine Learning%' OR
    Job_Title LIKE '%AI%' -- Add more conditions as needed to match data science-related job titles
GROUP BY 
    Industry
ORDER BY 
    NumJobPostings DESC
LIMIT 5;

-- 5.Companies with Maximum Number of Job Openings.

SELECT 
    Company_Name,
    COUNT(*) AS NumJobPostings
FROM 
    Market
WHERE
    Salary_Estimate IS NOT NULL AND
    Salary_Estimate != 'Unknown'
GROUP BY 
    Company_Name
ORDER BY 
    NumJobPostings DESC
LIMIT 5;

-- 6.Job Titles with Most Number of Jobs.

SELECT 
    Job_Title,
    COUNT(*) AS NumJobPostings
FROM 
    Market
WHERE
    Salary_Estimate IS NOT NULL AND
    Salary_Estimate != 'Unknown'
GROUP BY 
    Job_Title
ORDER BY 
    NumJobPostings DESC
LIMIT 5;	




-- 7.Salary of Job Titles with Most Number of Jobs.


SELECT 
    t.Job_Title,
    COUNT(*) AS NumJobPostings,
    AVG((CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.Salary_Estimate, '-', 1), '$', -1), 'K', '') AS UNSIGNED) * 1000 + 
         CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.Salary_Estimate, '-', -1), '$', -1), 'K', '') AS UNSIGNED) * 1000) / 2) AS AvgSalary,
    MIN(CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.Salary_Estimate, '-', 1), '$', -1), 'K', '') AS UNSIGNED) * 1000) AS MinSalary,
    MAX(CAST(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.Salary_Estimate, '-', -1), '$', -1), 'K', '') AS UNSIGNED) * 1000) AS MaxSalary
FROM 
    Market t
JOIN (
    SELECT 
        Job_Title
    FROM 
        Market
    WHERE
        Salary_Estimate IS NOT NULL AND
        Salary_Estimate != 'Unknown'
    GROUP BY 
        Job_Title
    ORDER BY 
        COUNT(*) DESC
    LIMIT 5
) AS topJobTitles ON t.Job_Title = topJobTitles.Job_Title
WHERE
    t.Salary_Estimate IS NOT NULL
    AND t.Salary_Estimate != 'Unknown'
GROUP BY 
    t.Job_Title
ORDER BY 
    NumJobPostings DESC;
    
DESCRIBE Market;

    
-- 8.Skills Required by Companies for Each Job Title.


SELECT 
    t.Job_Title,
    GROUP_CONCAT(DISTINCT t.Skills ORDER BY t.Skills SEPARATOR ', ') AS RequiredSkills
FROM (
    SELECT 
        Job_Title,
        Salary_Estimate,
        CASE WHEN python = 1 THEN 'python'
             WHEN excel = 1 THEN 'excel'
             WHEN 'sql' = 1 THEN 'sql'
             WHEN hadoop = 1 THEN 'hadoop'
             WHEN tableau = 1 THEN 'tableau'
             WHEN bi = 1 THEN 'bi'
             WHEN flink = 1 THEN 'flink'
             WHEN mongo = 1 THEN 'mongo'
             WHEN google_an = 1 THEN 'google_an'
             WHEN tensor = 1 THEN 'tensor'
             ELSE NULL END AS Skills
    FROM Market
) AS t
WHERE 
    t.Salary_Estimate IS NOT NULL
    AND t.Salary_Estimate != 'Unknown'
    AND t.Skills IS NOT NULL
GROUP BY 
    t.Job_Title
ORDER BY 
    t.Job_Title;
    
--  10.Relation between Average Salary and Education.

SELECT
  'master(M)' AS Educational_Qualification,
  SUM(CASE WHEN Degree = 'm' THEN Lower_Salary + Upper_Salary + Avg_SalaryK / 3 END) AS Salary_Amount
FROM Market
UNION ALL
SELECT
  'NA' AS Educational_Qualification,
  SUM(CASE WHEN Degree = 'na' THEN Lower_Salary + Upper_Salary + Avg_SalaryK / 3  END) AS Salary_Amount
FROM Market
UNION ALL
SELECT
  'Ph.D degree(P)' AS Educational_Qualification,
  SUM(CASE WHEN Degree = 'p' THEN Lower_Salary + Upper_Salary + Avg_SalaryK / 3 END) AS Salary_Amount
FROM Market;

SHOW DATABASES;

-- to knoe user name and servername
SELECT @@hostname AS 'Server Name';
SELECT USER() AS 'Current User';

SELECT USER() AS 'Current User';

-- no of job openings availabe in the  Market
SELECT COUNT(*) AS Number_Of_Job_Openings
FROM Market;

select * from Market;


----- Completed-------

