# Netflix_sql_project
![logo](https://github.com/user-attachments/assets/b26641d3-e9fb-40bb-97dc-8d44612fea72)
#object

## Overview
This project analyzes Netflix's content dataset using SQL to address 15 business problems, providing insights into the platform's content library. The dataset contains metadata about movies and TV shows, including their type, title, director, cast, country, release year, rating, duration, genres, and descriptions. The goal is to uncover patterns, trends, and strategic focuses within Netflix's content offerings, such as content distribution, audience targeting, regional production, and genre popularity. This analysis can assist stakeholders in understanding Netflix's content strategy and market dynamics.

The project is executed using SQL queries on a single table, netflixdata, with results interpreted to provide actionable insights. Each business problem is solved with a specific SQL query, followed by a brief explanation of the approach and findings..

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflixdata;
CREATE TABLE netflixdata
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(*) AS total_count
FROM netflixdata
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT type, rating, COUNT(*) AS rating_count
    FROM netflixdata
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_common_rating
FROM RankedRatings
WHERE rank = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflixdata
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5 
    LTRIM(RTRIM(value)) AS country, 
    COUNT(*) AS total_content
FROM netflixdata
CROSS APPLY STRING_SPLIT(country, ',')
WHERE value IS NOT NULL AND value != ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_content DESC;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT TOP 1 *
FROM netflixdata
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, 2) AS INT) DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflixdata
WHERE 
    date_added IS NOT NULL
    AND TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflixdata
WHERE director IS NOT NULL
  AND director LIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflixdata
WHERE type = 'TV Show'
  AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    value AS genre,
    COUNT(*) AS total_content
FROM netflixdata
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY value;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT TOP 5 
    release_year,
    COUNT(*) AS total_release,
    ROUND(CAST(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM netflixdata WHERE country LIKE '%India%') AS FLOAT), 2) AS avg_release_percent
FROM netflixdata
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release_percent DESC;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflixdata
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflixdata
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflixdata
WHERE cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(GETDATE()) - 10
  AND type = 'Movie';
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT TOP 10 
    LTRIM(RTRIM(value)) AS actor,
    COUNT(*) AS total_movies
FROM netflixdata
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country LIKE '%India%' AND type = 'Movie'
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_movies DESC;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT
        *,
        CASE
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflixdata
) AS categorized
GROUP BY category, type
ORDER BY type;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
