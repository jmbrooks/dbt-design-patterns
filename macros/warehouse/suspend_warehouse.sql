{% macro suspend_warehouse(do_suspend, warehouse) %}
    {% if do_suspend == true %}
        alter warehouse {{ warehouse }} suspend
    {% else %}
        show parameters like 'timezone'
    {% endif %}
{% endmacro %}
