
purge-abandoned-images:
  cmd.run:
{% if pillar['docker']['network']['name'] is defined %}
    - name: docker system prune -af --filter "label!={{ pillar['docker']['network']['name'] }}"
{% else %}
    - name: docker system prune -af 
{% endif %}
    - runas: root

