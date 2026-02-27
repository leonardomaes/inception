# User Documentation - Inception
---

## What is Inception?

A self-hosted WordPress website running on Docker with NGINX web server, WordPress CMS, and MariaDB database - all in isolated containers.

---

## Services Provided

**1. NGINX (Web Server)**
- Handles HTTPS traffic on port 443
- TLS 1.2/1.3 encryption
- Access: https://lmaes.42.fr

**2. WordPress (CMS)**
- Content management system
- Admin panel: https://lmaes.42.fr/wp-admin

**3. MariaDB (Database)**
- Stores website data
- Internal access only (not exposed to internet)

---

## Starting and Stopping

### Start
```bash
cd /inception
make
```

### Stop
```bash
make stop    # Stop containers (keeps data)
make down    # Stop and remove containers (keeps data)
```

### Restart
```bash
make re
```

⚠️ **Never use `make clean` or `make fclean` unless you want to delete all data!**

---

## Accessing the Website

1. Open browser: `https://lmaes.42.fr`
2. Accept security warning (self-signed certificate - normal for development)
3. See WordPress homepage

**Admin Panel:** https://lmaes.42.fr/wp-admin
- Username: From `.env` file (`WP_ADMIN_USER`)
- Password: From `secrets/wp_admin_password.txt` file (`WP_ADMIN_PASSWORD`)

---

## Managing Credentials

### View Credentials
```bash
# WordPress admin
cat srcs/.env | grep WP_ADMIN
cat secrets/wp_admin_password.txt

# Database passwords
cat secrets/db_password.txt
cat secrets/db_root_password.txt
```

### Change WordPress Password

**Via WordPress Admin:**
1. Login → Users → Select user
2. Account Management → Set New Password

**Via Command Line:**
```bash
docker exec wordpress wp user update super_user \
  --user_pass='new_password' \
  --allow-root
```

---

## Monitoring Services

### Check Status
```bash
make status   # Quick status
docker ps     # Detailed info
```

### View Logs
```bash
make logs              # All services
```

---

## Backup and Restore

### Create Backup
```bash
# Stop services
make stop

# Create backup with timestamp
BACKUP="inception_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP"
cp -r ~/data/mariadb "$BACKUP/"
cp -r ~/data/wordpress "$BACKUP/"
tar -czf "${BACKUP}.tar.gz" "$BACKUP"
rm -rf "$BACKUP"

# Restart services
make start
```

### Restore from Backup
```bash
# Stop services
make down

# Remove current data
rm -rf ~/data/mariadb/* ~/data/wordpress/*

# Extract backup
tar -xzf inception_backup_*.tar.gz

# Restore
cp -r inception_backup_*/mariadb/* ~/data/mariadb/
cp -r inception_backup_*/wordpress/* ~/data/wordpress/

# Fix permissions
sudo chown -R $USER:$USER ~/data

# Start services
make up
```

---

## Common Commands

```bash
make status        # Check service status
make logs          # View all logs
make re            # Restart everything
docker ps          # List running containers
docker stats       # Resource usage
```

---