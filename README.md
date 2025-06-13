# Netflix_sql_project
![logo](https://github.com/user-attachments/assets/b26641d3-e9fb-40bb-97dc-8d44612fea72)

#object
Netflix Data Analysis SQL Project
#Project Overview
This project analyzes Netflix's content dataset using SQL to address 15 business problems, providing insights into the platform's content library. The dataset contains metadata about movies and TV shows, including their type, title, director, cast, country, release year, rating, duration, genres, and descriptions. The goal is to uncover patterns, trends, and strategic focuses within Netflix's content offerings, such as content distribution, audience targeting, regional production, and genre popularity. This analysis can assist stakeholders in understanding Netflix's content strategy and market dynamics.
The project is executed using SQL queries on a single table, netflixdata, with results interpreted to provide actionable insights. Each business problem is solved with a specific SQL query, followed by a brief explanation of the approach and findings.

#Table Description
The dataset is stored in a table named netflixdata, which contains metadata for Netflix's movies and TV shows. The table includes columns with potentially comma-separated values (e.g., country, cast, listed_in) to accommodate multiple entries.
##Columns and Data Types
Below is the schema of the netflixdata table with column names, data types, and constraints:

show_id: varchar(6), nullUnique identifier for each movie or TV show.
type: varchar(10), nullContent type, either 'Movie' or 'TV Show'.
title: varchar(250), nullTitle of the movie or TV show.
director: varchar(208), nullDirector(s) of the content, if available.
cast: varchar(1000), nullList of actors, comma-separated.
country: varchar(150), nullCountry or countries of origin, comma-separated.
date_added: varchar(55), nullDate the content was added to Netflix (e.g., 'January 1, 2020').
release_year: int, nullYear the content was originally released.
rating: varchar(10), nullContent rating (e.g., 'TV-MA', 'PG-13').
duration: varchar(15), nullDuration, in minutes for movies (e.g., '120 min') or seasons for TV shows (e.g., '3 Seasons').
listed_in: varchar(100), nullGenres or categories, comma-separated (e.g., 'Dramas, Comedies').
description: nvarchar(250), nullBrief description of the content, using nvarchar for Unicode support.

Note: All columns allow NULL values, reflecting potential missing data. The description column uses nvarchar for broader character support, while other string columns use varchar.

##SQL Analysis: Solutions to 15 Business Problems
**Query:** 1. Count of Movies vs. TV Shows
Objective: Determine the distribution of content by type.Query:
SELECT type, COUNT(*) AS total_count
FROM netflixdata
GROUP BY type;

Explanation: Groups content by type to count movies and TV shows, offering a high-level view of Netflix's content composition.Finding: Movies typically outnumber TV shows, reflecting Netflix's focus on cinematic content.

2. Most Common Rating for Movies and TV Shows
Objective: Find the most frequent rating for each content type.Query:
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

Explanation: Uses CTEs to count ratings by type, then ranks them to identify the most common rating for movies and TV shows.Finding: TV-MA dominates movies, while TV-14 is common for TV shows, indicating a focus on mature and teen audiences.

3. List All Movies Released in a Specific Year
Objective: Retrieve movies released in a given year, using 2020 as an example.Query:
SELECT * 
FROM netflixdata
WHERE release_year = 2020;

Explanation: Filters for movies released in the specified year using the release_year column.Finding: A diverse set of movies from the selected year, spanning multiple genres and countries.

4. Top 5 Countries with the Most Content
Objective: Identify the top 5 countries producing the most content.Query:
SELECT TOP 5 
    LTRIM(RTRIM(value)) AS country, 
    COUNT(*) AS total_content
FROM netflixdata
CROSS APPLY STRING_SPLIT(country, ',')
WHERE value IS NOT NULL AND value != ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_content DESC;

Explanation: Splits the country column into individual countries, cleans whitespace, and counts content per country to find the top 5.Finding: United States, India, United Kingdom, Canada, and France lead in content production.

5. Identify the Longest Movie
Objective: Find the movie with the longest duration.Query:
SELECT TOP 1 *
FROM netflixdata
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, 2) AS INT) DESC;

Explanation: Filters for movies, extracts the numeric part of duration, and orders by length to find the longest movie. Assumes duration starts with a number in minutes.Finding: Longest movies often exceed 2 hours, typically historical dramas or epics.

6. Find Content Added in the Last 5 Years
Objective: List content added to Netflix in the last 5 years from the current date.Query:
SELECT *
FROM netflixdata
WHERE 
    date_added IS NOT NULL
    AND TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());

