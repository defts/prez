select
  location
  , city
  , concat(cast(value as string), " ", unit) as value
  , avg(value) over() as average_country
  , avg(value) over(partition by city) as average_city
  , rank() over(order by value desc) as rank
from
  `bigquery-public-data.openaq.global_air_quality`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
order by rank asc