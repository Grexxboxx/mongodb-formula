##mongodb/bic/config.sls
# -*- coding: utf-8 -*-
# vim: ft=yaml
{%- from 'mongodb/map.jinja' import mongodb with context %}

  {%- for svc in ('mongosqld',) %}

mongodb bic {{ svc }} logpath:
  file.directory:
    - name: {{ mongodb.bic[svc]['conf']['systemLog']['path'] }}
    - user: {{ mongodb.bic.user }}
    - group: {{ mongodb.bic.group }}
    - dir mode: '0775'
    - makedirs: True
    - recurse:
      - user
      - group

mongodb bic {{ svc }} datapath:
  file.directory:
    - name: {{ mongodb.bic[svc]['conf']['storage']['dbpath'] }}
    - user: {{ mongodb.bic.user }}
    - group: {{ mongodb.bic.group }}
    - dir mode: '0775'
    - makedirs: True
    - recurse:
      - user
      - group

mongodb bic {{ svc }} config:
  file.managed:
    - name: {{ mongodb.bic[svc]['conf_path'] }}
    - source: salt://mongodb/files/service.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - context:
        service: {{ svc }}
        component: 'bic'

mongodb bic {{ svc }} logrotate add:
  file.managed:
    - name: /etc/logrotate.d/mongodb_{{ svc }}
    - unless: ls /etc/logrotate.d/mongodb_{{ svc }}
    - user: root
    - group: root
    - mode: '0440'
    - source: salt://mongodb/files/logrotate.jinja
    - context:
        pattern: {{ mongodb.bic[svc]['conf']['systemLog']['path']/{{ svc }}.log }}
        pidfile: {{ mongodb['lockdir'] ~ '/' ~ svc ~ '.lock' }}
        days: 7

mongodb bic {{ svc }} service:
  file.managed:
    - name: /Library/LaunchAgents/org.mongo.mongodb.{{ svc }}.plist
    - source: salt://mongodb/files/{{ svc }}.plist.jinja
    - mode: '0644'
    - user: root
    - group: wheel
    - template: jinja
    - context:
        plistname: 'org.mongo.mongodb.{{ svc }}'
        binpath: {{ mongodb.bic.symlink  ~ '/bin' }}
        datapath: {{ mongodb.bic[svc]['conf']['storage']['dbpath'] }}
        logpath: {{ mongodb.bic[svc]['conf']['systemLog']['path']/{{ svc }}.log }}
  svc.running:
    - name: {{ mongodb.bic[svc]['service'] }}
    - enable: True
    - watch:
      - file: mongodb bic {{ svc }} config

  {%- endfor %}
