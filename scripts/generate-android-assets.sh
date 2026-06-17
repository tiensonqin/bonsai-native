#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
asset_dir="$repo_root/android/app/src/main/assets"
opam_switch=${BONSAI_ANDROID_OPAM_SWITCH:-/Users/tiensonqin/Codes/projects/bonsai-apple}

mkdir -p "$asset_dir"
opam exec --switch="$opam_switch" -- \
  dune exec "$repo_root/examples/export_counter_json.exe" \
  > "$asset_dir/bonsai_counter.json"

echo "Generated $asset_dir/bonsai_counter.json"
