#!/usr/bin/env bash

# up/down app

# get package vendor dir
VENDOR_DIR=$(dirname $(dirname $(readlink -f "${BASH_SOURCE[0]}")))
# Get vendor parent dir
VENDOR_PARENT_DIR=$(sed -n -e 's/\(^.*\)\(\(\/vendor\).*\)/\1/p' <<< "$VENDOR_DIR")

ACTION=$1

if [ "$ACTION" = "init" ]; then

    TARGET_DIR="$VENDOR_PARENT_DIR/docker"

    if [ ! -d "$TARGET_DIR" ]; then
        cp -r "$VENDOR_DIR/sample" "$TARGET_DIR/"
        mv "$TARGET_DIR/.env-sample" "$TARGET_DIR/.env-local"
        echo "Server init success."
        echo "Change root-path in: $TARGET_DIR/nginx/conf-dynamic.d/sample.conf"
    else
        echo "$TARGET_DIR folder already exists"
    fi

    exit 0;
fi

# export environments
. "${VENDOR_DIR}/helpers/compile-env.sh"

DETACHED_MODE=$DEFAULT_DETACHED_MODE

if [[ "${ACTION}" = "down" || "${ACTION}" = "restart" ]] && [ "$DETACHED_MODE" = "-d" ]; then
    DETACHED_MODE=""
fi

COMMAND=(docker-compose $SERVICES $ACTION $DETACHED_MODE $OTHER_PARAMS)

if [ "$ACTION" = "restart" ]; then
    "${COMMAND[@]/restart/down}"
    "${COMMAND[@]/restart/up}" $DEFAULT_DETACHED_MODE
else
    "${COMMAND[@]}"
fi
