{{ config(
    materialized='view',
    schema='walmart_mart',
    alias='walmart_fact_table'
) }}
    {# unique_key=['date_id', 'store_id', 'dept_id'], #}

Select 
date_id,
store_id,
dept_id,
store_size,
store_weekly_sales,
fuel_price,
temperature,
unemployment,
cpi,
markdown1,
markdown2,
markdown3,
markdown4,
markdown5,  
insert_date,
COALESCE(dbt_valid_to, CURRENT_TIMESTAMP()) AS update_date,
dbt_valid_from AS vrsn_start_date,
dbt_valid_to AS vrsn_end_date,
CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
FROM {{ ref('fact_table_snapshot') }}

