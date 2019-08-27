# These are required to work
python2-pip:
  pkg.installed

docker-package:
  pip.installed:
    - name: docker
    - ignore_installed: true

# Kinda surprised this works
purge-abandoned-images:
  docker_image.absent:
    - name: <none>

{% if pillar['docker.network'] is defined %}
{% set docker_network_name = pillar['docker.network.name'] | default('internalnet', true) %}
{% set docker_network_type = pillar['docker.network.type'] | default('bridge', true) %}

{{ docker_network_name }}:
  docker_network.present:
    - driver: {{ docker_network_type }} 
    - require: 
      - docker-package

{% endif %}
