{% snapshot fact_table_snapshot %}

{{
    config(
        target_schema='walmart_mart',
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
