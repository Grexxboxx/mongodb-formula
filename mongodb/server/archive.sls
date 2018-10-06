##mongodb/server/archive.sls
# -*- coding: utf-8 -*-
# vim: ft=yaml
{%- from 'mongodb/map.jinja' import mongodb with context -%}

mongodb server archive {{ mongodb.server.dirname }} dirs:
  file.directory:
    - names:
      - {{ mongodb.dl.tmpdir }}
      - {{ mongodb.prefix }}
    - makedirs: True
    - clean: True

mongodb server archive {{ mongodb.server.dirname }} download:
  file.absent:
    - names:
      - {{ mongodb.dl.tmpdir }}/{{ mongodb.server.arcname }}
      - {{ mongodb.prefix }}/{{ mongodb.server.dirname }}
  pkg.installed:
    - names: {{ mongodb.dl.deps }}
  cmd.run:
    - name: curl {{ mongodb.dl.opts }} -o {{ mongodb.dl.tmpdir }}/{{ mongodb.server.arcname }} {{ mongodb.server.url }}
        {% if grains['saltversioninfo'] >= [2017, 7, 0] %}
    - retry:
        attempts: {{ mongodb.dl.retries }}
        interval: {{ mongodb.dl.interval }}
        {% endif %}
    - require:
      - mongodb server archive {{ mongodb.server.dirname }} dirs

mongodb server archive {{ mongodb.server.dirname }} install:
  archive.extracted:
    - source: file://{{ mongodb.dl.tmpdir }}/{{ mongodb.server.arcname }}
    - name: {{ mongodb.prefix }}/{{ mongodb.server.dirname }}
    - makedirs: True
    - trim output: True
    - options: {{ mongodb.dl.unpackopts }}
    - enforce toplevel: False
    - source hash: {{ mongodb.server.url }}.sha256
    - onchanges:
      - mongodb server archive {{ mongodb.server.dirname }} download
    - require in:
      - file: mongodb server archive {{ mongodb.server.dirname }} install
      - file: mongodb server archive {{ mongodb.server.dirname }} bashprofile
      - file: mongodb server archive {{ mongodb.server.dirname }} tidyup
  file.server.symlink:
    - name: {{ mongodb.server.symlink }}
    - target: {{ mongodb.prefix }}/{{ mongodb.server.dirname }}
    - force: True

mongodb server archive {{ mongodb.server.dirname }} bashprofile:
  file.append:
    - name: {{ mongodb.userhome }}/{{ mongodb.server.user }}/.bash_profile
    - text: 'export PATH=$PATH:{{ mongodb.server.symlink }}/bin'
    - onlyif: test -d {{ mongodb.server.symlink }}/bin
    - unless: grep '{{ mongodb.server.symlink }}/bin' {{ mongodb.userhome }}/{{ mongodb.server.user }}/.bash_profile

mongodb server archive {{ mongodb.server.dirname }} tidyup:
  file.absent:
    - name: {{ mongodb.dl.tmpdir }}/{{ mongodb.server.arcname }}

