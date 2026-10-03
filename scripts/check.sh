#!/usr/bin/env bash
# Run before pushing: static analysis, then every test.
# TZ is pinned so the NZ daylight-saving tests exercise the real transitions.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter analyze
TZ=Pacific/Auckland flutter test
