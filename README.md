# OSCE Practice App 🩺

A Flutter-based mobile application designed to help clinical students practice history taking and clinical reasoning through simulated OSCE-style cases with intelligent feedback and scoring.

## 🚀 Features

### Core Functionality
- **User Authentication**: Email/password login and registration using Firebase Auth
- **Department Selection**: Choose from various medical departments (Medicine, Surgery, O&G, etc.)
- **Timed Cases**: 5-minute countdown timer for realistic OSCE practice
- **Structured Clerking**: Step-by-step history taking with comprehensive checklists:
  - Biodata
  - Presenting Complaint
  - History of Presenting Complaint
  - Review of Systems
  - Past Medical History
  - Family & Social History
  - Summary
- **Follow-up Questions**: Clinical reasoning questions for diagnosis and management
- **Intelligent Scoring**: Real-time feedback based on completeness and accuracy
- **Results & Analytics**: Detailed breakdown with areas for improvement

### UI/UX Features
- **Modern Design**: Clean, minimalist interface with clinical theme
- **Animated Timer**: Circular progress ring with color-coded feedback
- **Interactive Cards**: Expandable sections with progress tracking
- **Real-time Scoring**: Live progress indicators and completion percentages
- **Comprehensive Feedback**: Detailed results with grade and improvement suggestions

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Functions (optional)
  - Firebase Storage (optional)
- **State Management**: Provider
- **UI**: Material Design with Google Fonts

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── screens/                  # All app screens
│   ├── login_screen.dart     # Authentication (login/register)
│   ├── home_screen.dart      # Main dashboard with department grid
│   ├── department_screen.dart # Case list for selected department
│   ├── case_screen.dart      # Patient scenario and timer
│   ├── clerking_screen.dart  # Structured history taking
│   ├── followup_screen.dart  # Clinical reasoning questions
│   └── result_screen.dart    # Results and feedback
├── widgets/                  # Reusable UI components
│   ├── timer_widget.dart     # Animated countdown timer
│   ├── input_card.dart       # Expandable checklist cards
│   └── section_header.dart   # (Future widget)
├── models/                   # Data models
│   ├── case_model.dart       # Case, Department, FollowUpQuestion
│   ├── user_model.dart       # User data and progress
│   └── answer_model.dart     # ClerkingAnswer, FollowUpAnswer, AttemptModel
├── services/                 # Business logic
│   ├── auth_service.dart     # Firebase Authentication wrapper
│   └── firestore_service.dart # Database operations
└── utils/
    └── constants.dart        # Colors, dimensions, text styles
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Firebase account
- Android Studio / VS Code
- Git

### 1. Clone the Repository
```bash
git clone <repository-url>
cd osce_practice_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable the following services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - (Optional) Firebase Functions
   - (Optional) Firebase Storage

#### Configure Firebase for Flutter
1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Activate FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```

#### Firebase Configuration Files
The setup will generate the following files:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### 4. Firestore Security Rules
Add these security rules to your Firestore:

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
      allow write: if false; // Only admins should write
    }
    
    match /cases/{document} {
      allow read: if true;
      allow write: if false; // Only admins should write
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

### 5. Seed Initial Data
The app will automatically seed departments when first launched. For sample cases, you can add them manually through the Firebase Console or create a script.

### 6. Run the App
```bash
flutter run
```

## 📊 Database Schema

### Collections

#### `departments`
```json
{
  "id": "medicine",
  "name": "Medicine",
  "icon": "🩺"
}
```

#### `cases`
```json
{
  "id": "case01",
  "departmentId": "medicine",
  "title": "Chest Pain in a 45-year-old",
  "scenario": "Mr. John presents with 2-day history of central chest pain...",
  "clerkingChecklist": {
    "biodata": ["age", "sex", "occupation"],
    "presentingComplaint": ["pain location", "duration"],
    "HPC": ["onset", "character", "radiation", "aggravating factors"],
    "reviewOfSystems": ["cvs", "respiratory"],
    "PMH": ["hypertension", "diabetes"],
    "FSH": ["smoking", "alcohol"]
  },
  "followUpQuestions": [
    {
      "type": "short_answer",
      "question": "What is your most likely diagnosis?"
    }
  ],
  "answers": {
    "diagnosis": "Myocardial infarction",
    "differentials": ["Angina", "GERD", "Pulmonary embolism"]
  },
  "maxScore": 20
}
```

#### `attempts`
```json
{
  "userId": "uid_123",
  "caseId": "case01",
  "timestamp": "2025-08-02T12:00:00Z",
  "clerkingAnswers": { /* user responses */ },
  "followUpAnswers": [ /* user responses */ ],
  "scoreBreakdown": {
    "biodata": 2,
    "HPC": 6,
    "ROS": 3,
    "followUp": 4
  },
  "totalScore": 15,
  "maxScore": 20,
  "timeSpentSeconds": 240,
  "completed": true
}
```

## 🎨 Design System

### Colors
- **Primary**: #1A73E8 (Medical Blue)
- **Accent**: #34A853 (Success Green)
- **Background**: #FAFAFA (Light Gray)
- **Error**: #EA4335 (Warning Red)
- **Success**: #4CAF50 (Completion Green)

### Typography
- **Font Family**: Inter (via Google Fonts)
- **Heading Styles**: Bold, various sizes
- **Body Text**: Regular weight, readable sizes

### Components
- **Cards**: Rounded corners, subtle shadows
- **Buttons**: Rounded, color-coded by function
- **Progress Indicators**: Color-coded based on completion
- **Icons**: Consistent Feather/Material icon style

## 🔮 Future Enhancements

### Planned Features
- **Progress Tracking Dashboard**: Comprehensive analytics
- **Offline Mode**: Practice without internet
- **Voice Recording**: Audio history taking practice
- **AI-Powered Feedback**: Advanced NLP for answer evaluation
- **Multiplayer Mode**: Peer practice sessions
- **Custom Cases**: User-generated content
- **Export Results**: PDF reports for portfolio

### Technical Improvements
- **State Management**: Upgrade to Riverpod or Bloc
- **Testing**: Unit tests, widget tests, integration tests
- **CI/CD**: Automated build and deployment
- **Performance**: Code splitting, lazy loading
- **Accessibility**: Screen reader support, high contrast mode

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support, please contact [your-email@example.com] or create an issue in the repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Medical education community for feedback and requirements
- Open source contributors

---

**Note**: This app is designed for educational purposes to help medical students practice clinical skills. It should not be used as a substitute for proper medical training or real patient care.