#!/usr/bin/env bash

set -euo pipefail

target="${IOS_TARGET:-arm64-apple-ios17.0-simulator}"

if [[ -n "${IOS_SDKROOT:-}" ]]; then
  sdkroot="$IOS_SDKROOT"
else
  case "$target" in
    *simulator*)
      sdk=iphonesimulator
      ;;
    *)
      sdk=iphoneos
      ;;
  esac

  sdkroot="$(xcrun --sdk "$sdk" --show-sdk-path)"
fi

escaped=${sdkroot//\\/\\\\}
escaped=${escaped//\"/\\\"}

printf '(-ccopt "-isysroot" -ccopt "%s")\n' "$escaped"
