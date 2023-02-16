{% set DEBUG = salt['environ.get']('DEBUG') %}
{% set ALLOWED_HOSTS = salt['environ.get']('ALLOWED_HOSTS') %}
{% set CONDA_ENV_NAME = salt['environ.get']('CONDA_ENV_NAME') %}
{% set CONDA_HOME = salt['environ.get']('CONDA_HOME') %}
{% set APACHE_USER = salt['environ.get']('APACHE_USER') %}
{% set CLIENT_MAX_BODY_SIZE = salt['environ.get']('CLIENT_MAX_BODY_SIZE') %}
{% set ASGI_PROCESSES = salt['environ.get']('ASGI_PROCESSES') %}
{% set TETHYS_BIN_DIR = [CONDA_HOME, "/envs/", CONDA_ENV_NAME, "/bin"]|join %}
{% set TETHYS_DB_NAME = salt['environ.get']('TETHYS_DB_NAME') %}
{% set TETHYS_DB_HOST = salt['environ.get']('TETHYS_DB_HOST') %}
{% set TETHYS_DB_PASSWORD = salt['environ.get']('TETHYS_DB_PASSWORD') %}
{% set POSTGRES_PASSWORD = salt['environ.get']('POSTGRES_PASSWORD') %}
{% set TETHYS_DB_PORT = salt['environ.get']('TETHYS_DB_PORT') %}
{% set TETHYS_DB_ENGINE = salt['environ.get']('TETHYS_DB_ENGINE') %}
{% set TETHYS_DB_OPTIONS = salt['environ.get']('TETHYS_DB_OPTIONS') %}
{% set TETHYS_DB_USERNAME = salt['environ.get']('TETHYS_DB_USERNAME') %}
{% set TETHYS_HOME = salt['environ.get']('TETHYS_HOME') %}
{% set TETHYS_PORT = salt['environ.get']('TETHYS_PORT') %}
{% set SKIP_DB_SETUP = salt['environ.get']('SKIP_DB_SETUP') %}
{% set BYPASS_TETHYS_HOME_PAGE = salt['environ.get']('BYPASS_TETHYS_HOME_PAGE') %}
{% set USE_SSL = salt['environ.get']('USE_SSL') %}
{% set APACHE_SSL_CERT_FILE = salt['environ.get']('APACHE_SSL_CERT_FILE') %}
{% set APACHE_SSL_KEY_FILE = salt['environ.get']('APACHE_SSL_KEY_FILE') %}
{% set RUN_PROXY_SERVER_AS_USER = salt['environ.get']('RUN_PROXY_SERVER_AS_USER') %}
{% set PROXY_SERVER_PORT = salt['environ.get']('PROXY_SERVER_PORT') %}
{% set PROXY_SERVER_ADDITIONAL_DIRECTIVES = salt['environ.get']('PROXY_SERVER_ADDITIONAL_DIRECTIVES') %}
{% set OTHER_SETTINGS = salt['environ.get']('OTHER_SETTINGS') %}
{% set TETHYS_DB_SUPERUSER = salt['environ.get']('TETHYS_DB_SUPERUSER') %}
{% set TETHYS_DB_SUPERUSER_PASS = salt['environ.get']('TETHYS_DB_SUPERUSER_PASS') %}
{% set PORTAL_SUPERUSER_NAME = salt['environ.get']('PORTAL_SUPERUSER_NAME') %}
{% set PORTAL_SUPERUSER_EMAIL = salt['environ.get']('PORTAL_SUPERUSER_EMAIL') %}
{% set PORTAL_SUPERUSER_PASSWORD = salt['environ.get']('PORTAL_SUPERUSER_PASSWORD') %}
{% set ADD_DJANGO_APPS = salt['environ.get']('ADD_DJANGO_APPS') %}
{% set SESSION_WARN = salt['environ.get']('SESSION_WARN') %}
{% set SESSION_EXPIRE = salt['environ.get']('SESSION_EXPIRE') %}
{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set REGISTER_CONTROLLER = salt['environ.get']('REGISTER_CONTROLLER') %}
{% set STATICFILES_USE_NPM = salt['environ.get']('STATICFILES_USE_NPM') %}
{% set STATIC_ROOT = salt['environ.get']('STATIC_ROOT') %}
{% set WORKSPACE_ROOT = salt['environ.get']('WORKSPACE_ROOT') %}
{% set QUOTA_HANDLERS = salt['environ.get']('QUOTA_HANDLERS') %}
{% set DJANGO_ANALYTICAL = salt['environ.get']('DJANGO_ANALYTICAL') %}
{% set ADD_BACKENDS = salt['environ.get']('ADD_BACKENDS') %}
{% set OAUTH_OPTIONS = salt['environ.get']('OAUTH_OPTIONS') %}
{% set CHANNEL_LAYERS_BACKEND = salt['environ.get']('CHANNEL_LAYERS_BACKEND') %}
{% set CHANNEL_LAYERS_CONFIG = salt['environ.get']('CHANNEL_LAYERS_CONFIG') %}
{% if salt['environ.get']('RECAPTCHA_PRIVATE_KEY') %}
{% set RECAPTCHA_PRIVATE_KEY = salt['environ.get']('RECAPTCHA_PRIVATE_KEY') %}
{% else %}
{% set RECAPTCHA_PRIVATE_KEY = "''" %}
{% endif %}
{% if salt['environ.get']('RECAPTCHA_PUBLIC_KEY') %}
{% set RECAPTCHA_PUBLIC_KEY = salt['environ.get']('RECAPTCHA_PUBLIC_KEY') %}
{% else %}
{% set RECAPTCHA_PUBLIC_KEY = "''" %}
{% endif %}

