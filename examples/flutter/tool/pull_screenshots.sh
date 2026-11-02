#!/bin/sh
# Copies the screenshots of an integration test run off a device.
#
#   tool/pull_screenshots.sh ios <simulator id> <folder>
#   tool/pull_screenshots.sh ios-device <device id> <folder>
#   tool/pull_screenshots.sh android <emulator serial> <folder>
set -eu

platform=$1
device=$2
target=$3

mkdir -p "$target"

case "$platform" in
  ios)
    container=$(xcrun simctl get_app_container "$device" com.cdget.plass.plassShowcase data)
    cp -R "$container/tmp/plass-shots/." "$target/"
    ;;
  ios-device)
    xcrun devicectl device copy from --device "$device" \
      --domain-type appDataContainer --domain-identifier com.cdget.plass.plassShowcase \
      --source tmp/plass-shots --destination "$target"
    ;;
  android)
    adb -s "$device" exec-out run-as com.cdget.plass.plass_showcase tar c code_cache/plass-shots |
      tar -x -C "$target" --strip-components=2
    ;;
esac
