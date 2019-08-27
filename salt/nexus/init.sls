include:
  - docker

{% if pillar['nexus.remove_local'] %}
disable-local-nexus:
  service.dead:
    - name: nexus
    - onlyif: 
      - test -f /etc/rc.d/init.d/nexus

  file.directory:
    - name: /var/lib/nexus
    - clean: true
    - onlyif: 
      - test -d /var/lib/nexus

# Nuke the old one to prevent conflicts
remove-old-files:
  file.directory:
    - name: /var/lib/sonatype-work
    - clean: true
    - onlyif: 
      - test -d /var/lib/sonatype-work
{% endif %}

nexus-docker:
  docker_container.running:
    - name: nexus
    - image: docker.io/sonatype/nexus
    - port_bindings:
      - 8081:8081
{% if pillar['docker.network.name'] is defined %}
{% set docker_network_name = pillar['docker.network.name'] %}
    - networks:
      - {{ docker_network_name }}
    - require:
      - {{ docker_network_name }}
{% endif %}
