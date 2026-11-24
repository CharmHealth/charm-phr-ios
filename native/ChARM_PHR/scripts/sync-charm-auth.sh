#!/bin/bash
# Builds CharmAuth.xcframework from the charm-mobile-auth-sdk submodule (via its swift/sync.sh),
# but only when it is missing or the SDK sources changed since the last build. Runs as the phr
# scheme's Build pre-action, so it finishes before Xcode compiles the CharmAuthKit package.
#
# Output goes to $LOG (scheme pre-actions don't show in Xcode's build log).
# Force a rebuild: delete native/ChARM_PHR/charm-mobile-auth-sdk/swift/CharmAuth.xcframework.
set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SDK_DIR="$PROJECT_DIR/charm-mobile-auth-sdk"
FRAMEWORK="$SDK_DIR/swift/CharmAuth.xcframework"
STAMP="$SDK_DIR/swift/.CharmAuth.xcframework.stamp"
LOG="${TMPDIR:-/tmp}/charm-auth-sync.log"

exec >"$LOG" 2>&1
echo "[$(date)] charm-auth sync check"

if [ ! -f "$SDK_DIR/swift/sync.sh" ]; then
    echo "Submodule missing: run 'git submodule update --init' in the repo root."
    exit 1
fi

# Fingerprint: submodule commit + any local edits to the SDK sources.
fingerprint="$(
    cd "$SDK_DIR" &&
    git rev-parse HEAD &&
    git diff HEAD -- charm-mobile-auth swift/Sources swift/Package.swift build.gradle.kts settings.gradle.kts gradle.properties | shasum
)"

if [ -d "$FRAMEWORK" ] && [ -f "$STAMP" ] && [ "$(cat "$STAMP")" = "$fingerprint" ]; then
    echo "CharmAuth.xcframework is up to date; skipping."
    exit 0
fi

JAVA_21="$(/usr/libexec/java_home -v 21 2>/dev/null)"
if [ -z "$JAVA_21" ]; then
    echo "JDK 21 not found (needed to build CharmAuth.xcframework)."
    exit 1
fi

echo "Building CharmAuth.xcframework (JDK: $JAVA_21)..."
# Xcode's build environment would otherwise leak into Gradle's Kotlin/Native xcodebuild calls.
if env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin" \
    CHARM_AUTH_JAVA_HOME="$JAVA_21" "$SDK_DIR/swift/sync.sh"; then
    echo "$fingerprint" >"$STAMP"
    echo "Done."
else
    echo "sync.sh failed."
    exit 1
fi
