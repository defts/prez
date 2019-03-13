select
  city
  , avg(value) as avegage
  , array_agg(value) as all_values
from
  `bigquery-public-data.openaq.global_air_quality`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
group by city
order by city asc