#!/usr/bin/env bash
# dbml_installer.sh — installer for DBML v4.1.0
set -euo pipefail
KH_HOME="${HOME}/kh-scripts"
LIB_DIR="${KH_HOME}/library/dynamic_box"
BACKUP_DIR="${KH_HOME}/backup"
LOG_DIR="${KH_HOME}/logs"
mkdir -p "${LIB_DIR}" "${BACKUP_DIR}" "${LOG_DIR}"
TS=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/dbml_install_${TS}.log"
echo "Installing DBML v4.1.0..." | tee "${LOG_FILE}"
if [[ -d "${LIB_DIR}" ]]; then
  BACKUP_OUT="${BACKUP_DIR}/dbml_preinstall_backup_${TS}.tar.gz"
  tar -czf "${BACKUP_OUT}" -C "${KH_HOME}" "$(realpath --relative-to="${KH_HOME}" "${LIB_DIR}")"
  echo "Existing DBML backed up to ${BACKUP_OUT}" | tee -a "${LOG_FILE}"
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -v "${SCRIPT_DIR}/dynamic_box.sh" "${LIB_DIR}/" | tee -a "${LOG_FILE}"
cp -v "${SCRIPT_DIR}/box-demo.sh" "${LIB_DIR}/" | tee -a "${LOG_FILE}"
cp -v "${SCRIPT_DIR}/dbml_template.sh" "${LIB_DIR}/" | tee -a "${LOG_FILE}"
chmod +x "${LIB_DIR}/dynamic_box.sh" "${LIB_DIR}/box-demo.sh" || true
echo "DBML v4.1.0 installed to ${LIB_DIR}" | tee -a "${LOG_FILE}"
echo "Log saved to ${LOG_FILE}"
