{% if pillar['packages'] is defined %}
{% for package in pillar['packages'] %}
install-{{ package }}:
  pkg.installed:
    - name: {{ package }}
{% endfor %}
{% endif %}
