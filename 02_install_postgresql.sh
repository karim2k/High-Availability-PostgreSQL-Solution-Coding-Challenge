#!/bin/bash
# 02_install_postgresql.sh - PostgreSQL Installation with Existence Check

source ./00_config.sh

NODE=$1
log "Checking PostgreSQL installation on $NODE..."

# Function to check if PostgreSQL is already installed
check_postgres_installed() {
    ssh "$NODE" "which psql > /dev/null 2>&1 && \
                psql --version | grep -q $PG_VERSION"
}

if check_postgres_installed; then
    log "PostgreSQL $PG_VERSION is already installed on $NODE"
    exit 0
fi

log "Installing PostgreSQL $PG_VERSION on $NODE..."

ssh "$NODE" <<EOF
    # Install packages with confirmation
    sudo apt-get update
    sudo apt-get install -y postgresql-$PG_VERSION postgresql-contrib-$PG_VERSION \
        postgresql-$PG_VERSION-pgaudit postgresql-$PG_VERSION-wal2json
    
    # Verify installation
    if ! which psql > /dev/null; then
        echo "PostgreSQL installation failed" >&2
        exit 1
    fi
    
    # Stop PostgreSQL if running
    sudo systemctl stop postgresql 2>/dev/null || true
    
    # Initialize data directory if not exists
    if [ ! -d "/var/lib/postgresql/$PG_VERSION/main" ]; then
        sudo -u postgres /usr/lib/postgresql/$PG_VERSION/bin/initdb \
            --data-checksums \
            --encoding=UTF8 \
            --locale=en_US.UTF-8 \
            -D /var/lib/postgresql/$PG_VERSION/main
    else
        echo "Data directory already exists, skipping initialization"
    fi
    
    # Copy SSL certificates if directory exists
    if [ -d "/scripts/ssl" ]; then
        sudo mkdir -p /etc/postgresql/ssl
        sudo cp /scripts/ssl/* /etc/postgresql/ssl/
        sudo chown -R postgres:postgres /etc/postgresql/ssl
        sudo chmod 600 /etc/postgresql/ssl/*.key
    else
        echo "SSL certificates not found, skipping SSL setup"
    fi
    
    # Verify PostgreSQL version
    INSTALLED_VERSION=\$(psql --version | awk '{print \$3}')
    if [ "\$INSTALLED_VERSION" != "$PG_VERSION" ]; then
        echo "Version mismatch: Expected $PG_VERSION, found \$INSTALLED_VERSION" >&2
        exit 1
    fi
EOF

if [ \$? -eq 0 ]; then
    log "PostgreSQL $PG_VERSION successfully installed on $NODE"
else
    error "Failed to install PostgreSQL on $NODE"
fi
