#!/bin/bash

set -e -o pipefail
shopt -s nullglob

# Script environment.
export PYSH_OS_NAME=`uname -s | tr '[:upper:]' '[:lower:]'`

# Layout of the work dir.
export PYSH_MINICONDA_DIR="miniconda"

# Paths for py.sh helpers.
export PYSH_MINICONDA_PATH="${PYSH_WORK_PATH}/${PYSH_MINICONDA_DIR}"
export PYSH_MINICONDA_BIN_PATH="${PYSH_MINICONDA_PATH}/bin"

# Paths for this script.
PYSH_MINICONDA_INSTALLER_PATH="${PYSH_LIB_PATH}/install-miniconda.sh"

# Determine the correct Miniconda installer.
if [ "${PYSH_OS_NAME}" = "darwin" ]; then
    PYSH_MINICONDA_INSTALLER_URL="https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
else
    PYSH_MINICONDA_INSTALLER_URL="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"
fi

# Runs a script silently, only outputing stderr/stdout on failure.
run-silent() {
    if ! CMD_OUTPUT=$(eval "${@} 2>&1"); then
        printf "ERROR!\n%s\n%s\n" "${*}" "${CMD_OUTPUT}"
        exit 1
    fi
}

# Download Miniconda.
if [ ! -f "${PYSH_MINICONDA_INSTALLER_PATH}" ]; then
    # Download Miniconda.
    printf "Downloading Miniconda... "
    curl --location --silent "${PYSH_MINICONDA_INSTALLER_URL}" > "${PYSH_MINICONDA_INSTALLER_PATH}"
    printf "done!\n"
fi

# Install Miniconda.
if [ ! -d "${PYSH_MINICONDA_PATH}" ]; then
    printf "Installing Miniconda... "
    run-silent bash "${PYSH_MINICONDA_INSTALLER_PATH}" -b -p "${PYSH_MINICONDA_PATH}"
    printf "done!\n"
    # Install helpers.
    printf "Installing py.sh helpers... "
    run-silent "${PYSH_MINICONDA_BIN_PATH}/pip" install --no-index --upgrade "${PYSH_HELPERS_PATH}"
    printf "done!\n"
fi

# Delegate to Python py.sh helpers.
"${PYSH_MINICONDA_BIN_PATH}/python" -m _pysh "${@}"