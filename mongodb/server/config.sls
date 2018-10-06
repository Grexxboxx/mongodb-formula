##mongodb/server/config.sls
# -*- coding: utf-8 -*-
# vim: ft=yaml
{%- from 'mongodb/map.jinja' import mongodb with context -%}

mongodb server tools pypip package:
  pkg.installed:
    - name: {{ mongodb.pip }}

mongodb server tools pymongo package:
  pip.installed:
    - name: pymongo
    - reload_modules: True
    - require:
      - pkg: mongodb server tools pypip package

  {%- for svc in ('mongod', 'mongos',) %}

mongodb server {{ svc }} logpath:
  file.directory:
    - name: {{ mongodb.server[svc]['conf']['systemLog']['path'] }}
    - user: {{ mongodb.server.user }}
    - group: {{ mongodb.server.group }}
    - dir mode: '0775'
    - makedirs: True
    - recurse:
      - user
      - group

mongodb server {{ svc }} datapath:
  file.directory:
    - name: {{ mongodb.server[svc]['conf']['storage']['dbpath'] }}
    - user: {{ mongodb.server.user }}
    - group: {{ mongodb.server.group }}
    - dir mode: '0775'
    - makedirs: True
    - recurse:
      - user
      - group

mongodb server {{ svc }} config:
  file.managed:
    - name: {{ mongodb.server[svc]['conf_path'] }}
    - source: salt://mongodb/files/service.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - context:
        service: {{ svc }}
        component: 'server'

mongodb server {{ svc }} logrotate add:
  file.managed:
    - name: /etc/logrotate.d/mongodb_{{ svc }}
    - unless: ls /etc/logrotate.d/mongodb_{{ svc }}
    - user: root
    - group: root
    - mode: '0440'
    - source: salt://mongodb/files/logrotate.jinja
    - context:
        pattern: {{ mongodb.server[svc]['conf']['systemLog']['path']/{{ svc }}.log }}
        pidfile: {{ mongodb['lockdir'] ~ '/' ~ svc ~ '.lock' }}
        days: 7

mongodb server {{ svc }} service:
  file.managed:
    - onlyif: test "`uname`" = "Darwin"
    - name: /Library/LaunchAgents/org.mongo.{{ svc }}.plist
    - source: salt://mongodb/files/mongodb.plist.jinja
    - mode: '0644'
    - user: root
    - group: wheel
    - template: jinja
    - context:
       plistname: 'org.mongo.mongodb.{{ svc }}'
       binpath: {{ mongodb.server.symlink ~ '/bin' }}
       datapath: {{ mongodb.server[svc]['conf']['storage']['dbpath'] }}
       logpath: {{ mongodb.server[svc]['conf']['systemLog']['path']/{{ svc }}.log }}
  svc.running:
    - name: {{ mongodb.server[svc]['service'] }}
    - enable: True
    - watch:
      - file: mongodb server {{ svc }} config

  {%- endif %}
  {%- if mongodb.server.shell.etc_mongorc %}

mongodb server shell etc mongorc add:
  file.managed:
    - name: {{ mongodb.server.shell.etc_mongorc }}
    - unless: test -f mongodb.server.shell.etc.mongorc }}
    - user: {{ mongodb.server.user }}
    - group: {{ mongodb.server.group }}
    - mode: '0644'
    - source: salt://mongodb/files/mongorc.js.jinja

  {%- endif %}
