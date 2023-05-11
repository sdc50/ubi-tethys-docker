ARG BASE_IMAGE=tethysplatform/ubi-micromamba

FROM ${BASE_IMAGE}
###################
# BUILD ARGUMENTS #
###################
ARG PYTHON_VERSION=3.*
ARG RUN_SUPERVISOR_AS_USER="root"
ARG TETHYS_VERSION="4.0"
ARG TETHYS_CHANNEL="tethysplatform"

###############
# ENVIRONMENT #
###############
ENV TETHYS_HOME="/usr/lib/tethys"
ENV TETHYS_LOG="/var/log/tethys"
ENV TETHYS_PERSIST="/var/lib/tethys_persist"
ENV TETHYS_APPS_ROOT="/var/www/tethys/apps"
ENV TETHYS_PORT=8000
ENV POSTGRES_PASSWORD="pass"
ENV TETHYS_DB_NAME='tethys_platform'
ENV TETHYS_DB_USERNAME="tethys_default"
ENV TETHYS_DB_PASSWORD="pass"
ENV TETHYS_DB_HOST="db"
ENV TETHYS_DB_PORT=5432
ENV TETHYS_DB_ENGINE="django.db.backends.postgresql"
ENV TETHYS_DB_OPTIONS=""
ENV TETHYS_DB_SUPERUSER="tethys_super"
ENV TETHYS_DB_SUPERUSER_PASS="pass"
ENV PORTAL_SUPERUSER_NAME=""
ENV PORTAL_SUPERUSER_EMAIL=""
ENV PORTAL_SUPERUSER_PASSWORD=""
ENV TETHYS_MANAGE="${TETHYS_HOME}/tethys/tethys_portal/manage.py"
ENV WAIT_FOR_DB=true
ENV SKIP_DB_SETUP=false
ENV SKIP_DB_MIGRATE=false

# Salt Scripts
ENV SALT_SCRIPTS="pre_tethys:tethyscore:post_app"
ENV ADDITIONAL_SALT_SCRIPTS=""

# Proxy Server Config
ENV APACHE_SSL_CERT_FILE="${TETHYS_PERSIST}/keys/server.crt"
ENV APACHE_SSL_KEY_FILE="${TETHYS_PERSIST}/keys/server.key"
ENV PROXY_SERVER_PORT=""
ENV USE_SSL=false
ENV RUN_PROXY_SERVER_AS_USER="root"
ENV PROXY_SERVER_PORT=""
ENV PROXY_SERVER_ADDITIONAL_DIRECTIVES=""

# Misc
ENV BASH_PROFILE=".bashrc"
ENV CONDA_HOME="/opt/conda"
ENV CONDA_ENV_NAME=tethys
ENV ENV_NAME=tethys
ENV ASGI_PROCESSES=1
ENV CLIENT_MAX_BODY_SIZE="75M"

# Tethys settings arguments
ENV DEBUG="False"
ENV ALLOWED_HOSTS="\"[localhost, 127.0.0.1]\""
ENV BYPASS_TETHYS_HOME_PAGE="True"
ENV ADD_DJANGO_APPS="\"[]\""
ENV SESSION_WARN=1500
ENV SESSION_EXPIRE=1800
ENV STATICFILES_USE_NPM=false
ENV REGISTER_CONTROLLER=null
ENV STATIC_ROOT="${TETHYS_PERSIST}/static"
ENV WORKSPACE_ROOT="${TETHYS_PERSIST}/workspaces"
ENV QUOTA_HANDLERS="\"[]\""
ENV DJANGO_ANALYTICAL="\"{}\""
ENV ADD_BACKENDS="\"[]\""
ENV OAUTH_OPTIONS="\"{}\""
ENV CHANNEL_LAYERS_BACKEND="channels.layers.InMemoryChannelLayer"
ENV CHANNEL_LAYERS_CONFIG="\"{}\""
ENV RECAPTCHA_PRIVATE_KEY=""
ENV RECAPTCHA_PUBLIC_KEY=""
ENV OTHER_SETTINGS=""

