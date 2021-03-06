#!/bin/bash
set -e

# Helpers directory detection
HELPERS_DIR=$(dirname $(readlink -f $0))

# First arg is Python command to call to setup the venv
PYTHON_FOR_VENV="$1"
shift

# Second arg is venv location
PYTHON_VENV="$1"
shift

# Remaining args are either requirement files (.txt) or archive files coming from dependencies
REQS_LIST=""
DIST_LIST=""
for CANDIDATE in "$@"; do
    if test "$(basename ${CANDIDATE})" !=  "$(basename -s txt ${CANDIDATE})"; then
        REQS_LIST="${REQS_LIST} ${CANDIDATE}"
    else
        DIST_LIST="${DIST_LIST} ${CANDIDATE}"
    fi
done

# Status helper
STATUS="${HELPERS_DIR}/status.py -p "${PROJECT_ROOT}" -t ${SETUP_VENV_TARGET:-venv} --lang python -i gift -s"

# Prepare venv
RC=0
(${STATUS} "  * Setup venv folder" -- $PYTHON_FOR_VENV -m venv $PYTHON_VENV) || RC=$?
if test "$RC" -ne 0; then
    echo "Cleaning corrupted $PYTHON_VENV folder"
    rm -Rf $PYTHON_VENV;
    exit $RC;
fi

# Update pip first
(source $PYTHON_VENV/bin/activate && ${STATUS} "  * Upgrade pip" -- pip install pip --upgrade)

# Install dependencies first, if any, and if file exist
PIP_CMD="pip install ${PYTHON_VENV_EXTRA_ARGS}"
if test -n "${DIST_LIST}"; then
    ${STATUS} "  * Collect builds:"
    for DIST in $DIST_LIST; do
        ${STATUS} "    * ${DIST}"
        PIP_CMD="$PIP_CMD ${DIST}"
    done
    (source $PYTHON_VENV/bin/activate && ${STATUS} "  * Resolve builds" -- $PIP_CMD)
fi

# Finaly finish setup by doing pip installs
if test -n "$REQS_LIST"; then
    PIP_CMD="pip install ${PYTHON_VENV_EXTRA_ARGS}"
    for DEPFILE in $REQS_LIST; do
        PIP_CMD="$PIP_CMD -r $DEPFILE"
    done
    (source $PYTHON_VENV/bin/activate && ${STATUS} "  * Resolve requirements" -- $PIP_CMD)
fi
touch $PYTHON_VENV
