-- Neyflix Project 

DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix(
	show_id	varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(210),
	casts varchar(1000),
	country	varchar(150),
	date_added varchar(50),
	release_year int,
	rating	varchar(10),
	duration varchar(15),
	listed_in varchar(100),
	description varchar(300)
);

SELECT * FROM netflix;


SELECT 
	COUNT(*) as total_content 
FROM netflix;


SELECT 
	DISTINCT type
FROM netflix;


SELECT * FROM netflix;

-- Business Problems

--1. Count the number of Movies vs Tv Shows


SELECT 
	type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV show
SELECT
	type,
	rating
FROM 
(
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
) as t1
WHERE
	ranking = 1;



-- 3. List all movies released in a specific year


SELECT * FROM netflix
WHERE
	type = 'Movie'
	AND
	release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
group by 1
ORDER BY 2 DESC
LIMIT 5;


SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country
FROM netflix;


-- 5. Identify the longest movie or TV show duration 

SELECT * FROM netflix
WHERE
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



-- 7. Find all the movies/TV show by director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all the TV show with more then 5 seasons

SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ',1)::numeric > 5;

-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;

-- 10. Find each year and the average numbers of content release in India on netflix.


SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
	,2)as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1;


-- 11. List All Movies that are Documentaries

SELECT *
FROM netflix
WHERE
	listed_in ILIKE '%documentaries%';

-- 12. Find All Content Without a Director

SELECT *
FROM netflix
WHERE
	director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT *
FROM netflix
WHERE
	casts ILIKE '%Salman khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 15;

-- 14.  Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India


SELECT
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords


WITH new_table
AS
(
SELECT *,
	CASE
	WHEN
		description ILIKE '%KILL%' OR
		description ILIKE '%VIOLENCE%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1;


