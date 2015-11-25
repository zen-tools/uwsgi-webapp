#!/usr/bin/env bash

BASE_DIR="$(dirname "$(readlink -f $0)" )";

export PERL5LIB="$PERL5LIB:$BASE_DIR/www/lib";
export PATH="$PATH:/usr/sbin:$BASE_DIR/sbin";

NGINX_PREFIX="$BASE_DIR/proxy/";
NGINX_CONF="${NGINX_PREFIX}/conf/nginx.conf";
NGINX_PID="$BASE_DIR/logs/nginx.pid";

UWSGI_PASS="127.0.0.1:9999";
UWSGI_MAIN="$BASE_DIR/www/router.psgi";
UWSGI_LOG="$BASE_DIR/logs/uwsgi.log";
UWSGI_PID="$BASE_DIR/logs/uwsgi.pid";

# Check script dependencies
function require() {
    local NF;
    while (($#)); do
        test -z $(which $1 2> /dev/null) && NF+=("$1");
        shift;
    done

    # Return the elements of array what have been not found
    test ${#NF[@]} -ne 0 && {
        echo ${NF[@]} && return 1;
    }

    return 0;
}

function build_configs() {
    mkdir -p "$BASE_DIR/proxy/conf/";
    local CONFIGS_SRC=(
        "uwsgi_params"
        "nginx.conf"
    );

    for cfg in "${CONFIGS_SRC[@]}"
    do
        cp "$BASE_DIR/conf/$cfg" "$BASE_DIR/proxy/conf/$cfg" || return 1;
        sed "s|{BASE_DIR}|$BASE_DIR|g" -i "$BASE_DIR/proxy/conf/$cfg" || return 2;
        sed "s|{UWSGI_PASS}|$UWSGI_PASS|g" -i "$BASE_DIR/proxy/conf/$cfg" || return 3;
    done
}

function sync_static_files() {
    mkdir -p "$BASE_DIR"/www/static/{css,files,js,images};
    mkdir -p "$BASE_DIR"/proxy/public/{css,files,js,images};
    for dir in css images files js
    do
        cp -Tar "$BASE_DIR/www/static/$dir" "$BASE_DIR/proxy/public/$dir" \
            || return 1;
    done

    return 0;
}

function is_running() {
    test -r "$1" || return 1;
    local PID=$(pgrep -F $1 2>/dev/null)
    test -n "$PID" || {
        return 2;
    }
    echo $PID;
    return 0;
}

function start() {
    build_configs || {
        echo "Error! Cannot build configs" 1>&2;
        exit 1;
    }

    sync_static_files || {
        echo "Error! Cannot sync static files" 1>&2;
        exit 2;
    }

    PID=$(is_running $NGINX_PID) && {
        echo "nginx is already running. pid - $PID" 1>&2;
        exit 3;
    } || {
        nginx -c $NGINX_CONF -p $NGINX_PREFIX;
    }

    PID=$(is_running "$UWSGI_PID") && {
        echo "uwsgi is already running. pid - $PID" 1>&2;
        exit 4;
    } || {
        uwsgi --socket "$UWSGI_PASS" \
              --http-socket-modifier1 5 \
              --master --daemonize="$UWSGI_LOG" \
              --pidfile="$UWSGI_PID" \
              --psgi "$UWSGI_MAIN";
    }
}

function stop() {
    PID=$(is_running "$NGINX_PID") && {
        kill -SIGQUIT $PID;
    }

    PID=$(is_running "$UWSGI_PID") && {
        kill -SIGKILL $PID;
    }
}

function status() {
    PID=$(is_running "$NGINX_PID") && {
        echo -e "nginx is running. pid - $PID";
    } || {
        echo -e "nginx is not runnig";
    }

    PID=$(is_running "$UWSGI_PID") && {
        echo -e "uwsgi is running. pid - $PID";
    } || {
        echo -e "uwsgi is not runnig";
    }
}

NOT_FOUND=( $(require nginx uwsgi) ) || {
    echo -e "ERROR: Unresolved dependencies:\n$(printf '%s\n' ${NOT_FOUND[@]})" 1>&2;
    exit 5;
}

case $1 in
    start)
        start;
    ;;
    stop)
        stop;
    ;;
    restart)
        stop;
        start;
    ;;
    status)
        status;
    ;;
    *)
        echo "Usage $0 (start|stop|restart|status)";
        exit 6;
    ;;
esac

exit 0;

