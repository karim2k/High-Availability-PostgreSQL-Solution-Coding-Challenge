#!/bin/bash
# 06_test_failover.sh - Failover Testing

source ./00_config.sh

log "Testing failover..."

# Stop primary
ssh "$PRIMARY_NODE" "sudo systemctl stop postgresql"

# Promote replica
ssh "$REPLICA_NODE" "sudo -u postgres psql -c 'SELECT pg_promote(true, 30);'"

# Verify promotion
status=$(ssh "$REPLICA_NODE" "sudo -u postgres psql -t -c 'SELECT pg_is_in_recovery();' | tr -d '[:space:]'")
[ "$status" = "f" ] && log "Failover test passed" || error "Failover test failed"

# Restore original primary
ssh "$PRIMARY_NODE" "sudo systemctl start postgresql"
