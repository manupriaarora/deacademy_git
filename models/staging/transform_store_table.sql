{{ config(
    materialized='incremental',
    unique_key=['store_id', 'dept_id'],
    schema='walmart_test_staging',
    alias='transform_store_dim' ,
    incremental_strategy='merge'
) }}
-- 1. Base source data
With sourceData as (
    Select DISTINCT
    d.store_id,
    d.dept_id, 
    s.store_type,
    s.store_size,
    d.insert_date,
    CURRENT_TIMESTAMP() AS update_date
FROM {{ ref('stg_departments') }} AS d
JOIN    {{ ref('stg_stores') }} AS s
on s.store_id = d.store_id
),
-- 2. Preserve insert date and update only if values change
CombinedData as (
    SELECT
    source.store_id,
    source.dept_id,
    source.store_type,
    source.store_size,
    -- Keep original insert date if row exists
    {% if is_incremental() %}
        COALESCE(target.insert_date, source.insert_date) AS insert_date,
    {% else %}
        source.insert_date AS insert_date,
    {% endif %}
     -- Only update timestamp if something actually changed
    {% if is_incremental() %}
        case 
            when target.store_type is distinct from source.store_type
              or target.store_size is distinct from source.store_size
            then current_timestamp()
            else COALESCE(target.update_date, source.update_date)
        end as update_date
    {% else %}
        source.update_date as update_date
    {% endif %}
FROM sourceData as source
{% if is_incremental() %}
LEFT JOIN {{ this }} AS target
    ON source.store_id = target.store_id
    AND source.dept_id = target.dept_id
{% endif %}
), 
-- 3. Keep only the latest version per store+dept
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY store_id, dept_id
               ORDER BY update_date DESC
           ) AS rn
    FROM CombinedData
)

-- 4. Final output
SELECT
    store_id,
    dept_id,
    store_type,
    store_size,
    insert_date,
    update_date
FROM ranked
WHERE rn = 1
