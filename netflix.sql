select * from netflixdata

-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
select type, COUNT(*) AS total_count
FROM netflixdata
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
-- 2. Find the most common rating for Movies and TV Shows

with RatingCounts as (
 select type, rating,count(*) as rating_count
    from netflixdata
    group by type, rating
),
RankedRatings as (
    select
        type,
        rating,
        rating_count,
        rank() over (partition by type order by  rating_count desc) as rank
    from RatingCounts
)
select 
    type,
    rating as most_common_rating
from RankedRatings
where rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

select * 
from netflixdata
where release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

select top 5 
    ltrim(rtrim(value)) as country, 
    count(*) as total_content
from netflixdata
CROSS APPLY string_split(country, ',')
where value IS NOT NULL AND value != ''
group by LTRIM(RTRIM(value))
order by total_content desc;





-- 5. Identify the longest movie
SELECT TOP 1 *
FROM netflixdata
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, 2) AS INT) DESC;


-- 6. Find content added in the last 5 years

SELECT *
FROM netflixdata
WHERE 
    date_added IS NOT NULL
    AND TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflixdata
WHERE director IS NOT NULL
  AND director LIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflixdata
WHERE type = 'TV Show'
  AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;



-- 9. Count the number of content items in each genre

SELECT 
    value AS genre,
    COUNT(*) AS total_content
FROM netflixdata
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY value;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT TOP 5 
    release_year,
    COUNT(*) AS total_release,
    ROUND(CAST(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM netflixdata WHERE country LIKE '%India%') AS FLOAT), 2) AS avg_release_percent
FROM netflixdata
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release_percent DESC;



-- 11. List all movies that are documentaries
SELECT *
FROM netflixdata
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';




-- 12. Find all content without a director
SELECT * FROM netflixdata
WHERE director IS NULL


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflixdata
WHERE cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(GETDATE()) - 10
  AND type = 'Movie';


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TOP 10 
    LTRIM(RTRIM(value)) AS actor,
    COUNT(*) AS total_movies
FROM netflixdata
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country LIKE '%India%' AND type = 'Movie'
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_movies DESC;


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

select
    category,
    type,
    count(*) as content_count
from (
    select
        *,
      case
            when description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
           else 'Good'
       end as category
    from netflixdata
) as categorized
group by category, type
order by type;



-- End of reports

