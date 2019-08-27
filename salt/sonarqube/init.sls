include: 
  - docker

create-sonarqube-container:
  docker_container.running:
    - name: sonar
    - image: 'sonarqube:lts-alpine'
    - port_bindings:
      - 9000:9000
{% if pillar['docker']['network']['name'] is defined %}
{% set docker_network_name = pillar['docker']['network']['name'] %}
    - networks:
      - {{ docker_network_name }}
{% endif %}