{% set TETHYS_SITE_VAR_LIST = ['SITE_TITLE', 'FAVICON', 'BRAND_TEXT', 'BRAND_IMAGE', 'BRAND_IMAGE_HEIGHT',
                               'BRAND_IMAGE_WIDTH', 'BRAND_IMAGE_PADDING', 'APPS_LIBRARY_TITLE', 'PRIMARY_COLOR',
                               'SECONDARY_COLOR', 'PRIMARY_TEXT_COLOR', 'PRIMARY_TEXT_HOVER_COLOR',
                               'SECONDARY_TEXT_COLOR', 'SECONDARY_TEXT_HOVER_COLOR', 'BACKGROUND_COLOR',
                               'FOOTER_COPYRIGHT', 'HERO_TEXT', 'BLURB_TEXT', 'FEATURE_1_HEADING', 'FEATURE_1_BODY',
                               'FEATURE_1_IMAGE', 'FEATURE_2_HEADING', 'FEATURE_2_BODY', 'FEATURE_2_IMAGE',
                               'FEATURE_3_HEADING', 'FEATURE_3_BODY', 'FEATURE_3_IMAGE', 'CALL_TO_ACTION',
                               'CALL_TO_ACTION_BUTTON', 'PORTAL_BASE_CSS', 'HOME_PAGE_CSS', 'APPS_LIBRARY_CSS',
                               'ACCOUNTS_BASE_CSS', 'LOGIN_CSS', 'REGISTER_CSS', 'USER_BASE_CSS', 'HOME_PAGE_TEMPLATE',
                               'APPS_LIBRARY_TEMPLATE', 'LOGIN_PAGE_TEMPLATE', 'REGISTER_PAGE_TEMPLATE',
                               'USER_PAGE_TEMPLATE', 'USER_SETTINGS_PAGE_TEMPLATE'] %}

{% set TETHYS_SITE_CONTENT_LIST = [] %}

