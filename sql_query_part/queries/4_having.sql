select
  city
  , avg(value) as average
from
  `bigquery-public-data.openaq.global_air_quality`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
group by city
having avg(value) > 25
order by average desc