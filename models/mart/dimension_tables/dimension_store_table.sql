{{ config(
    materialized='view',
    schema='walmart_test_mart',
    alias='walmart_store_dim'
) }}

Select * from {{ ref("transform_store_table")}}