{% for ARG in TETHYS_SITE_VAR_LIST %}
  {% if salt['environ.get'](ARG) %}
    {% set ARG_KEY = ['--', ARG.replace('_', '-')|lower]|join %}
    {% set CONTENT = [ARG_KEY, salt['environ.get'](ARG)|quote]|join(' ') %}
    {% do TETHYS_SITE_CONTENT_LIST.append(CONTENT) %}
  {% endif %}
{% endfor %}

{% set TETHYS_SITE_CONTENT = TETHYS_SITE_CONTENT_LIST|join(' ') %}



Generate_Tethys_Settings_TethysCore:
  cmd.run:
    - name: >
        tethys settings
        --set DEBUG {{ DEBUG }}
        --set ALLOWED_HOSTS {{ ALLOWED_HOSTS }}
        --set DATABASES.default.NAME {{ TETHYS_DB_NAME }}
        --set DATABASES.default.USER {{ TETHYS_DB_USERNAME }}
        --set DATABASES.default.PASSWORD {{ TETHYS_DB_PASSWORD }}
        --set DATABASES.default.HOST {{ TETHYS_DB_HOST }}
        --set DATABASES.default.PORT {{ TETHYS_DB_PORT }}
        --set DATABASES.default.ENGINE {{ TETHYS_DB_ENGINE }}
        {%- if TETHYS_DB_OPTIONS %}
        --set DATABASES.default.OPTIONS {{ TETHYS_DB_OPTIONS }}
        {%- endif %}
        --set INSTALLED_APPS {{ ADD_DJANGO_APPS }}
        --set SESSION_CONFIG.SECURITY_WARN_AFTER {{ SESSION_WARN }}
        --set SESSION_CONFIG.SECURITY_EXPIRE_AFTER {{ SESSION_EXPIRE }}
        --set TETHYS_PORTAL_CONFIG.STATICFILES_USE_NPM {{ STATICFILES_USE_NPM }}
        --set TETHYS_PORTAL_CONFIG.STATIC_ROOT {{ STATIC_ROOT }}
        --set TETHYS_PORTAL_CONFIG.TETHYS_WORKSPACES_ROOT {{ WORKSPACE_ROOT }}
        --set TETHYS_PORTAL_CONFIG.BYPASS_TETHYS_HOME_PAGE {{ BYPASS_TETHYS_HOME_PAGE }}
        --set RESOURCE_QUOTA_HANDLERS {{ QUOTA_HANDLERS }}
        --set ANALYTICS_CONFIG {{ DJANGO_ANALYTICAL }}
        --set AUTHENTICATION_BACKENDS {{ ADD_BACKENDS }}
        --set OAUTH_CONFIG {{ OAUTH_OPTIONS }}
        --set CHANNEL_LAYERS.default.BACKEND {{ CHANNEL_LAYERS_BACKEND }}
        --set CHANNEL_LAYERS.default.CONFIG {{ CHANNEL_LAYERS_CONFIG }}
        --set CAPTCHA_CONFIG.RECAPTCHA_PRIVATE_KEY {{ RECAPTCHA_PRIVATE_KEY }}
        --set CAPTCHA_CONFIG.RECAPTCHA_PUBLIC_KEY {{ RECAPTCHA_PUBLIC_KEY }}
        {{ OTHER_SETTINGS }}
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ];"


Generate_Package_JSON_TethysCore:
  cmd.run:
    - name: >
        micromamba install -c conda-forge nodejs -y
        && tethys gen package_json
        && npm audit fix
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ] || [ "$STATICFILES_USE_NPM" = false ];"

Generate_Apache_Settings_TethysCore:
  cmd.run:
    - name: >
        tethys gen apache
        {%- if USE_SSL %}
        --ssl
        --ssl-cert-path {{ APACHE_SSL_CERT_FILE }}
        --ssl-key-path {{ APACHE_SSL_KEY_FILE }}
        {%- endif %}
        --tethys-port {{ TETHYS_PORT }}
        {%- if PROXY_SERVER_PORT %}
        --web-server-port {{ PROXY_SERVER_PORT }}
        {%- endif %}
        --ip-address $(sed -n '$p'  /etc/hosts | awk '{print $1}')
        --overwrite
        {{ PROXY_SERVER_ADDITIONAL_DIRECTIVES }}
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ];"

