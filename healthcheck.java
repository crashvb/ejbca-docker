#!/bin/bash

set -e -o pipefail

log "Checking if $(basename "${0}") is healthy ..."
[[ $(pgrep --count --full /usr/lib/jvm/java-11-slim/bin/java) -gt 0 ]]

