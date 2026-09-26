#!/bin/bash
# Automatically install Flutter SDK on Vercel and build web bundle
set -e

if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"
flutter config --no-analytics
flutter doctor
flutter build web --release
