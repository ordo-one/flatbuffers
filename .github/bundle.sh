#!/usr/bin/env bash
# Packs one flatc binary as a single-variant SwiftPM artifact bundle, consumed by
# package-data-model Scripts/bundles/Package.swift as a .binaryTarget.
set -euo pipefail

# the release version carries an `-ordo.N` prerelease suffix, which does not belong in info.json
version="${VERSION%%-ordo*}"

# stable across releases, so the consumer's asset lookup does not change every tag
bundle="${PLATFORM}.artifactbundle"

mkdir -p "${bundle}/flatc/bin"
cp "$BINARY" "${bundle}/flatc/bin/${PLATFORM}-flatc"
chmod +x "${bundle}/flatc/bin/${PLATFORM}-flatc"

sed -e "s|__VERSION__|${version}|g" \
    -e "s|__PLATFORM__|${PLATFORM}|g" \
    -e "s|__TRIPLE__|${TRIPLE}|g" \
    .github/info.json > "${bundle}/info.json"

zip -r -q "${bundle}.zip" "${bundle}"
echo "built ${bundle}.zip"
