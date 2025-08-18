{{ config(
    materialized='view',
    schema='walmart_staging'
) }}

SELECT
    CAST(STORE_ID AS INTEGER) AS store_id, 
    store_type,
    CAST(store_size AS INTEGER) AS store_size,
    insert_date
FROM {{ source('source', 'stores') }}

