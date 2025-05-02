#!/bin/bash
# 05_test_replication.sh - Replication Testing

source ./00_config.sh

log "Testing replication..."

# Insert test data on primary
ssh "$PRIMARY_NODE" <<EOF
  sudo -u postgres psql -d $DB_NAME -c \
    "INSERT INTO patients (ssn, name, dob) VALUES ('999-88-7777', 'Replication Test', '2001-01-01');"
EOF

# Verify on replica
result=$(ssh "$REPLICA_NODE" \
  "sudo -u postgres psql -d $DB_NAME -t -c \
   'SELECT count(*) FROM patients WHERE name = \'Replication Test\';' | tr -d '[:space:]'")

[ "$result" -eq 1 ] && log "Replication test passed" || error "Replication test failed"
