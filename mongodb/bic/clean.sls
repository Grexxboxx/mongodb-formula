##mongodb/bic/clean.sls
# -*- coding: utf-8 -*-
# vim: ft=yaml
{%- from 'mongodb/map.jinja' import mongodb with context %}

  {%- for svc in ('mongosqld',) %}

mongodb bi {{ svc }} cleanup:
  service.dead:
    - name: {{ mongodb.bic[svc]['service'] }}
  file.absent:
    - names:
      - {{ mongodb.bic[svc]['conf']['storage']['dbpath'] }}
      - {{ mongodb.bic[svc]['conf_path'] }}
      - /Library/LaunchAgents/org.mongo.{{ svc }}.plist

  {%- endfor %}

mongodb bi cleanup:
  file.absent:
    - names:
      - {{ mongodb.bic.symlink }}
      - {{ mongodb.prefix }}/{{ mongodb.bic.arcname }}
      - {{ mongodb.dl.tmpdir }}
      - /etc/logrotate.d/mongodb-mongosqld
