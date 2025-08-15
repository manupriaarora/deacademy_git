{{ config(
    materialized='table',
    unique_key=['date_id', 'store_id', 'dept_id'],
    schema='walmart_test_staging',
    alias='transform_fact_table'
) }}
-- 1. Latest dimension data
With LatestStores AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY insert_date DESC) AS rn
        FROM {{ ref('stg_stores') }}
    ) t
    WHERE rn = 1
),
LatestDepartments AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY store_id, dept_id, store_date ORDER BY insert_date DESC) AS rn
        FROM {{ ref('stg_departments') }}
    ) t
    WHERE rn = 1
),
-- 2.Use all fact rows, not just the latest
{# AllFact AS (
    SELECT *
    FROM {{ ref('stg_fact') }}
), #}
-- 2. Latest fact data
LatestFact AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY store_id, store_date ORDER BY insert_date DESC) AS rn
        FROM {{ ref('stg_fact') }}
    ) t
    WHERE rn = 1
),
-- 3. Distinct dates for date dimension
DistinctDates AS (
    SELECT DISTINCT store_date, is_holiday
    FROM LatestDepartments
),
-- 4. Assign surrogate key using ROW_NUMBER
DateIdAssociation AS (
    SELECT 
    *,
    ROW_NUMBER() OVER(order by store_date) as date_id
    from DistinctDates
),
-- 5. Join fact with dimension tables
JoinedData AS (
    SELECT
        d_dim.date_id,
        s.store_id,
        d.dept_id,
        s.store_size,
        d.store_weekly_sales,
        f.fuel_price,
        f.temperature,
        f.unemployment,
        f.cp AS cpi,
        f.markdown1,
        f.markdown2,
        f.markdown3,
        f.markdown4,
        f.markdown5,
        f.insert_date
    FROM LatestDepartments d
    JOIN LatestStores s
        ON d.store_id = s.store_id
    JOIN LatestFact f
        ON d.store_id = f.store_id
        AND d.store_date = f.store_date
    JOIN DateIdAssociation d_dim
        ON d_dim.store_date = d.store_date
),
-- 6. Keep only the latest row per key
LatestData AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY store_id, dept_id, date_id ORDER BY insert_date DESC) AS rn
        FROM JoinedData
    ) t
    WHERE rn = 1
)

-- 7. Final output
SELECT *
FROM LatestData
