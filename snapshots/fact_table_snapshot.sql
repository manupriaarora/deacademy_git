{% snapshot fact_table_snapshot %}

{{
    config(
        target_schema='walmart_test_mart',
        unique_key=['date_id', 'store_id', 'dept_id'],
        strategy='check',
        check_cols=[
            'store_size','store_weekly_sales','fuel_price','temperature','unemployment',
            'cpi','markdown1','markdown2','markdown3','markdown4','markdown5'
        ],
        invalidate_hard_deletes=true
    )
}}

SELECT 
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
    insert_date
    FROM {{ ref('transform_fact_table') }}
{% endsnapshot %}

{# SELECT 
    d_dim.date_id as date_id,
    s_dim.store_id as store_id,
    dpt.dept_id as dept_id,
    s_dim.store_size as store_size,
    dpt.store_weekly_sales as store_weekly_sales,
    f.fuel_price as fuel_price,
    f.temperature as temperature,
    f.unemployment as unemployment,
    f.cp as cpi,
    f.markdown1 as markdown1,
    f.markdown2 as markdown2,
    f.markdown3 as markdown3,
    f.markdown4 as markdown4,
    f.markdown5 as markdown5
FROM {{ source('fact_source', 'staging_departments') }} dpt
JOIN {{ source('fact_dim_source', 'walmart_store_dim') }} s_dim
    ON dpt.store_id = s_dim.store_id
    AND dpt.dept_id = s_dim.dept_id
JOIN {{ source('fact_source', 'staging_fact') }} f
    ON dpt.store_id = f.store_id
    AND dpt.store_date = f.store_date
JOIN {{ source('fact_dim_source', 'walmart_date_dim') }} d_dim
    ON d_dim.date = dpt.store_date #}


