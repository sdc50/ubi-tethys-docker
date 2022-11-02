{% set STATIC_ROOT = salt['environ.get']('STATIC_ROOT') %}
{% set WORKSPACE_ROOT = salt['environ.get']('WORKSPACE_ROOT') %}
{% set TETHYS_HOME = salt['environ.get']('TETHYS_HOME') %}
{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}

Activate_Tethys_Environment_Pre_Tethys:
  cmd.run:
    - name: /usr/local/bin/_entrypoint.sh
    - shell: /bin/bash

Create_Static_Root_On_Mounted_Pre_Tethys:
  cmd.run:
    - name: mkdir -p {{ STATIC_ROOT }}
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -d "${STATIC_ROOT}" ];"

Create_Workspace_Root_On_Mounted_Pre_Tethys:
  cmd.run:
    - name: mkdir -p {{ WORKSPACE_ROOT }}
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -d "${WORKSPACE_ROOT}" ];"

Chown_Static_Workspaces_On_Mounted_Pre_Tethys:
  cmd.run:
    - name: >
        export APACHE_USER=$(grep 'User ' /etc/httpd/conf/httpd.conf | awk '{print $2}') ;
        find {{ WORKSPACE_ROOT }} ! -user ${APACHE_USER} -print0 | xargs -0 -I{} chown ${APACHE_USER}: {} ;
        find {{ STATIC_ROOT }} ! -user ${APACHE_USER} -print0 | xargs -0 -I{} chown ${APACHE_USER}: {}
    - shell: /bin/bash
