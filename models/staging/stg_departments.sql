{{ config(
    materialized='view',
    schema='walmart_test_staging'
) }}
Select
    CAST(STORE_ID AS INTEGER) AS store_id, 
    CAST(DEPARTMENT_ID AS INTEGER) AS dept_id,
    CAST(STORE_DATE AS DATE) AS store_date,
    CAST(WEEKLY_SALES AS DECIMAL(20, 2)) AS store_weekly_sales,
    IS_HOLIDAY,
    insert_date
from {{ source('source', 'departments') }}

