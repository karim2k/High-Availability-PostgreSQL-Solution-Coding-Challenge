#!/bin/bash
# 01_generate_ssl_certs.sh - SSL Certificate Generation

source ./00_config.sh

log "Generating SSL certificates..."
mkdir -p "$SSL_CERT_DIR"

# CA Certificate
openssl req -new -x509 -days 365 -nodes -out "$SSL_CERT_DIR/ca.crt" \
  -keyout "$SSL_CERT_DIR/ca.key" -subj "/CN=PostgreSQL CA"

# Server Certificate
openssl req -new -nodes -out "$SSL_CERT_DIR/server.csr" \
  -keyout "$SSL_CERT_DIR/server.key" -subj "/CN=$PRIMARY_NODE"
openssl x509 -req -in "$SSL_CERT_DIR/server.csr" -days 365 \
  -CA "$SSL_CERT_DIR/ca.crt" -CAkey "$SSL_CERT_DIR/ca.key" -CAcreateserial \
  -out "$SSL_CERT_DIR/server.crt"

chmod 600 "$SSL_CERT_DIR"/*
chown postgres:postgres "$SSL_CERT_DIR"/*
