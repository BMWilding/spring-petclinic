include:
  - docker

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

remove-old-files:
  file.directory:
    - name: /var/lib/sonatype-work
    - clean: true
    - onlyif: 
      - test -d /var/lib/sonatype-work

nexus-docker:
  docker_container.running:
    - name: nexus
    - image: docker.io/sonatype/nexus
    - networks:
      - liatrionet     
    - port_bindings:
      - 8081:8081
    - require:
      - liatrionet
