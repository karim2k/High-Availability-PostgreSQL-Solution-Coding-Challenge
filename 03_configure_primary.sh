#!/bin/bash
# 03_configure_primary.sh - Primary Node Configuration

source ./00_config.sh

log "Configuring primary node $PRIMARY_NODE..."

ssh "$PRIMARY_NODE" <<EOF
  # Create configuration
  sudo tee /etc/postgresql/$PG_VERSION/main/postgresql.conf >/dev/null <<CONF
# Security
listen_addresses = 'localhost,$PRIMARY_NODE'
ssl = on
ssl_cert_file = '/etc/postgresql/ssl/server.crt'
ssl_key_file = '/etc/postgresql/ssl/server.key'
ssl_ca_file = '/etc/postgresql/ssl/ca.crt'
password_encryption = scram-sha-256

# Replication
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
synchronous_commit = remote_apply
synchronous_standby_names = 'standby1'
CONF

  # Configure authentication
  sudo tee /etc/postgresql/$PG_VERSION/main/pg_hba.conf >/dev/null <<HBA
hostssl replication $REPLICATION_USER $NETWORK_CIDR scram-sha-256
HBA

  # Start PostgreSQL
  sudo systemctl start postgresql
  
  # Create users and database
  sudo -u postgres psql -c "CREATE ROLE $REPLICATION_USER WITH REPLICATION LOGIN PASSWORD '$REPLICATION_PASSWORD';"
  sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
  sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASSWORD';"
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
EOF
