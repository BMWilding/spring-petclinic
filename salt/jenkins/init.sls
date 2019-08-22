
include:
{%- if pillar.jenkins.master is defined %}
- jenkins.master
{%- endif %}
{%- if pillar.jenkins.slave is defined %}
- jenkins.slave
{%- endif %}
{%- if pillar.jenkins.job_builder is defined %}
- jenkins.job_builder
{%- endif %}
{%- if pillar.jenkins.client is defined %}
- jenkins.client
{%- endif %}

upgrade-jenkins:
  pkg.latest:
    - name: jenkins
    - version: '2.176.2'
    - refresh: true
