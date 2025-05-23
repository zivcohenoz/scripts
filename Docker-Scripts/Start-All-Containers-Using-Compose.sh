#!/bin/bash

# Ensure Docker is running
systemctl start docker

# Navigate to the directory where your `docker-compose.yml` is located
cd /path/to/your/docker-compose

# Start all containers
docker-compose up -d

# Wait for containers to initialize
sleep 10

# Check if containers are healthy
containers=("container1" "container2" "container3" "container4" "container5")

for container in "${containers[@]}"; do
    health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container")

    if [ "$health_status" == "healthy" ]; then
        echo "$container is healthy ✅"
    else
        echo "$container is NOT healthy ❌"
        echo "Attempting to restart $container..."
        docker restart "$container"

        sleep 5
        health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container")

        if [ "$health_status" != "healthy" ]; then
            echo "$container failed to restart! Sending an alert email..."
            echo "Container $container is unhealthy and failed to restart!" | mailx -s "Docker Container Issue" admin@zivcohenoz.com

            # Logging to a file
            echo "$(date): Container $container failed to restart!" >> /var/log/docker_errors.log

            # OPTIONAL: Send notifications to Slack or Telegram
            # curl -X POST -H 'Content-type: application/json' --data '{"text":"Container $container is unhealthy and failed to restart!"}' https://hooks.slack.com/services/YOUR_WEBHOOK_URL
            # curl -s -X POST https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage -d chat_id=YOUR_CHAT_ID -d text="Container $container failed to restart!"
        fi
    fi
done

echo "Health check complete!"