# Tethys site arguments
ENV SITE_TITLE=""
ENV FAVICON=""
ENV BRAND_TEXT=""
ENV BRAND_IMAGE=""
ENV BRAND_IMAGE_HEIGHT=""
ENV BRAND_IMAGE_WIDTH=""
ENV BRAND_IMAGE_PADDING=""
ENV APPS_LIBRARY_TITLE=""
ENV PRIMARY_COLOR=""
ENV SECONDARY_COLOR=""
ENV PRIMARY_TEXT_COLOR=""
ENV PRIMARY_TEXT_HOVER_COLOR=""
ENV SECONDARY_TEXT_COLOR=""
ENV SECONDARY_TEXT_HOVER_COLOR=""
ENV BACKGROUND_COLOR=""
ENV COPYRIGHT=""
ENV HERO_TEXT=""
ENV BLURB_TEXT=""
ENV FEATURE_1_HEADING=""
ENV FEATURE_1_BODY=""
ENV FEATURE_1_IMAGE=""
ENV FEATURE_2_HEADING=""
ENV FEATURE_2_BODY=""
ENV FEATURE_2_IMAGE=""
ENV FEATURE_3_HEADING=""
ENV FEATURE_3_BODY=""
ENV FEATURE_3_IMAGE=""
ENV CALL_TO_ACTION=""
ENV CALL_TO_ACTION_BUTTON=""
ENV PORTAL_BASE_CSS=""
ENV HOME_PAGE_CSS=""
ENV APPS_LIBRARY_CSS=""
ENV ACCOUNTS_BASE_CSS=""
ENV LOGIN_CSS=""
ENV REGISTER_CSS=""
ENV USER_BASE_CSS=""
ENV HOME_PAGE_TEMPLATE=""
ENV APPS_LIBRARY_TEMPLATE=""
ENV LOGIN_PAGE_TEMPLATE=""
ENV REGISTER_PAGE_TEMPLATE=""
ENV USER_PAGE_TEMPLATE=""
ENV USER_SETTINGS_PAGE_TEMPLATE=""

#########
# SETUP #
#########
USER root
WORKDIR ${TETHYS_HOME}

# Install APT packages
RUN rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 \
 && dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
 && rpm --import https://repo.saltproject.io/salt/py3/redhat/8/x86_64/latest/SALT-PROJECT-GPG-PUBKEY-2023.pub \
 && curl -fsSL https://repo.saltproject.io/salt/py3/redhat/8/x86_64/latest.repo | tee /etc/yum.repos.d/salt.repo \
 && dnf update -y \
 && dnf -y install bzip2 httpd mod_ssl supervisor salt-minion procps pv \
 && dnf clean all

# Remove default Apache site
RUN rm -f /etc/httpd/conf.d/ssl.conf

# Setup Conda Environment
WORKDIR ${TETHYS_HOME}/tethys
RUN micromamba create -n "${CONDA_ENV_NAME}" --yes -c conda-forge -c ${TETHYS_CHANNEL} \
    tethys-platform=${TETHYS_VERSION} python=${PYTHON_VERSION} \
 && micromamba clean --all --yes

###########
# INSTALL #
###########
# Make dirs
RUN mkdir -p ${TETHYS_PERSIST} ${TETHYS_APPS_ROOT} ${WORKSPACE_ROOT} ${STATIC_ROOT} ${TETHYS_LOG}

# Setup www user, run supervisor and nginx processes as www user
RUN sed -i "/^\[supervisord\]$/a user=${RUN_SUPERVISOR_AS_USER}" /etc/supervisord.conf \
  ; chown -R apache: ${TETHYS_LOG} /run /var/log/supervisor /var/log/httpd /var/lib/httpd

# Run Installer
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN tethys gen portal_config

# Install channel-redis
RUN pip install channels_redis

############
# CLEAN UP #
############
 RUN dnf -y autoremove \
  ; dnf -y clean all

#########################
# CONFIGURE  ENVIRONMENT#
#########################
VOLUME ["${WORKSPACE_ROOT}", "${STATIC_ROOT}", "${TETHYS_PERSIST}/keys"]
EXPOSE ${PROXY_SERVER_PORT}

###############*
# COPY IN SALT #
###############*
ADD docker/salt/ /srv/salt/
ADD docker/run.sh ${TETHYS_HOME}/

########
# RUN! #
########
WORKDIR ${TETHYS_HOME}
# Create Salt configuration based on ENVs
CMD bash run.sh
HEALTHCHECK --start-period=240s \
  CMD  function check_process_is_running(){ if [ "$(ps $1 | wc -l)" -ne 2 ]; then echo The $2 process \($1\) is  not running. 1>&2; return 1; fi }; \
  check_process_is_running $(cat $(grep 'pidfile=.*' /etc/supervisord.conf | awk -F'=' '{print $2}' | awk '{print $1}')) supervisor; \
  check_process_is_running $(cat $(grep "PidFile " /etc/httpd/conf/httpd.conf || echo $(grep 'ServerRoot "' /etc/httpd/conf/httpd.conf | awk -F'"' '{print $2}')/logs/httpd.pid)) apache; \
  check_process_is_running $(ls -l /run/tethys_asgi0.sock.lock | awk -F'-> ' '{print $2}') asgi;
