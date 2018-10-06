##mongodb/bic/archive.sls
# -*- coding: utf-8 -*-
# vim: ft=yaml
{%- from 'mongodb/map.jinja' import mongodb with context -%}

mongodb bic archive {{ mongodb.bic.dirname }} dirs:
  file.directory:
    - names:
      - {{ mongodb.dl.tmpdir }}
      - {{ mongodb.prefix }}/{{ mongodb.bic.dirname }}
    - makedirs: True
    - clean: True

mongodb bic archive {{ mongodb.bic.dirname }} download:
  file.absent:
    - names:
      - {{ mongodb.dl.tmpdir }}/{{ mongodb.bic.arcname }}
      - {{ mongodb.bic.symlink }}
  pkg.installed:
    - names: {{ mongodb.dl.deps }}
  cmd.run:
    - name: curl {{ mongodb.dl.opts }} -o {{ mongodb.dl.tmpdir }}/{{ mongodb.bic.arcname }} {{ mongodb.bic.url }}
        {% if grains['saltversioninfo'] >= [2017, 7, 0] %}
    - retry:
        attempts: {{ mongodb.dl.retries }}
        interval: {{ mongodb.dl.interval }}
        {% endif %}
    - require:
      - mongodb bic archive {{ mongodb.bic.dirname }} dirs

mongodb bic archive {{ mongodb.bic.dirname }} install:
  archive.extracted:
    - source: file://{{ mongodb.dl.tmpdir }}/{{ mongodb.bic.arcname }}
    - name: {{ mongodb.prefix }}/{{ mongodb.bic.dirname }}
    - makedirs: True
    - trim output: True
    - options: {{ mongodb.dl.unpackopts }}
    - enforce toplevel: False
    - source hash: {{ mongodb.bic.url }}.sha256
    - onchanges:
      - mongodb bic archive {{ mongodb.bic.dirname }} download
    - require in:
      - file: mongodb bic archive {{ mongodb.bic.dirname }} install
      - file: mongodb bic archive {{ mongodb.bic.dirname }} bashprofile
      - file: mongodb bic archive {{ mongodb.bic.dirname }} tidyup
  file.symlink:
    - name: {{ mongodb.bic.symlink }}
    - target: {{ mongodb.prefix }}/{{ mongodb.bic.dirname }}
    - force: True

mongodb bic archive {{ mongodb.bic.dirname }} bashprofile:
  file.append:
    - name: {{ mongodb.userhome }}/{{ mongodb.bic.user }}/.bash_profile
    - text: 'export PATH=$PATH:{{ mongodb.bic.symlink }}/bin'
    - onlyif: test -d {{ mongodb.bic.symlink }}/bin
    - unless: grep '{{ mongodb.bic.symlink }}/bin' {{ mongodb.userhome }}/{{ mongodb.bic.user }}/.bash_profile

mongodb bic archive {{ mongodb.bic.dirname }} tidyup:
  file.absent:
    - name: {{ mongodb.dl.tmpdir }}/{{ mongodb.bic.arcname }}

