{{ config(
    materialized='incremental',
    unique_key='date_id',
    schema='walmart_staging',
    alias='transform_date_dim',
    incremental_strategy='merge',
    pre_hook="{{ macros_copy_dpts_csv('DEPARTMENTS') }}"
) }}
-- 1. Get distinct dates
With DistinctDates as (
Select DISTINCT
    store_date,
    IS_HOLIDAY,
    insert_date
from {{ ref('stg_departments') }}
),
-- 2. Assign a surrogate key for the date

-- MD5(TO_VARCHAR(store_date)) AS date_id a better approach than ROW NUMBER
DateIdAssociation AS (
    SELECT 
    *,
    ROW_NUMBER() OVER(order by store_date) as date_id
    from DistinctDates
),
-- 3. Add insert/update timestamps
SourceData AS (
    SELECT
        date_id,
        TO_DATE(store_date) AS store_date,
        is_holiday,
        insert_date,
        CURRENT_TIMESTAMP() AS update_date
    FROM DateIdAssociation
),
-- 4. Merge with target (for incremental loads)
MergedData AS (
    SELECT
        s.date_id,
        s.store_date,
        s.is_holiday,
        {% if is_incremental() %}
            COALESCE(t.insert_date, s.insert_date) AS insert_date,
            CASE
                WHEN t.is_holiday IS DISTINCT FROM s.is_holiday 
                THEN CURRENT_TIMESTAMP()
                ELSE COALESCE(t.update_date, s.update_date)
            END AS update_date
        {% else %}
            s.insert_date,
            s.update_date
        {% endif %}
    FROM SourceData AS s
    {% if is_incremental() %}
    LEFT JOIN {{ this }} AS t
        ON s.date_id = t.date_id
    {% endif %}
),

-- 5. Keep only the most recent update per store_date
RankedData AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY store_date
            ORDER BY update_date DESC
        ) AS rn
    FROM MergedData
)

-- Final output
SELECT
    date_id,
    store_date,
    is_holiday,
    insert_date,
    update_date
FROM RankedData
WHERE rn = 1
