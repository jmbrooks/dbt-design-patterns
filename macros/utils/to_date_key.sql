{% macro to_date_key(column_name, precision='day') -%}

    {%- if precision | lower == 'day' -%}
        (left(try_to_date({{ column_name }}), 4) || substr(try_to_date({{ column_name }}), 6, 2) || right(try_to_date({{ column_name }}), 2))::int
        
    
    {%- elif precision | lower == 'month' -%}
        (left(try_to_date({{ column_name }}), 4) || substr(try_to_date({{ column_name }}), 6, 2))::int

    {%- elif precision | lower == 'quarter' -%}
        case
            when substr(try_to_date({{ column_name }}), 6, 2)::int < 4 then (left(try_to_date({{ column_name }}), 4)::varchar || '01')::int
            when substr(try_to_date({{ column_name }}), 6, 2)::int between 4 and 6 then (left(try_to_date({{ column_name }}), 4)::varchar || '02')::int
            when substr(try_to_date({{ column_name }}), 6, 2)::int between 7 and 9 then (left(try_to_date({{ column_name }}), 4)::varchar || '03')::int
            when substr(try_to_date({{ column_name }}), 6, 2)::int > 9 then (left(try_to_date({{ column_name }}), 4)::varchar || '04')::int
        end   
    
    {%- elif precision | lower == 'year' -%}
        (left(try_to_date({{ column_name }}), 4))::int

    {%- endif -%}

{%- endmacro %}
