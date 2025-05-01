#!/bin/bash
# 00_main.sh - PostgreSQL HA Cluster Setup Orchestrator

set -euo pipefail
source ./00_config.sh

log "Starting PostgreSQL HA Cluster Setup"

# Execute scripts in order
./01_generate_ssl_certs.sh
./02_install_postgresql.sh "$PRIMARY_NODE"
./02_install_postgresql.sh "$REPLICA_NODE"
./03_configure_primary.sh
./04_configure_replica.sh
./05_test_replication.sh
./06_test_failover.sh

log "PostgreSQL HA Cluster setup completed successfully"
