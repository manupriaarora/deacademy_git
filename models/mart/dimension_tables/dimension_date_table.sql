{{ config(
    materialized='view',
    schema='walmart_test_mart',
    alias='walmart_date_dim'
) }}

Select * from {{ ref("transform_date_table")}}
