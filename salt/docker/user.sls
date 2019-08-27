vagrant:
  user.present:
    - shell: /bin/bash
    - home: /home/vagrant
    - groups:
      - docker
