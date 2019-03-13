select
  location
  , city
  , value
  , pollutant
  , timestamp
from
  `bigquery-public-data.openaq.global_air_quality`
where
  pollutant = 'pm10'
  and country='FR'
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)