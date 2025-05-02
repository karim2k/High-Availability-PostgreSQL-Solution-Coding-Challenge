POSTGRESQL HIGH AVAILABILITY CLUSTER DOCUMENTATION
By Abdelkarim Benabllah - [karim2k@gmail.com](https://medium.com/@karim2k)

PROJECT OVERVIEW
This project sets up a secure PostgreSQL cluster with automatic failover capabilities. It ensures continuous database availability even during server failures or maintenance.

KEY COMPONENTS
- Primary PostgreSQL node
- Standby replica node
- Automated failover system
- Security features
- Monitoring tools

REQUIREMENTS
- Linux servers (2 minimum)
- PostgreSQL 14
- SSH access between nodes
- Basic bash knowledge

SCRIPTS AND THEIR FUNCTIONS

00_config.sh
- Contains all configuration settings
- Sets up passwords and network details
- Defines security parameters

01_generate_ssl_certs.sh
- Creates SSL certificates
- Sets up encrypted connections
- Configures certificate permissions

02_install_postgresql.sh
- Installs PostgreSQL packages
- Checks for existing installations
- Sets up data directories
- Configures SSL support

03_configure_primary.sh
- Configures the primary database
- Sets up replication user
- Creates test database
- Implements security policies

04_configure_replica.sh
- Configures the standby server
- Sets up replication from primary
- Configures failover settings

05_test_replication.sh
- Tests data replication
- Verifies sync between nodes
- Checks for replication lag

06_test_failover.sh
- Tests automatic failover
- Simulates primary failure
- Verifies replica promotion

SETUP INSTRUCTIONS

1. Prepare two Linux servers
2. Install required packages
3. Clone this repository
4. Run scripts in order from 00 to 06
5. Verify setup with test scripts

SECURITY FEATURES
- Encrypted connections
- Row-level security
- Audit logging
- Secure authentication
- Limited superuser access

MONITORING COMMANDS

Check replication status:
psql -c "SELECT * FROM pg_stat_replication"

Verify node role:
psql -c "SELECT pg_is_in_recovery()"

Check connection count:
psql -c "SELECT count(*) FROM pg_stat_activity"

TROUBLESHOOTING

Replication not working:
- Check network connectivity
- Verify pg_hba.conf settings
- Check PostgreSQL logs

SSL connection issues:
- Verify certificate permissions
- Check certificate paths
- Confirm SSL settings in postgresql.conf

Failover not working:
- Check Patroni status
- Verify etcd/consul health
- Review failover logs

MAINTENANCE

Regular checks:
- Monitor replication lag
- Check disk space
- Review security logs
- Test failover periodically

Backup procedures:
- Configure WAL archiving
- Set up base backups
- Test restore process

This documentation covers all essential aspects of the project without special formatting. The plain text format makes it easy to view in any environment while maintaining all critical information.
