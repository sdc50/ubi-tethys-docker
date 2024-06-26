#!/bin/bash

echo_status() {
  local args="${@}"
  tput setaf 4
  tput bold
  echo -e "- $args"
  tput sgr0
}

db_max_count=24;
no_daemon=true;
skip_perm=false;
test=false;
USAGE="USAGE: . run.sh [options]
OPTIONS:
--background              \t run supervisord in background.
--skip-perm               \t skip fixing permissions step.
--db-max-count <INT>      \t number of attempt to connect to the database. Default is at 24.
--test                    \t only run test.
"

while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-perm)
      skip_perm=true;
    ;;
    --background)
      no_daemon=false;
    ;;
    --db-max-count)
      shift # shift from key to value
      db_max_count=$1;
    ;;
    --test)
      test=true;
    ;;
    *)
      echo -e "${USAGE}"
      return 0
  esac
  shift
done

echo_status "Starting up..."

# Remove stale pid and lock files that might remain after a host reboot
/bin/rm -f /run/tethys_asgi*.sock* >/dev/null 2>&1
/bin/rm -f /run/supervisord.pid >/dev/null 2>&1
/bin/rm -f /run/supervisor/supervisor.sock >/dev/null 2>&1
/bin/rm -f /run/httpd/* >/dev/null 2>&1

# Create Salt Config
echo "file_client: local" > /etc/salt/minion
echo "postgres.host: '${TETHYS_DB_HOST}'" >> /etc/salt/minion
echo "postgres.port: '${TETHYS_DB_PORT}'" >> /etc/salt/minion
echo "postgres.user: '${TETHYS_DB_USERNAME}'" >> /etc/salt/minion
echo "postgres.pass: '${TETHYS_DB_PASSWORD}'" >> /etc/salt/minion
echo "postgres.bins_dir: '${CONDA_HOME}/envs/${CONDA_ENV_NAME}/bin'" >> /etc/salt/minion

# Create Salt top.sls file
TOP_SLS=/srv/salt/top.sls
echo -e "base:\n  '*':" > ${TOP_SLS}
( IFS=:; for script_name in ${SALT_SCRIPTS}; do echo "    - $script_name" >> ${TOP_SLS}; done; )
( IFS=:; for script_name in ${ADDITIONAL_SALT_SCRIPTS}; do echo "    - $script_name" >> ${TOP_SLS}; done; )

if [[ $test = false ]]; then
  # Set extra ENVs
  export APACHE_USER=$(grep 'User ' /etc/httpd/conf/httpd.conf | awk '{print $2}')

  if [[ $WAIT_FOR_DB = true ]]; then
      # Apply States
      echo_status "Checking if DB is ready"

      db_check_count=0

      until ${CONDA_HOME}/envs/${CONDA_ENV_NAME}/bin/pg_isready -h ${TETHYS_DB_HOST} -p ${TETHYS_DB_PORT} -U postgres; do
        if [[ $db_check_count -gt $db_max_count ]]; then
          >&2 echo "DB was not available in time - exiting"
          exit 1
        fi
        >&2 echo "DB is unavailable - sleeping"
        db_check_count=`expr $db_check_count + 1`
        sleep 5
      done
  fi
fi

echo_status "Enforcing start state... (This might take a bit)"
salt-call --local --force-color state.apply

if [[ $test = false ]]; then
  if [[ $skip_perm = false ]]; then
    echo_status "Fixing permissions"
    chown -R ${APACHE_USER} ${STATIC_ROOT} ${WORKSPACE_ROOT} ${TETHYS_PERSIST} ${TETHYSAPP_DIR} ${TETHYS_HOME}
  fi

  echo_status "Starting supervisor"

  # Start Supervisor
  /usr/bin/supervisord $([[ $no_daemon = true ]] && printf %s "-n")

  echo_status "Done!"

  # Watch Logs
  echo_status "Watching logs"
  tail -qF /var/log/supervisor/*.log /var/log/httpd/*_log /var/log/tethys/*.log
fi

