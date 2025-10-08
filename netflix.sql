DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
show_id VARCHAR(8),
type VARCHAR(15),
title VARCHAR(160),	
director VARCHAR(210),
casts VARCHAR(1000),
country VARCHAR(160),
date_added VARCHAR(50),
release_year INT,
rating	VARCHAR(10),
duration VARCHAR(15),
listed_in	VARCHAR(100),
description VARCHAR(260)

);


--1.COUNT THE NUMBERS OF MOVIES VS TV SHOWS 

--first method
SELECT SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 end )
FROM netflix;

--second method 

SELECT type,
COUNT(*) as total_content 
from netflix 
group by type;



--2.FIND THE MOST COMMON RATING FOR MOVIES AND TV SHOWS

SELECT rating,
COUNT(*) as common_ratings 
from netflix 
group by rating
order by common_ratings  desc; 

SELECT type , MAX(rating)
from netflix
group by 1;

select 
type,
rating,
count(*)
from netflix
group by 1,2 
order by count desc;




--3.LIST OF MOVIES RELEASED IN A SPECIFIC YEAR 

SELECT release_year, title AS movie_name
FROM netflix
WHERE type = 'Movie' 
and release_year = 2002
ORDER BY release_year ASC, title ASC;




--4.FIND THE TOP 5 COUNTRIES WITH THE MOST CONTENT ON NETFLIX

SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;




--5. IDENTIFY THE LONGEST MOVIE

SELECT 
    *
FROM netflix
WHERE type = 'Movie'
and duration = (select max(duration) from netflix)



--6. FIND CONTENT ADDED IN  THE LAST 5 YEARS

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



--7. FIND ALL MOVIES/TV SHOWS BY DIRECTOR 'Rajiv Chilaka'

SELECT *
FROM netflix 
where 
director like '%Rajiv Chilaka%'


--8.FIND the content without the director

select *from netflix
where 
director is null ;



--9.FIND HOW MANY MOVIES ACTOR SALMAM KHAN APPERED IN LAT 10 YEARS

SELECT *FROM netflix
where 
 TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '10 YEARS' 
 AND casts like '%Salman Khan%' 
 order by release_year asc; 



--10. LIST ALL TV SHOWS WITH MORE THAN 5 SEASONS

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;



--11.COUNT THE NUMBER OF CONTENT ITEMS IN EACH GENRE

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;



--12.FIND EACH YEAR AND THE AVERAGE NUMBERS OF CONTENT RELEASE IN INDIA ON NETFLIX

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;




--13. FIND ALL MOVIES THAT ARE DOCUMENTARIES

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';




--14.FIND ALL CONTENT WITHOUT A DIRECTOR

SELECT * 
FROM netflix
WHERE director IS NULL;



--15.FIND TOP 10 ACTORS WHO APPEARED IN THE HIGHEST NUMBER OF MOVIES  PRODUCED IN INDIA

select 
 unnest(string_to_array(casts,',')) as new_cast,
 count(type)
 from netflix
 where 
 type = 'Movie'
and country like '%India%' 
group by new_cast  
order by count(type) desc
limit 10;


  
--16. Caegorize content based on the presence of 'kill' and 'violence' keywords


WITH new_table
AS
(
SELECT *,

case when
description like '%kill%' 
or 
description like '%violence%' then 'bad_content'
else 'good_content'
end category 
from netflix
)
SELECT 
category,
count(*) as total_content
from new_table
group by 1
