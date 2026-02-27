# Developer Documentation - Inception

Quick reference guide for building the Inception project.

---

## Prerequisites & Setup

### Required Software
```bash
sudo apt update && sudo apt install -y docker.io docker-compose make
sudo usermod -aG docker $USER && newgrp docker
```

### Project Structure
```bash
inception/
├── Makefile
├── secrets/
│   ├── db_root_password.txt
│   └── db_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── wordpress/
        └── nginx/
```

Create structure:
```bash
mkdir -p inception/srcs/requirements/{mariadb,nginx,wordpress}/{conf,tools}
mkdir -p inception/secrets ~/data/{mariadb,wordpress}
```

---

## Configuration Files

### Environment Variables (`srcs/.env`)

| Variable | Example Value | Purpose |
|----------|--------------|---------|
| `DOMAIN_NAME` | `example.42.fr` | Website domain |
| `MYSQL_DATABASE` | `wordpress` | Database name |
| `MYSQL_USER` | `wp_user` | Database user |
| `WP_ADMIN_USER` | `wpadmin` | WordPress admin (no "admin"!) |
| `WP_ADMIN_EMAIL` | `admin@example.com` | Admin email |
| `WP_USER` | `wpuser` | Regular user |
| `WP_USER_EMAIL` | `user@example.com` | User email |

### Secrets

| File | Content |
|------|---------|
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/db_password.txt` | WordPress database password |

**Important:** `chmod 600 secrets/*.txt`

### Domain Configuration
```bash
echo "127.0.0.1   example.42.fr" | sudo tee -a /etc/hosts
```

---

## Service Architecture

```
Internet → NGINX:443 → WordPress:9000 → MariaDB:3306
              ↓              ↓              ↓
          Port 443      wp_files       db_files
                    ~/data/wordpress  ~/data/mariadb
```

| Service | Base Image | Port | Volume | Purpose |
|---------|-----------|------|--------|---------|
| **MariaDB** | debian:bookworm | 3306 | `/var/lib/mysql` | Database |
| **WordPress** | debian:bookworm | 9000 | `/var/www/html` | PHP-FPM |
| **NGINX** | debian:bookworm | 443 | `/var/www/html` | Web server |

---

## Key Configuration Details

### MariaDB (`requirements/mariadb/`)

**Dockerfile:** Install MariaDB, copy config and setup script, expose port 3306

**conf/my.cnf:**
- `bind-address = 0.0.0.0`
- `port = 3306`
- `skip-networking = 0`

**tools/setup.sh:**
- Read secrets from `/run/secrets/`
- Initialize database if not exists
- Create database and user
- Grant privileges

### WordPress (`requirements/wordpress/`)

**Dockerfile:** Install PHP 7.4-FPM, WP-CLI, configure to listen on port 9000

**conf/www.conf:**
- `listen = 9000`
- `pm = dynamic`
- Process manager settings

**tools/setup.sh:**
- Wait for MariaDB
- Download WordPress with WP-CLI
- Create `wp-config.php`
- Install WordPress
- Create two users (admin + regular)

### NGINX (`requirements/nginx/`)

**Dockerfile:** Install NGINX, generate self-signed SSL certificate

**conf/nginx.conf:**
- `ssl_protocols TLSv1.2 TLSv1.3`
- `listen 443 ssl`
- FastCGI pass to `wordpress:9000`
- Root: `/var/www/html`

---

## Docker Compose Structure

**Key sections in `srcs/docker-compose.yml`:**

| Section | Configuration |
|---------|--------------|
| **Services** | mariadb, wordpress, nginx with build contexts |
| **Dependencies** | wordpress depends on mariadb, nginx depends on wordpress |
| **Volumes** | Named volumes with bind mounts to `~/data/` |
| **Networks** | Custom bridge network `inception` |
| **Secrets** | Files from `../secrets/*.txt` |
| **Restart Policy** | `on-failure` for all services |

---

## Makefile Commands

| Command | Action |
|---------|--------|
| `make` / `make all` | Build and start all services |
| `make down` | Stop and remove containers |
| `make clean` | Remove containers and volumes |
| `make fclean` | Full cleanup (images, networks, data) |
| `make re` | Rebuild from scratch |
| `make logs` | Follow logs from all services |

---

## Build & Verification

### Build Process
```bash
make
```

### Verification Steps

| Check | Command | Expected Result |
|-------|---------|----------------|
| Containers running | `docker ps` | 3 containers: mariadb, wordpress, nginx |
| Database ready | `docker exec mariadb mysqladmin ping` | "mysqld is alive" |
| WordPress installed | `docker exec wordpress wp core is-installed --allow-root` | No output (success) |
| NGINX config valid | `docker exec nginx nginx -t` | "syntax is ok" |
| Website accessible | `curl -k https://localhost` | HTML content |
| Network connectivity | `docker exec wordpress ping -c 2 mariadb` | Successful pings |

### Access Website
- URL: `https://example.42.fr`
- Accept SSL warning (self-signed certificate)
- Login: `/wp-admin` with credentials from `.env`

---

## Useful Commands

### Debugging
- **View logs:** `docker logs -f nginx`
- **Enter container:** `docker exec -it mariadb bash`
- **Test connectivity:** `docker exec wordpress ping mariadb`
- **Check processes:** `docker ps`

---

## Security Checklist

- [ ] Secrets not committed (add to `.gitignore`)
- [ ] `.env` not committed
- [ ] Only port 443 exposed to host
- [ ] TLS 1.2/1.3 only
- [ ] Admin username doesn't contain "admin"
- [ ] Strong random passwords in secrets
- [ ] Services on internal network
- [ ] MariaDB not accessible externally

---