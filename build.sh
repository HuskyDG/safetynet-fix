#!/usr/bin/env bash

tmp_dir="$(mktemp --tmpdir -d modulebuild.XXXXXXXXXX)"
cleanup() {
    rm -fr "$tmp_dir"
}
trap cleanup EXIT

build_mode="${1:-Release}"

pushd "$(dirname "$0")"
src_dir="$(pwd)"
popd

cd "$tmp_dir"

pushd "$src_dir/riru"
rm -fr out
./gradlew "assemble$build_mode"
popd

pushd "$src_dir/java_module"
# Must always be release due to R8 requirement
./gradlew assembleRelease
popd

unzip "$src_dir/riru/out/safetynet-fix-"*.zip
unzip "$src_dir/java_module/app/build/outputs/apk/release/app-release.apk" classes.dex
sha256sum classes.dex | cut -d' ' -f1 | tr -d '\n' > classes.dex.sha256sum

rm -f "$src_dir/safetynet-fix.zip"
zip -r9 "$src_dir/safetynet-fix.zip" .
