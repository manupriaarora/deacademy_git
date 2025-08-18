{{ config(materialized="view", schema="walmart_staging") }}
select
    cast(store_id as integer) as store_id,
    cast(department_id as integer) as dept_id,
    cast(store_date as date) as store_date,
    cast(weekly_sales as decimal(20, 2)) as store_weekly_sales,
    is_holiday,
    insert_date
from {{ source("source", "departments") }}
