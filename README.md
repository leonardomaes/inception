# Inception

*This project has been created as part of the 42 curriculum by lmaes.*

## Description

Inception is a Docker-based infrastructure project that sets up a complete web hosting environment with NGINX, WordPress, and MariaDB running in isolated containers. Each service runs in its own dedicated container, orchestrated with Docker Compose.

### Key Components
- **NGINX**: Web server with TLS 1.2/1.3 encryption
- **WordPress**: Content management system with PHP-FPM
- **MariaDB**: Database server for data persistence
- **Docker Volumes**: Persistent storage in `/home/login/data`
- **Docker Network**: Isolated bridge network for inter-container communication

---

## Instructions

### Prerequisites
- Docker (20.10+)
- Docker Compose (1.29+)
- Make
- Linux virtual machine (Debian/Ubuntu)

### Installation

1. **Clone and setup:**
   ```bash
   git clone https://github.com/leonardomaes/inception.git
   cd inception
   ```

2. **Create secrets:**
   ```bash
   mkdir -p srcs/secrets
   echo "your_root_password" > srcs/secrets/db_root_password.txt
   echo "your_wp_admin_password" > srcs/secrets/wp_admin_password.txt
   echo "your_db_password" > srcs/secrets/db_password.txt
   chmod 600 srcs/secrets/*.txt
   ```

3. **Build and start:**
   ```bash
   make
   ```

### Usage

```bash
make        # Build and start all services
make start   # Start containers
make stop   # Stop containers
make down   # Stop and remove containers
make fclean  # Remove containers and volumes
make re     # Full rebuild
```

**Access Website:** https://lmaes.42.fr

---

## Resources

### Documentation
- [Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [MariaDB 1](https://mariadb.org/documentation/)
- [MariaDB 2](https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/docker-and-mariadb/creating-a-custom-container-image)
- [Docker Hub](https://hub.docker.com/search?badges=official)

### AI Usage

AI was used for:
- Documentation structure and formatting
- Configuration syntax verification
- Debugging assistance
- Troubleshooting solutions

---

## Project Description

### Architecture

```
Internet (HTTPS:443)
    ↓
[NGINX Container] - TLS termination
    ↓
[WordPress Container] - PHP-FPM (port 9000)
    ↓
[MariaDB Container] - Database (port 3306)

Volumes:
- ~/data/mariadb
- ~/data/wordpress
```

### Technology Stack
- **Base OS**: Debian Bullseye
- **Web Server**: NGINX with TLS 1.2/1.3
- **Application**: WordPress + PHP-FPM 7.4
- **Database**: MariaDB 10.5
- **Orchestration**: Docker Compose v3.8

### Design Choices

**Containers**: Each service in dedicated container for isolation and single responsibility.

**Base Image**: Debian Bullseye chosen for better package compatibility and stability over Alpine.

**Network**: Custom bridge network for isolation and DNS-based service discovery.

**Volumes**: Named volumes with bind mounts to specific host path as required by subject.

**Security**: TLS only, Docker secrets for passwords, minimal exposed ports (443 only).

---

## Technical Comparisons

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|------------------|--------|
| Isolation | Full OS | Process-level |
| Resources | High (full OS) | Low (shared kernel) |
| Startup | Minutes | Seconds |
| Size | GBs | MBs |
| Performance | Slower | Near-native |

**Choice**: Docker for faster development, efficient resources, and portability.

### Secrets vs Environment Variables

| Aspect | Secrets | Environment Variables |
|--------|---------|----------------------|
| Storage | Encrypted files | Plain text |
| Visibility | Mounted files only | Visible in inspect |
| Security | High | Low |
| Best For | Passwords, keys | Config, non-sensitive |

**Choice**: Secrets for all passwords, .env for usernames/domains.

### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|----------------|--------------|
| Isolation | Yes | No |
| Port Conflicts | No | Yes |
| DNS | Built-in | Manual |
| Security | Better | Same as host |

**Choice**: Bridge network for isolation and security.

### Docker Volumes vs Bind Mounts

| Aspect | Volumes | Bind Mounts |
|--------|---------|-------------|
| Management | Docker-managed | Manual |
| Portability | High | Path-dependent |
| Best For | Production | Development |

**Choice**: Named volumes with bind mounts to meet subject requirement (`/home/login/data`).

---
