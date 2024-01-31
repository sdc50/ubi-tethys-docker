{% set TETHYS_HOME = salt['environ.get']('TETHYS_HOME') %}
{% set CONDA_ENV_NAME = salt['environ.get']('CONDA_ENV_NAME') %}
{% set CONDA_HOME = salt['environ.get']('CONDA_HOME') %}
{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}

Persist_Portal_Config_Post_App:
  file.rename:
    - source: {{ TETHYS_HOME }}/portal_config.yml
    - name: {{ TETHYS_PERSIST }}/portal_config.yml
    - unless: /bin/bash -c "[ -f "${TETHYS_PERSIST}/portal_config.yml" ];"

Restore_Portal_Config_Post_App:
  file.symlink:
    - name: {{ TETHYS_HOME }}/portal_config.yml
    - target: {{ TETHYS_PERSIST }}/portal_config.yml
    - force: True

Chown_Portal_Config_Post_App:
  cmd.run:
    - name: chown apache:apache {{ TETHYS_HOME }}/portal_config.yml
    - shell: /bin/bash

Collect_Static:
  cmd.run:
    - name: tethys manage collectstatic --noinput
    - shell: /bin/bash

Collect_Workspaces:
  cmd.run:
    - name: tethys manage collectworkspaces
    - shell: /bin/bash

Persist_Apache_Config_Post_App:
  file.rename:
    - source: {{ TETHYS_HOME }}/tethys_apache.conf
    - name: {{ TETHYS_PERSIST }}/tethys_apache.conf
    - force: True

Link_Apache_Config_Post_App:
  file.symlink:
    - name: /etc/httpd/conf.d/tethys_apache.conf
    - target: {{ TETHYS_PERSIST }}/tethys_apache.conf
    - force: True

Persist_Apache_Supervisor_Post_App:
  file.rename:
    - source: {{ TETHYS_HOME }}/apache_supervisord.conf
    - name: {{ TETHYS_PERSIST }}/apache_supervisord.conf
    - unless: /bin/bash -c "[ -f "${TETHYS_PERSIST}/apache_supervisord.conf" ];"

Link_Apache_Supervisor_Post_App:
  file.symlink:
    - name: /etc/supervisord.d/apache_supervisord.ini
    - target: {{ TETHYS_PERSIST }}/apache_supervisord.conf
    - force: True

Persist_ASGI_Supervisor_Post_App:
  file.rename:
    - source: {{ TETHYS_HOME }}/asgi_supervisord.conf
    - name: {{ TETHYS_PERSIST }}/asgi_supervisord.conf
    - unless: /bin/bash -c "[ -f "${TETHYS_PERSIST}/asgi_supervisord.conf" ];"

Link_ASGI_Supervisor_Post_App:
  file.symlink:
    - name: /etc/supervisord.d/asgi_supervisord.ini
    - target: {{ TETHYS_PERSIST }}/asgi_supervisord.conf
    - force: True
