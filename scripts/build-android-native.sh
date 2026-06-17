#!/usr/bin/env bash

set -euo pipefail

cat <<'EOF'
Android native build is not implemented yet.

Expected output:
  android/_build/android/jniLibs/arm64-v8a/libbonsai_android_counter.so

The intended pipeline is:
  1. Create/use an OCaml Android cross switch.
  2. Build bonsai_android and the app component for arm64-v8a.
  3. Link the OCaml runtime, app code, and jni/bonsai_android_jni.c into a .so.
  4. Run android/gradlew :app:assembleDebug.
EOF

exit 1
