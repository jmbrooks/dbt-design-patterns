{% macro create_lookml_view(model_name, alias='none', database='none', schema='none', view_label='none') -%}

    {% set lookml_view=[] %}
    {% set relation=ref(model_name) %}

    {% if alias != 'none' %}
        {% set table_name = alias %}
    {% else %}
        {% set table_name = relation.identifier %}
    {% endif %}

    {% if database != 'none' %}
        {% set db_name = database %}
    {% else %}
        {% set db_name = relation.database %}
    {% endif %}

    {% if schema != 'none' %}
        {% set schema_name = schema %}
    {% else %}
        {% set schema_name = relation.schema %}
    {% endif %}

    -- First, fetch column descriptions from Snowflake information schema
    {% set query = "select comment from " ~ db_name ~ ".information_schema.columns where table_schema = '" ~ schema_name | upper ~ "' and table_name = '" ~ table_name | upper ~ "' order by ordinal_position" %}
    {{ log(query, info=True) }}
    {% set results = run_query(query) %}

    {% if execute %}
        {% set results_descriptions = results.columns[0].values() %}
    {% else %}
        {% set results_descriptions = [] %}
    {% endif %}
    
    {{ log(results_descriptions) }}

    -- Next, create the view header
    {% do lookml_view.append('view: ' ~ table_name | lower ~ ' {') %}

    {% if view_label != 'none' %}

        {% set label = view_label %}
        {% do lookml_view.append('  label: "' ~ label ~ '"') %}

    {% endif %}

    {% do lookml_view.append('  sql_table_name: ' ~ db_name ~ '.' ~ schema_name ~ '.' ~ relation.identifier ~ ' ;;') %}

    -- Create dimensions
    {% do lookml_view.append('') %}
    {% do lookml_view.append('  # Dimensions') %}
    {% do lookml_view.append('') %}

    {%- set columns = adapter.get_columns_in_relation(relation) -%}

    {% set set_detail_fields=[] %}

    {% for column in columns %}

        {% set column_description = results_descriptions[loop.index - 1] %}
        {% if column_description is not none %}
            {% set description = column_description %}
        {% else %}
            {% set description = '' %}
        {% endif %}

        {% do set_detail_fields.append(column.name) %}
        
        {% set dimension_declaration = 'dimension: ' %}

        {% if 'num' in column.data_type | lower %}
            {% set dimension_type = 'number' %}
        {% elif 'bool' in column.data_type | lower %}
            {% set dimension_type = 'yesno' %}
        {% elif 'time' in column.data_type | lower %}
            {% set dimension_type = 'time' %}
            {% set dimension_declaration = 'dimension_group: ' %}
        {% elif 'date' in column.data_type | lower %}
            {% set dimension_type = 'date' %}
        {% else %}
            {% set dimension_type = 'string' %}
        {% endif %}

        {% do lookml_view.append('  ' ~ dimension_declaration ~ column.name | lower ~ ' {') %}
        {% do lookml_view.append('    description: "' ~ description ~ '"') %}
        {% do lookml_view.append('    type: ' ~ dimension_type) %}

        {% if dimension_declaration == 'dimension_group: ' %}
            {% do lookml_view.append('    timeframes: [') %}
            {% do lookml_view.append('      raw,') %}
            {% do lookml_view.append('      time,') %}
            {% do lookml_view.append('      date,') %}
            {% do lookml_view.append('      week,') %}
            {% do lookml_view.append('      month,') %}
            {% do lookml_view.append('      quarter,') %}
            {% do lookml_view.append('      year') %}
            {% do lookml_view.append('    ]') %}
        {% endif %}

        {% do lookml_view.append('    sql: ${TABLE}.' ~ column.name | lower ~ ' ;;') %}

        {% do lookml_view.append('  }') %}
        {% do lookml_view.append('') %}

    {% endfor %}

    -- Create measures
    {% do lookml_view.append('  # Measures') %}
    {% do lookml_view.append('') %}
    {% do lookml_view.append('  measure: count {') %}
    {% do lookml_view.append('    hidden: yes') %}
    {% do lookml_view.append('    type: count') %}
    {% do lookml_view.append('    drill_fields: [detail*]') %}
    {% do lookml_view.append('  }') %}

    -- Create sets placeholder
    {% set set_fields = set_detail_fields | join (',\n      ') %}

    {% do lookml_view.append('') %}
    {% do lookml_view.append('  # Sets') %}
    {% do lookml_view.append('') %}
    {% do lookml_view.append('  set: detail {') %}
    {% do lookml_view.append('    fields: [') %}
    {% do lookml_view.append('      ' ~ set_fields | lower) %}
    {% do lookml_view.append('    ]') %}
    {% do lookml_view.append('  }') %}

    -- End of view file
    {% do lookml_view.append('}') %}

    {% if execute %}

        {% set joined = lookml_view | join ('\n') %}
        {{ log(joined, info=True) }}
        {% do return(joined) %}

    {% endif %}

{%- endmacro %}
