{% macro macros_copy_fact_csv(table_nm) %} 
{% set sql_statement %}
{# delete from {{var ('rawhist_db') }}.{{var ('wrk_schema')}}.{{ table_nm }}; #}
COPY INTO {{var ('rawhist_db') }}.{{var ('wrk_schema')}}.{{ table_nm }} 
FROM (
    SELECT
        $1 AS store_id, -- Replace with actual column mappings from the stage file
        $2 AS store_date,
        $3 AS temperature,
        $4 AS fuel_price,
        $5 AS markdown1,
        $6 AS markdown2,
        $7 AS markdown3,
        $8 AS markdown4,
        $9 AS markdown5,
        $10 AS cpi,
        $11 AS unemployment,
        $12 AS is_holiday,
        CURRENT_TIMESTAMP() AS insert_date
    FROM @{{ var('stage_name') }}/fact/fact.csv
)
FILE_FORMAT = {{ var ('file_format_csv') }}
PURGE={{ var('purge_status') }}
FORCE = TRUE;
{% endset %}
{{ log('Executing SQL: ' ~ sql_statement, info=True) }}
{% do run_query(sql_statement) %}
{{ log('COPY INTO executed for table ' ~ table_nm, info=True) }}

{% endmacro %}