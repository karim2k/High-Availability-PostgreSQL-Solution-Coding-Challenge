-- ha_setup_test.sql - Complete HA Setup & Testing in PSQL

/* 1. SETUP PRIMARY NODE */
\c postgres postgres

-- Create replication user
CREATE ROLE repl_user WITH REPLICATION LOGIN PASSWORD 'repl_password';

-- Create application database
CREATE DATABASE healthcare;

\c healthcare postgres

-- Create tables with security features
CREATE TABLE patients (
    id SERIAL PRIMARY KEY,
    ssn TEXT NOT NULL,
    name TEXT NOT NULL,
    dob DATE NOT NULL,
    medical_history TEXT,
    CONSTRAINT ssn_format CHECK (ssn ~ '^\d{3}-\d{2}-\d{4}$')
);

-- Enable Row-Level Security
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

-- Create audit log table
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    action TEXT NOT NULL,
    record_id INT,
    changed_at TIMESTAMP DEFAULT NOW(),
    changed_by TEXT DEFAULT CURRENT_USER
);

-- Create audit trigger function
CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log(table_name, action, record_id)
        VALUES (TG_TABLE_NAME, 'CREATE', NEW.id);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log(table_name, action, record_id)
        VALUES (TG_TABLE_NAME, 'UPDATE', NEW.id);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log(table_name, action, record_id)
        VALUES (TG_TABLE_NAME, 'DELETE', OLD.id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to patients table
CREATE TRIGGER patients_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON patients
FOR EACH ROW EXECUTE FUNCTION log_changes();

-- Insert test data
INSERT INTO patients (ssn, name, dob, medical_history) VALUES
('123-45-6789', 'John Doe', '1980-01-15', 'Hypertension'),
('987-65-4321', 'Jane Smith', '1975-06-20', 'Diabetes');

/* 2. TEST ROW-LEVEL SECURITY */
-- Create test user
CREATE ROLE doctor LOGIN PASSWORD 'doctor_pass';

-- Create RLS policy
CREATE POLICY doctor_policy ON patients
    FOR SELECT TO doctor
    USING (id % 2 = 0);  -- Only allow access to even IDs

-- Test RLS
\c healthcare doctor
SELECT * FROM patients;  -- Should only see even IDs

\c healthcare postgres
SELECT * FROM patients;  -- Should see all records

/* 3. TEST REPLICATION (SIMULATED) */
-- Create replication slot (would normally be on primary)
SELECT * FROM pg_create_physical_replication_slot('standby1_slot');

-- Simulate WAL changes
INSERT INTO patients (ssn, name, dob) VALUES ('111-22-3333', 'Test Patient', '2000-01-01');

-- Check replication status (view from primary)
SELECT pid, usename, application_name, state, sync_state,
       pg_wal_lsn_diff(pg_current_wal_lsn(), sent_lsn) AS send_lag,
       pg_wal_lsn_diff(sent_lsn, flush_lsn) AS flush_lag,
       pg_wal_lsn_diff(flush_lsn, replay_lsn) AS replay_lag
FROM pg_stat_replication;

/* 4. TEST FAILOVER (SIMULATED) */
-- Promote standby (simulated)
SELECT pg_promote(true, 30);

-- Verify promotion
SELECT pg_is_in_recovery();  -- Should return false after promotion

/* 5. VERIFY DATA CONSISTENCY */
-- Count records
SELECT count(*) AS total_patients FROM patients;

-- Verify audit logging
SELECT * FROM audit_log ORDER BY changed_at DESC;

/* 6. SECURITY CHECKS */
-- Verify encryption status
SELECT name, setting FROM pg_settings WHERE name LIKE '%encrypt%';

-- Check authentication methods
SELECT * FROM pg_hba_file_rules ORDER BY line_number;

-- Verify RLS policies
SELECT nspname, relname, relrowsecurity, relforcerowsecurity
FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE relkind = 'r' AND nspname NOT LIKE 'pg_%';
