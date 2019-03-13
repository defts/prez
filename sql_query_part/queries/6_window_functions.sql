select
  rank() over(order by avg(value) desc) as rank
  , city
  , avg(value) as avergage
  , [min(value), max(value)] as min_max
  , concat(
    '+', cast(
        round(
            (avg(value) 
            - lead(avg(value)) over(order by avg(value) desc))
            / avg(value) * 100, 2) 
        as string)
    , '%'
    ) as variance_from_previous
    , concat(
        cast(
            round(
                (avg(value) 
                  - first_value(avg(value)) over(order by avg(value) asc)
            ) / first_value(avg(value)) over(order by avg(value) asc), 2) 
        as string)
    , 'x'
    ) as times_from_first
from
  `bigquery-public-data.openaq.global_air_quality`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
group by city
order by rank asc