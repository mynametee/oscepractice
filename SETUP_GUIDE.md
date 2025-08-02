# 🚀 Local Setup Guide for OSCE Practice App

## Prerequisites
- Flutter SDK (3.0.0+)
- Android Studio or VS Code
- Git
- Firebase account (free)

## Step 1: Install Flutter

### Windows
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your PATH
4. Run `flutter doctor` to verify installation

### macOS
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/macos
2. Extract to `~/flutter`
3. Add `~/flutter/bin` to your PATH
4. Run `flutter doctor` to verify installation

### Linux
```bash
cd ~/
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
echo 'export PATH="$PATH:~/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
flutter doctor
```

## Step 2: Create Flutter Project

```bash
flutter create osce_practice_app
cd osce_practice_app
```

## Step 3: Replace Generated Files

### 3.1 Replace pubspec.yaml
Replace the contents of `pubspec.yaml` with:

```yaml
name: osce_practice_app
description: A Flutter app for OSCE practice with Firebase backend.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  
  # State Management
  provider: ^6.1.1
  
  # UI Components
  cupertino_icons: ^1.0.2
  google_fonts: ^6.1.0
  
  # Utilities
  intl: ^0.18.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### 3.2 Replace lib folder
Delete the existing `lib` folder and recreate with our structure:

```bash
rm -rf lib/
mkdir -p lib/{screens,widgets,models,services,utils}
```

### 3.3 Copy App Files
You need to copy all the files from our codebase. Here's the structure:

```
lib/
├── main.dart
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── department_screen.dart
│   ├── case_screen.dart
│   ├── clerking_screen.dart
│   ├── followup_screen.dart
│   └── result_screen.dart
├── widgets/
│   ├── timer_widget.dart
│   └── input_card.dart
├── models/
│   ├── case_model.dart
│   ├── user_model.dart
│   └── answer_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── sample_data.dart
└── utils/
    └── constants.dart
```

**Note:** All the file contents are provided in the codebase above. Copy each file exactly as shown.

## Step 4: Install Dependencies

```bash
flutter pub get
```

## Step 5: Firebase Setup

### 5.1 Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Create a project"
3. Enter project name: `osce-practice-app`
4. Disable Google Analytics (optional)
5. Click "Create project"

### 5.2 Enable Firebase Services

**Authentication:**
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Click "Save"

**Cloud Firestore:**
1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location near you
5. Click "Done"

### 5.3 Add Firebase to Flutter

Install Firebase CLI:
```bash
npm install -g firebase-tools
firebase login
```

Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

Configure Firebase for your project:
```bash
flutterfire configure
```

This will:
- Create `firebase_options.dart`
- Download `google-services.json` (Android)
- Download `GoogleService-Info.plist` (iOS)

### 5.4 Set Firestore Security Rules
In Firebase Console > Firestore Database > Rules, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Everyone can read departments and cases
    match /departments/{document} {
      allow read: if true;
      allow write: if false;
    }
    
    match /cases/{document} {
      allow read: if true;
      allow write: if false;
    }
    
    // Users can read/write their own attempts
    match /attempts/{document} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## Step 6: Run the App

### For Android:
```bash
flutter run
```

### For iOS (macOS only):
```bash
flutter run -d ios
```

### For Web:
```bash
flutter run -d chrome
```

## Step 7: Test the App

1. **Register a new account:**
   - Open the app
   - Switch to "Register" tab
   - Enter name, email, and password
   - Click "Register"

2. **Try a sample case:**
   - Select "Medicine" department
   - Choose "Chest Pain in a 45-year-old Male"
   - Start the timer
   - Complete the history taking sections
   - Answer follow-up questions
   - View your results

## Troubleshooting

### Common Issues:

**1. Firebase configuration errors:**
```bash
# Re-run configuration
flutterfire configure
```

**2. Dependency conflicts:**
```bash
flutter clean
flutter pub get
```

**3. Android build issues:**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**4. iOS build issues (macOS):**
```bash
cd ios
pod install
cd ..
flutter run
```

### Debug Tips:

1. **Check Flutter doctor:**
```bash
flutter doctor -v
```

2. **View logs:**
```bash
flutter logs
```

3. **Restart app:**
```bash
flutter hot restart
```

## Next Steps

Once the app is running:

1. **Add more sample cases** through Firebase Console
2. **Customize the UI** colors and themes
3. **Add more departments** and specialties
4. **Implement progress tracking** features
5. **Add offline support** for practice mode

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify all files are copied correctly
3. Ensure Firebase is properly configured
4. Check Flutter and dependency versions

The app should now be running locally with sample data automatically populated!