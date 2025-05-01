#!/bin/bash
# 00_config.sh - Configuration Variables

# Node Configuration
export PRIMARY_NODE="pg-primary"
export REPLICA_NODE="pg-replica"
export PG_VERSION="14"
export NETWORK_CIDR="192.168.1.0/24"

# Database Configuration
export DB_NAME="healthcare"
export DB_USER="healthcare_admin"
export DB_PASSWORD=$(openssl rand -hex 16)
export REPLICATION_USER="repl_user"
export REPLICATION_PASSWORD=$(openssl rand -hex 16)
export SSL_CERT_DIR="/etc/postgresql/ssl"

# Logging Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export NC='\033[0m' # No Color

log() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" >&2
  exit 1
}
