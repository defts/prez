# Quickie SQL - Get Some Data - Query part


TODO : 

- ameliorer intro 
  - presenter openAQ
    - derniere valeur relevé
- merger aggregate slides

passer plus vite au début 


---

## Dataset

- bigquery
- openaq
---

## Where

> demande : je voudrais avoir les valeurs **pm10** en **france** et que l'**information ne date pas de plus de deux jours** 

![cat where image](https://media.giphy.com/media/iTOS89Y0gD1ny/giphy.gif)

> solution : `where`

Note:
```
select
  location
  , city
  , concat(cast(value as string), " ", unit)
  , pollutant
  , timestamp
from
  \`bigquery-public-data.openaq.global_air_quality\`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
```

---

## Group et Aggregate functions

> demande : je voudrais avoir les **valeurs moyennes par city ainsi que la liste de toutes les valeurs** des pm10 en france et que l'information ne date pas de plus de deux jours 

![cat aggregate image](https://media.giphy.com/media/UotLuplZSzKRa/200w.webp)

> solution : `Aggregates functions`

Note:
```
select
  city
  , avg(value) as avegage
  , array_agg(value) as all_values
from
  \`bigquery-public-data.openaq.global_air_quality\`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
group by 
  city, pollutant
```

---

## Aggregate functions - Selective Aggregates

> demande : je voudrais avoir les valeurs moyennes par city des pm10 **et des pm2.5** en france et que l'information ne date pas de plus de deux jours 


![cat aggreage 2 image](https://media.giphy.com/media/WFGwTDeEtcbL2/giphy.gif)

> solution : `filter — Selective Aggregates`

Note:
```
select
  city
  -- pg: avg(value) filter(where pollutant = 'pm10') as avg_pm10
  , avg(CASE WHEN pollutant = 'pm10' THEN value END) as avg_pm10
  , avg(CASE WHEN pollutant = 'pm25' THEN value END) as avg_pm25
from
  \`bigquery-public-data.openaq.global_air_quality\`
where
  pollutant in('pm10', 'pm25') 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
group by 
  city
order by city asc
```

---

## Having

> demande : je voudrais avoir les valeurs moyennes par city des pm10 en france et que l'information ne date pas de plus de deux jours **pour toutes les city ayant une valeur supperieur a 25**

![cat having image](https://media.giphy.com/media/1400Ywo4LFDfSU/giphy.gif)

> solution : `having`

Note:
```
select
  city
  , avg(value) as average
  , pollutant
from
  \`bigquery-public-data.openaq.global_air_quality\`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
group by 
  city, pollutant
having 
  avg(value) > 25
order by 
  average desc
```

---

## Window functions

> demande : je voudrais avoir les valeurs pm10 en france et que l'information ne date pas de plus de deux jours **ainsi que la moyenne nationale, la moyenne de la city en question et la position de cette ville dans le classement des villes les plus polluées**

![cat window function image](https://media.giphy.com/media/26FL8E5N7S8vMxzm8/giphy.gif)

> solution : `window functions!`

Note:
```
select
  location
  , city
  , concat(cast(value as string), " ", unit)
  , pollutant
  , timestamp
  , avg(value) over() as average_country
  , avg(value) over(partition by city) as average_city
  , rank() over(order by value desc) as rank
from
  \`bigquery-public-data.openaq.global_air_quality\`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
order by 
  rank asc
```

---

## Et pour le fun

> demande : je voudrais les avoir...  
\- groupé par city  
\- la position de ce groupe dans le classement des groupes les plus polluées  
\- la valeur moyenne de ce groupe  
\- la plus petite et la plus grande valeur de e groupe  
\- la variation par rapport au groupe précédent  
\- et combien de fois ce groupe est plus pollué que le moins pollué    

![cat jump image](https://media.giphy.com/media/9eesIL98bUali/giphy.gif)

Note:
```
select
  rank() over(order by avg(value) desc) as rank
  , city
  , avg(value) as avergage
  , [min(value), max(value)] as min_max
  , concat(
    '+'
    , cast(round((avg(value) - lead(avg(value)) over(order by avg(value) desc)) / avg(value) * 100, 2) as string)
    , '%'
    ) as variance_from_previous
    , concat(
    cast(round((avg(value) - first_value(avg(value)) over(order by avg(value) asc)) / first_value(avg(value)) over(order by avg(value) asc), 2) as string)
    , 'x'
    ) as times_from_first
from
  \`bigquery-public-data.openaq.global_air_quality\`
where
  pollutant = 'pm10' 
  and country='FR' 
  and cast(timestamp as date) > date_sub(current_date, interval 2 DAY)
group by city
order by 
  rank asc
```
