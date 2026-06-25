#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
  printf '%s\n' "$CODESIGN_IDENTITY"
  exit 0
fi

identity=""
if command -v security >/dev/null 2>&1; then
  identity="$(
    security find-identity -v -p codesigning 2>/dev/null \
      | awk '/^[[:space:]]*[0-9]+\)/ && $0 !~ /CSSMERR_/ { print $2; exit }'
  )"
fi

if [[ -n "$identity" ]]; then
  printf '%s\n' "$identity"
  exit 0
fi

case "${IOS_TARGET:-}" in
  *simulator* | *Simulator*)
    printf -- '-\n'
    exit 0
    ;;
esac

printf 'No valid Apple code signing identity found. Set CODESIGN_IDENTITY explicitly or install an Apple Development certificate.\n' >&2
exit 1
