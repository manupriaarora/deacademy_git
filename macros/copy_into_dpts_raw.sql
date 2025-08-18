{% macro macros_copy_dpts_csv(table_nm) %} 

{# delete from {{var ('rawhist_db') }}.{{var ('wrk_schema')}}.{{ table_nm }}; #}
{% set sql_statement %}
COPY INTO {{var ('rawhist_db') }}.{{var ('wrk_schema')}}.{{ table_nm }} 
FROM (
    SELECT
        $1 AS store_id, -- Replace with actual column mappings from the stage file
        $2 AS department_id,
        $3 AS store_date,
        $4 AS weekly_sales,
        $5 AS is_holiday,
        CURRENT_TIMESTAMP() AS insert_date
    FROM @{{ var('stage_name') }}/departments/department.csv
)
FILE_FORMAT = {{ var ('file_format_csv') }}
PURGE={{ var('purge_status') }}
FORCE = TRUE;
{% endset %}
{{ log('Executing SQL: ' ~ sql_statement, info=True) }}
{% do run_query(sql_statement) %}
{{ log('COPY INTO executed for table ' ~ table_nm, info=True) }}

{% endmacro %}