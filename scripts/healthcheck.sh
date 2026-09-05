#!/bin/bash

CONTAINER="mlops-api"

if ! sudo docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "$(date): Container is not running. Restarting..."
    sudo docker start "$CONTAINER"
else
    STATUS=$(sudo docker inspect --format='{{.State.Health.Status}}' "$CONTAINER")

    if [ "$STATUS" != "healthy" ]; then
        echo "$(date): Container unhealthy. Restarting..."
        sudo docker restart "$CONTAINER"
    fi
fi
