#!/bin/sh

# Fail this script if any subcommand fails
set -e

# Navigate to project root directory
cd $CI_PRIMARY_REPOSITORY_PATH

# 1. Install Flutter using git
echo "Cloning Flutter stable channel..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. Pre-cache iOS artifacts
flutter precache --ios

# 3. Install Flutter dependencies
flutter pub get

# 4. Install CocoaPods
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

# 5. Install CocoaPods dependencies
cd ios && pod install

echo "Xcode Cloud post-clone setup completed successfully."
exit 0
