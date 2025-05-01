#!/bin/bash
# 00_docker_orchestrator.sh - Dockerized Step-by-Step Execution

set -euo pipefail
source ./00_config.sh

# Define the execution order of scripts
SCRIPTS=(
  "01_generate_ssl_certs.sh"
  "02_install_postgresql.sh pg-primary"
  "02_install_postgresql.sh pg-replica"
  "03_configure_primary.sh"
  "04_configure_replica.sh"
  "05_test_replication.sh"
  "06_test_failover.sh"
)

# Initialize Docker environment
init_docker() {
  log "Initializing Docker environment..."
  docker network create pg-ha-network 2>/dev/null || true
  
  docker run -d --name pg-primary --network pg-ha-network \
    -e POSTGRES_PASSWORD=secret -p 5432:5432 \
    -v $(pwd)/ssl:/etc/postgresql/ssl \
    -v $(pwd)/data/primary:/var/lib/postgresql/data \
    postgres:14-alpine > /dev/null
    
  docker run -d --name pg-replica --network pg-ha-network \
    -e POSTGRES_PASSWORD=secret -p 5433:5432 \
    -v $(pwd)/ssl:/etc/postgresql/ssl \
    -v $(pwd)/data/replica:/var/lib/postgresql/data \
    postgres:14-alpine > /dev/null
    
  docker run -d --name pg-control --network pg-ha-network \
    -v $(pwd):/scripts -it postgres:14-alpine \
    tail -f /dev/null > /dev/null
    
  sleep 5 # Wait for containers to initialize
}

# Cleanup function
cleanup() {
  log "Cleaning up Docker containers..."
  docker rm -f pg-primary pg-replica pg-control > /dev/null 2>&1 || true
  docker network rm pg-ha-network > /dev/null 2>&1 || true
}

# Main execution flow
main() {
  init_docker
  
  for script in "${SCRIPTS[@]}"; do
    log "Executing: $script"
    if docker exec pg-control bash -c "cd /scripts && ./$script"; then
      log "$script completed successfully"
    else
      error "Failed to execute $script"
    fi
    echo ""
  done
  
  log "All steps completed successfully!"
  echo -e "\nAccess Options:"
  echo "1. Primary PostgreSQL:   psql -h localhost -p 5432 -U postgres"
  echo "2. Replica PostgreSQL:   psql -h localhost -p 5433 -U postgres"
  echo "3. Control container:    docker exec -it pg-control bash"
}

# Handle Ctrl-C and errors
trap cleanup EXIT
trap 'error "Script interrupted"' INT

main
