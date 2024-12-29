--Summary of Skills/Methods Used:
--Database Selection (USE)
--Data Retrieval (SELECT)
--Creating Tables (SELECT INTO)
--Inserting Data (INSERT)
--Data Cleaning Steps: Checking for duplicates, standardizing data, handling null values.
--Removing Duplicates: Using ROW_NUMBER, CTEs, and DELETE.
--Data Standardization: Using TRIM, UPDATE.
--Date Handling: Using CONVERT, TRY_CONVERT, ALTER TABLE.
--Joining Tables (JOIN)
--Updating Data (UPDATE)


--When we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


--USE Statement: Selects the database to work with.
USE Layoffs; 

--SELECT Statement: Retrieves all rows from the layoffs table.
SELECT * FROM layoffs;

--Creating Staging Table: Creates an empty staging table with the same structure as layoffs using SELECT INTO.
SELECT TOP 0 * INTO layoffs_staging FROM layoffs;

--Inserting Data: Inserts data into the staging table.
INSERT layoffs_staging 
SELECT * FROM layoffs;

SELECT *
FROM world_layoffs.layoffs_staging;

--Checking for Duplicates: Using ROW_NUMBER to identify duplicates.
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location, industry, total_laid_off,percentage_laid_off, 'date', stage, country, funds_raised_millions 
ORDER BY company)
AS row_num
FROM layoffs_staging;

--Common Table Expressions (CTEs): Used for duplicate identification and deletion.
-- Looks for all duplicates
-- When looking for duplicates partition by all columns.
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location, industry, total_laid_off,percentage_laid_off, 'date', stage, country, funds_raised_millions 
ORDER BY company)
AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

--DELETES all duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location, industry, total_laid_off,percentage_laid_off, 'date', stage, country, funds_raised_millions 
ORDER BY company)
AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- 2. Standardize Data
--Trimming Data: Using TRIM to clean up whitespace.
SELECT company, TRIM(company) 
AS trimmed_company 
FROM layoffs_staging 
ORDER BY company;

--Updating Data: Standardizing specific columns.
UPDATE layoffs_staging
SET company= TRIM(company);

-- Do this for each column
SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry;

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%' ;

SELECT DISTINCT country
FROM layoffs_staging
ORDER BY country;

UPDATE layoffs_staging
SET country = 'United States'
WHERE country LIKE 'United States%' ;

SELECT [date]
FROM layoffs_staging;

--Used to convert date to string but gives errors
SELECT [date],
CONVERT(DATE, [date], 101) AS converted_date
FROM layoffs_staging;

--used to see where the error is coming from
SELECT [date] FROM layoffs_staging WHERE ISDATE([date]) = 0;

--converts  with no issues
SELECT [date], 
TRY_CONVERT(DATE, [date], 101) AS converted_date 
FROM layoffs_staging;

UPDATE layoffs_staging
SET [date] = TRY_CONVERT(DATE, [date], 101);

SELECT [date]
FROM layoffs_staging;

ALTER TABLE layoffs_staging
ALTER COLUMN [date] DATE;

--Filtering Null Values: Checking for NULL values.
SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging
WHERE company = 'Airbnb';

--Joining Tables: Ensuring consistency across different records.
SELECT t1.industry, t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE t1 SET t1.industry = t2.industry 
FROM layoffs_staging t1 
JOIN layoffs_staging t2 
ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL;


