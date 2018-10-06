##mongodb/server/init.sls
# -*- coding: utf-8 -*-
# vim: ft=yaml

include:
    {%- if mongodb.server.use_archive %}
  - mongodb.server.archive

    {%- else %}
  - mongodb.server.packages

    {%- endif
  - mongodb.server.config
