#!/bin/sh

# Fail this script if any subcommand fails
set -e

# Navigate to project root directory
cd $CI_PRIMARY_REPOSITORY_PATH

# Install Flutter using git
echo "Cloning Flutter stable channel..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Pre-cache iOS artifacts
flutter precache --ios

# Install Flutter dependencies
flutter pub get

echo "Xcode Cloud post-clone setup completed successfully."
exit 0
