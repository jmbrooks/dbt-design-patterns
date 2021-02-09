{% macro resume_warehouse(do_resume, warehouse) %}
    {% if do_resume == true %}
        alter warehouse {{ warehouse }} resume if suspended
    {% else %}
        show parameters like 'timezone'
    {% endif %}
{% endmacro %}