Explanation: Converts date_added to a DATE type and filters for the last 5 years from the current date.Finding: A significant portion of content is recent, showing active catalog updates.

7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
Objective: Retrieve content directed by Rajiv Chilaka.Query:
SELECT *
FROM netflixdata
WHERE director IS NOT NULL
  AND director LIKE '%Rajiv Chilaka%';

Explanation: Searches for content where the director includes 'Rajiv Chilaka', accounting for multiple directors.Finding: Mostly animated content like Chhota Bheem, popular among children.

8. List All TV Shows with More Than 5 Seasons
Objective: Identify TV shows with over 5 seasons.Query:
SELECT *
FROM netflixdata
WHERE type = 'TV Show'
  AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

Explanation: Extracts the number of seasons from duration and filters for TV shows with more than 5 seasons.Finding: Includes long-running shows like Grey's Anatomy, indicating popularity.

9. Count the Number of Content Items in Each Genre
Objective: Count content items per genre.Query:
SELECT 
    value AS genre,
    COUNT(*) AS total_content
FROM netflixdata
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY value;

Explanation: Splits the listed_in column into genres and counts items per genre.Finding: Dramas, comedies, and documentaries are the most common genres.

10. Top 5 Years for Content Releases by India
Objective: Find the top 5 years with the highest average content releases from India.Query:
SELECT TOP 5 
    release_year,
    COUNT(*) AS total_release,
    ROUND(CAST(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM netflixdata WHERE country LIKE '%India%') AS FLOAT), 2) AS avg_release_percent
FROM netflixdata
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release_percent DESC;

Explanation: Calculates the percentage of India's content per year relative to total Indian content, ordering by percentage.Finding: Recent years show a peak in Indian production, reflecting a growing market.

11. List All Movies That Are Documentaries
Objective: Retrieve movies categorized as documentaries.Query:
SELECT *
FROM netflixdata
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';

Explanation: Filters for movies where listed_in includes 'Documentaries'.Finding: A diverse set of documentaries covering nature, history, and social issues.

12. Find All Content Without a Director
Objective: List content with no director.Query:
SELECT * 
FROM netflixdata
WHERE director IS NULL;

Explanation: Filters for content where director is NULL.Finding: Many TV shows and some movies lack a director, often due to collaborative production.

13. Find Movies with Actor 'Salman Khan' in the Last 10 Years
Objective: List movies featuring Salman Khan from the last 10 years.Query:
SELECT *
FROM netflixdata
WHERE cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(GETDATE()) - 10
  AND type = 'Movie';

Explanation: Filters for movies with Salman Khan in the cast and released in the last 10 years from the current date.Finding: Includes Bollywood hits like Bajrangi Bhaijaan, showcasing his prominence.

14. Top 10 Actors in Indian Movies
Objective: Identify the top 10 actors with the most appearances in Indian movies.Query:
SELECT TOP 10 
    LTRIM(RTRIM(value)) AS actor,
    COUNT(*) AS total_movies
FROM netflixdata
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country LIKE '%India%' AND type = 'Movie'
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_movies DESC;

Explanation: Splits the cast column, filters for Indian movies, and counts appearances per actor.Finding: Shah Rukh Khan, Anupam Kher, and Amitabh Bachchan lead, reflecting their prolific careers.

15. Categorize Content by Keywords 'Kill' and 'Violence'
Objective: Categorize content as 'Bad' if its description contains 'kill' or 'violence', else 'Good', and count items per category and type.Query:
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

Explanation: Labels content based on keywords in description, then groups and counts by category and type.Finding: A notable portion of movies are 'Bad' due to action/thriller genres, while TV shows are more 'Good'.

Key Insights

Content Composition: Movies dominate over TV shows, with a focus on cinematic content.  
Audience Targeting: TV-MA and TV-14 ratings are prevalent, catering to mature and teen viewers.  
Regional Production: The U.S. and India lead, with India showing significant growth in recent years.  
Content Trends: A large portion of content is recent, and long-running TV shows highlight Netflix's focus on fresh, engaging content.  
Genre Popularity: Dramas, comedies, and documentaries are top genres, reflecting diverse viewer interests.  
Indian Market: Actors like Shah Rukh Khan and Salman Khan drive Indian movie production.  
Content Categorization: Movies often contain 'kill' or 'violence' due to action genres, while TV shows are more family-friendly.


Conclusion
This SQL project provides a deep dive into Netflix's content library, revealing strategic focuses on movies, mature-rated content, and regional production, particularly from the U.S. and India. The analysis highlights Netflix's commitment to diverse genres, recent content, and long-running series, offering valuable insights for content strategy and market expansion.
