include: 
  - docker

create-sonarqube-container:
  docker_container.running:
    - name: sonar
    - image: 'sonarqube:lts-alpine'
    - port_bindings:
      - 9000:9000
    - networks:
      - liatrionet
