##mongodb/server/clean.sls
# -*- coding: utf-8 -*-
# vim: ft=yaml
{%- from 'mongodb/map.jinja' import mongodb with context -%}

  {%- for svc in ('mongod', 'mongos',) %}

mongodb server {{ svc }} cleanup:
  service.dead:
    - name: {{ mongodb.server[svc]['service'] }}
  file.absent:
    - names:
      - {{ mongodb.server[svc]['conf']['storage']['dbpath'] }}
      - {{ mongodb.server[svc]['conf_path'] }}
      - /Library/LaunchAgents/org.mongo.{{ svc }}.plist

  {%- endfor %}

mongodb server cleanup:
  file.absent:
    - names:
      - {{ mongodb.prefix }}/{{ mongodb.server.dirname }}
      - {{ mongodb.server.symlink }}
      - {{ mongodb.dl.tmpdir }}/{{ mongodb.server.arcname }}
      - /etc/logrotate.d/mongodb-mongod
      - /etc/logrotate.d/mongodb-mongos
      - /etc/logrotate.d/mongodb-server
