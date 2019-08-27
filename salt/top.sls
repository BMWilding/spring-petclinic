base:
  'jenkins':
    - jenkins
    - serveo
  'worker':
    - packages
    - docker
    - docker.network
    - nexus
    - sonarqube
    - jenkins.ssh.worker
