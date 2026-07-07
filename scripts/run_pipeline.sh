#!/bin/bash

set -euo pipefail

LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/pipeline.log"

mkdir -p "${LOG_DIR}"

log() {
    local level="${1:-INFO}"
    local message="$2"

    printf "%s | %s | bash | %s\n" \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "${level}" \
        "${message}" | tee -a "${LOG_FILE}"
}

handle_error() {
    local exit_code=$?

    log "ERROR" "ETL pipeline failed with exit code ${exit_code}."

    exit "${exit_code}"
}

trap handle_error ERR

START_TIME=$(date +%s)

log "INFO" "Starting ETL pipeline at $(date '+%Y-%m-%d %H:%M:%S')."

python main.py 2>&1 | tee -a "${LOG_FILE}"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

log "INFO" "ETL pipeline completed successfully in ${DURATION} seconds."