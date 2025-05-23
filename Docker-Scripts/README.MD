# Docker Scripts

## Start-All-Containers.sh:

### Prerequisites:
- Install mailx for sending emails:
```bash
sudo apt install mailutils
```
- Ensure your mail server is configured (e.g., postfix).
- Replace admin@zivcohenoz.com with your email.

### How It Works:
- Runs containers with health checks.
- Waits for them to stabilize.
- If unhealthy, attempts a restart.
- If the restart fails, an email alert is sent.


## Start-All-Containers-Using-Compose.sh

### Advantages of Using Docker Compose

✅ Easier to manage multiple containers from one configuration file.

✅ Automated restarts using restart: always.

✅ Built-in health checks without modifying the shell script.

### Docker Compose File Example:

Place this in your /path/to/your/docker-compose/docker-compose.yml file:

```bash
version: '3.8'
services:
  container1:
    image: image1
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "exit 0"]
      interval: 10s
      timeout: 5s
      retries: 3

  container2:
    image: image2
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "exit 0"]
      interval: 10s
      timeout: 5s
      retries: 3

  container3:
    image: image3
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "exit 0"]
      interval: 10s
      timeout: 5s
      retries: 3

  container4:
    image: image4
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "exit 0"]
      interval: 10s
      timeout: 5s
      retries: 3

  container5:
    image: image5
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "exit 0"]
      interval: 10s
      timeout: 5s
      retries: 3
```


