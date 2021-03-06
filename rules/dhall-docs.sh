#!/usr/bin/env bash
#
# Script that outputs dhall library docs
#

set -euo pipefail

# This function canonicalizes a path, including resolving symlinks
# Behavior is equivalent to `realpath` from Linux or brew coreutils
# https://stackoverflow.com/a/18443300
function _realpath() {
  local OURPWD=$PWD
  cd "$(dirname "$1")" || return 1
  local LINK
  LINK=$(readlink "$(basename "$1")")
  while [ "$LINK" ]; do
    cd "$(dirname "$LINK")" || return 1
    LINK=$(readlink "$(basename "$1")")
  done
  local REALPATH
  REALPATH="$PWD/$(basename "$1")"
  cd "$OURPWD" || return 1
  echo "$REALPATH"
  return 0
}

function debug_log() {
 if [ $DEBUG -eq 1 ]
 then
    echo "$(basename "$0") DEBUG: $1" >&2
  fi
}

DEBUG=0

while getopts "v:" arg; do
  # We handle the rest of the arguments below
  # shellcheck disable=SC2220
  case "$arg" in
    v)
      DEBUG=1
      ;;
  esac
done
shift $((OPTIND - 1))

DHALL_DOCS_BIN=$(_realpath "$1")
INPUT=$(_realpath "$2")
OUTPUT=$(_realpath "$3")
export XDG_CACHE_HOME="$PWD/.cache"
export HOME="$PWD"

debug_log "Working directory: ${PWD}"
debug_log "Cache: ${XDG_CACHE_HOME}"
debug_log "Dhall binary: ${DHALL_DOCS_BIN}"
debug_log "Input Dir: ${INPUT}"
debug_log "Output file: ${OUTPUT}"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cd "$TMPDIR"

$DHALL_DOCS_BIN --input "$INPUT"
tar -chzf "${OUTPUT}" .
