# Moodle Docker Compose Setup

## Overview
This guide provides instructions on how to set up and run Moodle using Docker Compose. The provided `docker-compose.yml` file includes services for Moodle, MariaDB (MySQL-compatible database), and Redis (for caching).

## Prerequisites
Before running the Moodle setup, ensure you have the following installed:
- Docker
- Docker Compose

## Customization
### Environment Variables
Modify the following variables in `docker-compose.yml` if needed:
- **Database Settings:**
  - `MYSQL_ROOT_PASSWORD`: Root password for MariaDB.
  - `MYSQL_DATABASE`: Database name for Moodle.
  - `MYSQL_USER`: Moodle database username.
  - `MYSQL_PASSWORD`: Moodle database user password.
- **Redis Cache Settings:**
  - `MOODLE_REDIS_HOST`: Redis hostname.
  - `MOODLE_REDIS_PORT`: Redis port (default: 6379).
- **Ports:**
  - The default Moodle ports are `8080` (HTTP) and `8443` (HTTPS). Modify these if needed.

## Running the Setup
1. **Clone the repository (if applicable)**
   ```bash
   git clone git@gitlab.uol.edu.pk:uol/moodle-setup.git
   cd moodle-setup
   ```

2. **Start the containers**
   ```bash
   docker compose up -d
   ```
   The `-d` flag runs the containers in detached mode.

3. **Check running containers**
   ```bash
   docker ps
   ```

4. **Access Moodle**
   - Open a web browser and navigate to:
     - `http://localhost:8080` (if running locally)
     - `http://server-ip:8080` (if running on a remote server)
   - Follow the Moodle installation steps and provide the database details:
     - Database Host: `mariadb`
     - Database Name: `moodle`
     - Database User: `moodleuser`
     - Database Password: `moodlepass`

## Stopping and Removing Containers
To stop and remove all containers, use:
```bash
docker compose down
```

To remove all associated volumes (erasing all database and Moodle data):
```bash
docker compose down -v
```

## Logs and Debugging
To view logs for any service:
```bash
docker compose logs <service-name>
```
For example:
```bash
docker compose logs moodle
```

## Backup and Restore
- **Backup Database:**
  ```bash
  docker exec moodle-db mysqldump -u moodleuser -pmoodlepass moodle > moodle-backup.sql
  ```
- **Restore Database:**
  ```bash
  docker exec -i moodle-db mysql -u moodleuser -pmoodlepass moodle < moodle-backup.sql
  ```

## Network Configuration
The containers communicate over a custom network (`moodle-net`) with the following subnet:
```
Subnet: 172.33.0.0/16
```
Modify this in the `docker-compose.yml` file if needed.

## Conclusion
This setup provides a fully functional Moodle deployment with MariaDB and Redis. Modify the configuration as needed to suit your environment.

