#!/bin/bash
# 04_configure_replica.sh - Replica Node Configuration

source ./00_config.sh

log "Configuring replica node $REPLICA_NODE..."

ssh "$REPLICA_NODE" <<EOF
  sudo systemctl stop postgresql
  sudo rm -rf /var/lib/postgresql/$PG_VERSION/main
  
  # Perform base backup
  sudo -u postgres pg_basebackup -h $PRIMARY_NODE -D /var/lib/postgresql/$PG_VERSION/main \
    -U $REPLICATION_USER -P -v --wal-method=stream
  
  # Configure recovery
  sudo tee /var/lib/postgresql/$PG_VERSION/main/standby.signal >/dev/null <<SIGNAL
standby_mode = 'on'
SIGNAL

  sudo tee -a /var/lib/postgresql/$PG_VERSION/main/postgresql.auto.conf >/dev/null <<CONF
primary_conninfo = 'host=$PRIMARY_NODE user=$REPLICATION_USER password=$REPLICATION_PASSWORD sslmode=require'
CONF

  sudo systemctl start postgresql
EOF
