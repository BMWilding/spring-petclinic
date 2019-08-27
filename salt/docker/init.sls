python2-pip:
  pkg.installed

docker-package:
  pip.installed:
    - name: docker
    - ignore_installed: true
    - reload_modules: true

liatrionet:
  docker_network.present:
    - driver: bridge 
    - require: 
      - docker-package
