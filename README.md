Here's a concise README.md without code frames (as requested):

# High Availability PostgreSQL Solution

## Overview
This solution implements a highly available PostgreSQL cluster for healthcare applications requiring minimal downtime. The architecture features automated failover, comprehensive monitoring, and security compliance.

## Key Features
- Primary-Replica topology with synchronous replication
- Automated failover via Patroni (RTO < 60 seconds)
- Connection pooling with PgBouncer
- Prometheus/Grafana monitoring with alerting
- TLS encryption and role-based access control

## Architecture Components
1. Primary PostgreSQL node (read/write)
2. Synchronous replica (hot standby)
3. Asynchronous replica (read scaling)
4. Consul for service discovery
5. Monitoring stack (Prometheus + Grafana)

## Setup Instructions
1. Clone this repository
2. Run the setup script: `./setup.sh`
3. Initialize cluster: `./init_cluster.sh`
4. Access Grafana dashboard at http://localhost:3000

## Testing Failover
Execute the test script to simulate primary failure:
`./test_failover.sh --simulate-primary-crash`

Expected behavior:
- Failover detected within 15 seconds
- Replica promoted within 30 seconds
- Clients automatically reconnect


## Requirements
- Docker and docker-compose
- Python 3.8+
- 4GB RAM minimum

## Limitations
- Max 5 node cluster size
- Single-region deployment
- Manual backup configuration

## License
MIT License
