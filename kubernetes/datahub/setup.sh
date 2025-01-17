#!/bin/bash

# Execute entrypoint as usual after obtaining ZOO_SERVER_ID
# check ZOO_SERVER_ID in persistent volume via myid
# if not present, set based on POD hostname
if [[ -f "/bitnami/zookeeper/data/myid" ]]; then
    export ZOO_SERVER_ID="$(cat /bitnami/zookeeper/data/myid)"
else
    HOSTNAME="$(hostname -s)"
    if [[ $HOSTNAME =~ (.*)-([0-9]+)$ ]]; then
        ORD=${BASH_REMATCH[2]}
        export ZOO_SERVER_ID="$((ORD + 1 ))"
    else
        echo "Failed to get index from hostname $HOSTNAME"
        exit 1
    fi
fi
exec /entrypoint.sh /run.sh