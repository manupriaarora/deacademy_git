{{ config(
    materialized='view',
    schema='walmart_test_staging'
) }}

SELECT
    CAST(STORE_ID AS INTEGER) AS store_id,
    CAST(STORE_DATE AS Date) AS store_date,
    CAST(TEMPERATURE AS DECIMAL(10, 2)) AS temperature,
    CAST(FUEL_PRICE AS DECIMAL(10, 2)) AS fuel_price,
    TRY_CAST(MARKDOWN1 AS DECIMAL(10, 2)) AS markdown1, 
    TRY_CAST(MARKDOWN2 AS DECIMAL(10, 2)) AS markdown2, 
    TRY_CAST(MARKDOWN3 AS DECIMAL(10, 2)) AS markdown3, 
    TRY_CAST(MARKDOWN4 AS DECIMAL(10, 2)) AS markdown4, 
    TRY_CAST(MARKDOWN5 AS DECIMAL(10, 2)) AS markdown5, 
    TRY_CAST(CPI AS DECIMAL(10, 2)) AS cp,
    TRY_CAST(UNEMPLOYMENT AS DECIMAL(10, 2)) AS unemployment,
    is_holiday,
    insert_date
FROM {{ source('source', 'fact') }}

