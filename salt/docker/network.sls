{% if pillar['docker']['network'] is defined %}
{% set docker_network_name = pillar['docker']['network']['name'] %}
{% set docker_network_type = pillar['docker']['network']['type'] | default('bridge', true) %}

{{ docker_network_name }}:
  docker_network.present:
    - driver: {{ docker_network_type }} 
{% endif %}
