jenkinsworker:
  user.present:
    - shell: /bin/bash
    - home: /home/jenkinsworker
    - password: 'hardlyworking'
    - groups:
      - docker

# FYI Don't do this in prod
sshd:
  service.running:
    - enable: True
    - watch:
      - /etc/ssh/sshd_config

/etc/ssh/sshd_config:
  file.managed:
    - source: salt://jenkins/files/sshd_config
