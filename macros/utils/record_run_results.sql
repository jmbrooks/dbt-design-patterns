{% macro record_run_results(results, result_db='analytics', result_schema='metadata', result_table='dbt_run_history') %}

  {% set query_values = [] %}

  {% if target.role != 'snapshotter' %}
    {% set create_query = "create table if not exists " ~ result_db ~ "." ~ result_schema ~ "." ~ result_table ~ " ( dbt_run_history_id int identity(1,1) not null, target varchar(50), node_id varchar(255), relation_name varchar(255), result_status varchar(255), run_duration_seconds number(18,6), was_error boolean, was_skipped boolean, was_failed_test boolean, was_full_refresh boolean, target_database varchar(50), target_schema varchar(50), virtual_warehouse varchar(50), run_by_role varchar(50), run_by_user varchar(255), threads_count int, materialization varchar(50), resource_type varchar(50), dbt_package_name varchar(50), dbt_version varchar(50), run_completed_at timestamp_tz )" %}
    {% do run_query(create_query) %}
  {% endif %}

  {% for res in results -%}
      {% if res.error and res.error | length > 0 %}
        {% set has_error = true %}
      {% else %}
        {% set has_error = false %}
      {% endif %}

      {% if res.fail and res.fail | length > 0 %}
        {% set has_failure = true %}
      {% else %}
        {% set has_failure = false %}
      {% endif %}

      {% if  flags.FULL_REFRESH and flags.FULL_REFRESH | length > 0 %}
        {% set has_failure = true %}
      {% else %}
        {% set has_failure = false %}
      {% endif %}
      
      {% do query_values.append([
          "('", target.name, "','", res.node.unique_id, "','", res.node.alias, "','", res.status, "',", res.execution_time, "," ~ has_error ~ ",", res.skip, "," ~ has_failure ~ ",", has_failure, ",'", target.database, "','", target.schema, "','", target.warehouse, "','", target.role, "','", target.user, "',", target.threads, ",'", res.node.config.materialized, "','", res.node.resource_type, "','", res.node.package_name, "','", dbt_version, "', current_timestamp)"
        ] | join())
      %}
  {% endfor %}
  {% if query_values | length > 0 %}
      {% set query_start = "insert into " ~ result_db ~ "." ~ result_schema ~ "." ~ result_table ~ " (target, node_id, relation_name, result_status, run_duration_seconds, was_error, was_skipped, was_failed_test, was_full_refresh, target_database, target_schema, virtual_warehouse, run_by_role, run_by_user, threads_count, materialization, resource_type, dbt_package_name, dbt_version, run_completed_at) VALUES " %}
      {% set query_mid = query_values | join(',') %}
      {% set query = [query_start, query_mid] | join() %}
      
      {% set results = run_query(query) %}
      {% do run_query("commit;") %}

  {% endif %}

{% endmacro %}
