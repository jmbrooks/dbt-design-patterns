{% macro trim_set_field(column_name) %}
    case
        when left({{ column_name }}, 2) = '{''' or right({{ column_name }}, 2) = '''}' then trim(lower(rtrim(ltrim({{ column_name }}, '{'''), '''}')))
        when left({{ column_name }}, 2) = '[''' or right({{ column_name }}, 2) = ''']' then trim(lower(rtrim(ltrim({{ column_name }}, '['''), ''']')))
        when left({{ column_name }}, 3) = '{[''' or right({{ column_name }}, 3) = ''']}' then trim(lower(rtrim(ltrim({{ column_name }}, '{['''), ''']}')))
        else trim(lower({{ column_name }}))
    end
{% endmacro %}
