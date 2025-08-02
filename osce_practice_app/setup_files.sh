#!/bin/bash

# Setup script for OSCE Practice App
# Run this script in your Flutter project root directory

echo "Setting up OSCE Practice App files..."

# Create directory structure
mkdir -p lib/{screens,widgets,models,services,utils}

echo "Directory structure created."
echo ""
echo "Next steps:"
echo "1. Replace your pubspec.yaml with the one provided"
echo "2. Copy all the lib files from the provided codebase"
echo "3. Run 'flutter pub get' to install dependencies"
echo "4. Set up Firebase (see Firebase Setup section below)"
echo ""
echo "Firebase Setup Required:"
echo "========================"
echo "1. Go to https://console.firebase.google.com/"
echo "2. Create a new project"
echo "3. Enable Authentication (Email/Password)"
echo "4. Enable Cloud Firestore"
echo "5. Run 'flutterfire configure' to add Firebase to your project"
echo ""
echo "Files you need to copy manually:"
echo "================================"
echo "- All files from lib/ directory"
echo "- pubspec.yaml"
echo "- README.md"
echo ""
echo "After copying files, run:"
echo "flutter pub get"
echo "flutter run"