Generate_SSL_Certificate_Key_Pair_TethysCore:
  cmd.run:
    - name: >
        openssl req
        -newkey rsa:2048
        -keyout {{ APACHE_SSL_KEY_FILE }}
        -x509
        -days 365
        -out {{ APACHE_SSL_CERT_FILE }}
        -nodes
        -subj "/C=US/ST=UT/L=Provo/O=Tethys Foundation/CN=localhost"
        && chown {{ APACHE_USER }}: {{ APACHE_SSL_KEY_FILE }} {{ APACHE_SSL_CERT_FILE }}
    - unless: /bin/bash -c "[ {{ USE_SSL }} == false ] || ([ -f {{ APACHE_SSL_CERT_FILE }} ] && [ -f {{ APACHE_SSL_KEY_FILE }} ]);"

Generate_Apache_Service_TethysCore:
  cmd.run:
    - name: tethys gen apache_service --overwrite --run-as-user {{ RUN_PROXY_SERVER_AS_USER }}
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ];"

Generate_ASGI_Service_TethysCore:
  cmd.run:
    - name: >
        tethys gen asgi_service
        --asgi-processes {{ ASGI_PROCESSES }}
        --conda-prefix {{ CONDA_HOME }}/envs/{{ CONDA_ENV_NAME }}
        --micromamba
        --overwrite
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ];"

/run/asgi:
  file.directory:
    - user: {{ APACHE_USER }}
    - group: {{ APACHE_USER }}
    - mode: 755
    - makedirs: True

/var/log/tethys/tethys.log:
  file.managed:
    - user: {{ APACHE_USER }}
    - replace: False
    - makedirs: True

Create_Database_User_and_SuperUser_TethysCore:
  cmd.run:
    - name: >
        PGPASSWORD="{{ POSTGRES_PASSWORD }}" tethys db create
        -n {{ TETHYS_DB_USERNAME }}
        -p {{ TETHYS_DB_PASSWORD }}
        -N {{ TETHYS_DB_SUPERUSER }}
        -P {{ TETHYS_DB_SUPERUSER_PASS }}
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ] || [ "$SKIP_DB_SETUP" = true ];"

Migrate_Database_TethysCore:
  cmd.run:
    - name: >
        tethys db migrate
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ] || [ "$SKIP_DB_SETUP" = true ];"

Create_Database_Portal_SuperUser_TethysCore:
  cmd.run:
    - name: >
        tethys db createsuperuser
        {%- if PORTAL_SUPERUSER_NAME and PORTAL_SUPERUSER_PASSWORD %}
        --pn {{ PORTAL_SUPERUSER_NAME }} --pp {{ PORTAL_SUPERUSER_PASSWORD }}
        {% endif %}
        {%- if PORTAL_SUPERUSER_EMAIL %}--pe {{ PORTAL_SUPERUSER_EMAIL }}{% endif %}
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ] || [ "$SKIP_DB_SETUP" = true ];"

{% if REGISTER_CONTROLLER %}
Set_Register_Controller_TethysCore:
  cmd.run:
    - name: tethys settings -s TETHYS_PORTAL_CONFIG.REGISTER_CONTROLLER {{ REGISTER_CONTROLLER }}
{% endif %}

{% if TETHYS_SITE_CONTENT %}
Modify_Tethys_Site_TethysCore:
  cmd.run:
    - name: tethys site {{ TETHYS_SITE_CONTENT }}
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/setup_complete" ];"
{% endif %}

Flag_Complete_Setup_TethysCore:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/setup_complete
    - shell: /bin/bash
