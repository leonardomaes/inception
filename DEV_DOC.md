# DEV_DOC.md — Developer Documentation

## Overview

This document explains how a developer can set up, build, and manage the **Inception** project from scratch. The project consists of a small infrastructure composed of Docker containers running NGINX, WordPress + PHP-FPM, and MariaDB, orchestrated via Docker Compose inside a Virtual Machine.

---

## Prerequisites

Before getting started, make sure the following are available on your system:

- A **Virtual Machine** running a recent version of **Debian** or **Alpine Linux** (penultimate stable version recommended)
- **Docker** and **Docker Compose** installed
- **Make** installed
- **Git** installed
- Access to the root or a user with `sudo` privileges

---

## Project Structure

The repository must follow this directory layout:

```
.
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        └── bonus/
```

> **Note:** Each service has its own `Dockerfile`. You may not use pre-built images from DockerHub (except for the base Alpine/Debian images).

---

## Configuration Files

### `.env` file

Located at `srcs/.env`, this file holds non-sensitive environment variables:

```env
DOMAIN_NAME=login.42.fr

# MySQL / MariaDB
MYSQL_USER=your_db_user
MYSQL_DATABASE=wordpress

# WordPress
WORDPRESS_TITLE=My WordPress Site
WORDPRESS_ADMIN_USER=your_wp_admin      # Must NOT contain "admin" or "administrator"
WORDPRESS_ADMIN_EMAIL=admin@example.com
WORDPRESS_USER=second_user
WORDPRESS_USER_EMAIL=user@example.com
```

> **Important:** Passwords must **not** be stored in `.env`. Use Docker secrets instead.

### `secrets/` directory

Store sensitive data as plain text files in the `secrets/` folder:

- `credentials.txt` — WordPress admin credentials
- `db_password.txt` — MariaDB user password
- `db_root_password.txt` — MariaDB root password

These files must be listed in `.gitignore` and never committed to the repository.

### Domain configuration

Add the following line to `/etc/hosts` on the host machine to resolve the domain locally:

```
127.0.0.1   login.42.fr
```

Replace `login` with your actual 42 login.

---

## Building and Launching the Project

All build and run operations are managed via the `Makefile` at the project root.

### Build and start all containers

```bash
make
```

This command triggers `docker compose` to build the Docker images from their respective `Dockerfile`s and start the containers.

### Stop all containers

```bash
make down
```

### Clean all containers, images, volumes, and data

```bash
make fclean
```

> **Warning:** This will delete all persistent data stored in the Docker volumes.

### Rebuild from scratch

```bash
make re
```

---

## Docker Compose Overview

The `srcs/docker-compose.yml` file defines the following services:

| Service     | Description                                   | Port  |
|-------------|-----------------------------------------------|-------|
| `nginx`     | NGINX with TLSv1.2/TLSv1.3, entry point      | 443   |
| `wordpress` | WordPress + PHP-FPM (no NGINX)                | 9000  |
| `mariadb`   | MariaDB database (no NGINX)                   | 3306  |

All services share a custom **Docker network** defined in the compose file. `network: host` and `--link` are strictly forbidden.

### Named Volumes

Two Docker named volumes are used for data persistence:

- `db_volume` → stores the MariaDB database
- `wordpress_volume` → stores WordPress website files

Both volumes are mapped to `/home/login/data/` on the host machine (replace `login` with your username).

> **Bind mounts are not allowed** for these volumes.

---

## Container Management Commands

### View running containers

```bash
docker ps
```

### View logs for a specific container

```bash
docker logs <container_name>
```

### Open a shell inside a container

```bash
docker exec -it <container_name> sh
```

### Inspect a volume

```bash
docker volume inspect <volume_name>
```

### List all volumes

```bash
docker volume ls
```

---

## Data Persistence

All persistent data lives in Docker named volumes, physically stored on the host at:

```
/home/login/data/
├── db/          ← MariaDB data files
└── wordpress/   ← WordPress files
```

This data survives container restarts and `docker compose down`. It is only removed when volumes are explicitly deleted (e.g., `docker volume rm` or `make fclean`).

---

## Security Rules

- **No passwords in Dockerfiles** — always use environment variables or Docker secrets.
- **No `latest` tag** — always pin a specific image version.
- **No infinite loop commands** as entrypoints (e.g., `tail -f`, `sleep infinity`, `while true`).
- **NGINX is the sole entry point** — only port `443` is exposed externally, using TLSv1.2 or TLSv1.3.
- **Credentials must not appear in the Git repository** — use `.gitignore` to exclude `secrets/` and `.env` if it contains sensitive values.

---

## WordPress Database Setup

The MariaDB container must be initialized with:

- A **database** for WordPress
- A **regular user** with access to the WordPress database
- An **administrator user** whose username does **not** contain `admin`, `Admin`, `administrator`, or `Administrator`

These are configured via Docker secrets and environment variables read at container startup by the entrypoint script.

---

## Troubleshooting

| Issue | Solution |
|---|---|
| Containers exit immediately | Check entrypoint script; avoid infinite loop patterns |
| Cannot access `https://login.42.fr` | Verify `/etc/hosts` entry and that NGINX is running on port 443 |
| Database connection errors | Ensure MariaDB is fully initialized before WordPress starts; use `depends_on` with health checks |
| Volume data not persisting | Check that named volumes (not bind mounts) are defined in `docker-compose.yml` |
| TLS errors in browser | Self-signed certificate is expected; accept the browser security warning |

---

## Useful References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Configuration Guide](https://nginx.org/en/docs/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB Docker Setup](https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/)
- [PID 1 and Docker best practices](https://cloud.google.com/architecture/best-practices-for-building-containers)
