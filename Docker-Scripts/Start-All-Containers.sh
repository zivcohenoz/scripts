#!/bin/bash

# Ensure Docker is running
systemctl start docker

# Run the specified Docker containers
docker run -d --name container1 --health-cmd="exit 0" --health-interval=10s --health-timeout=5s --health-retries=3 image1
docker run -d --name container2 --health-cmd="exit 0" --health-interval=10s --health-timeout=5s --health-retries=3 image2
docker run -d --name container3 --health-cmd="exit 0" --health-interval=10s --health-timeout=5s --health-retries=3 image3
docker run -d --name container4 --health-cmd="exit 0" --health-interval=10s --health-timeout=5s --health-retries=3 image4
docker run -d --name container5 --health-cmd="exit 0" --health-interval=10s --health-timeout=5s --health-retries=3 image5

# Wait for containers to start
sleep 10

# Check if containers are healthy
for container in container1 container2 container3 container4 container5; do
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
            # Logging to a File
            echo "$(date): Container $container failed to restart!" >> /var/log/docker_errors.log

            # Send a Slack notification (OPTIONAL)
            # curl -X POST -H 'Content-type: application/json' --data '{"text":"Container $container is unhealthy and failed to restart!"}' https://hooks.slack.com/services/YOUR_WEBHOOK_URL

            # Send a Telegram Notification (OPTIONAL):
            # curl -s -X POST https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage -d chat_id=YOUR_CHAT_ID -d text="Container $container failed to restart!"
        fi
    fi
done

echo "Health check complete!"
