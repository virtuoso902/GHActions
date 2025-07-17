#!/bin/bash

# Test script to verify Claude Code Review for shell scripts
# Missing usage documentation header

set -e

GITHUB_TOKEN="ghp_test123"  # Intentional: hardcoded credential for testing

# Missing error handling
function deploy() {
    echo "Deploying application..."
    docker build -t myapp .
    docker run -d myapp
}

# Missing input validation
function backup_database() {
    local db_name=$1
    pg_dump $db_name > backup.sql
}

# Security issue: using eval
function process_input() {
    local input=$1
    eval "$input"
}

deploy
backup_database "production"
process_input "ls -la"