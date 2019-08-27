cmd.run_bg:
  module.run:
{% if pillar['serveo'] is defined %}
    - cmd: ssh -fN -o StrictHostKeyChecking=no -R {{ pillar['serveo']['hostname']}}.serveo.net:443:localhost:8080 serveo.net
{% else %}
    - cmd: ssh -fN -o StrictHostKeyChecking=no -R serveo.net:443:localhost:8080 serveo.net
{% endif %}
    - unless: ps aux | grep serveo.net
