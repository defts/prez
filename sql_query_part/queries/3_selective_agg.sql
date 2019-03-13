select
  city
  -- pg: avg(value) filter(where pollutant = 'pm10') as avg_pm10
  , avg(CASE WHEN pollutant = 'pm10' THEN value END) as avg_pm10
  , avg(CASE WHEN pollutant = 'pm25' THEN value END) as avg_pm25
from
  `bigquery-public-data.openaq.global_air_quality`
where
  pollutant in('pm10', 'pm25') 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
group by city
order by city asc