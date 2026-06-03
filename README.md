# FitTrack Pro 💪

FitTrack Pro is a premium, cross-platform fitness and diet tracking application built with **Flutter** and **Firebase**. Designed with a modern glassmorphism aesthetic, it allows users to privately log their daily habits, track custom foods, and monitor their long-term progress with dynamic charts and streak calendars.

## ✨ Features

- **Private & Secure Auth:** Built-in Firebase Authentication ensures every user has their own private database.
- **Daily Tracker:** Log water intake, weight, sleep, and workout status using a seamless auto-saving UI (no "Save" button required).
- **Custom Foods:** Add custom meals which are automatically title-cased, saved, and categorized under a "Your Custom Foods" section for future use.
- **Streak Calendar:** Automatically calculates and displays a continuous streak of perfect logging days, gracefully handling timezone shifts.
- **Analytics Dashboard:** Visualize your weight trends and daily completions with interactive charts.
- **PWA Ready:** Fully optimized as a Progressive Web App. Users can "Add to Home Screen" on their mobile devices for a native app experience, complete with custom icons.

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Web, iOS, Android)
- **Backend:** [Firebase](https://firebase.google.com/)
  - Authentication
  - Cloud Firestore (NoSQL Database)
  - Firebase Hosting
- **State Management:** Provider

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- [Firebase CLI](https://firebase.google.com/docs/cli) installed (`npm install -g firebase-tools`).

### Running Locally
1. Clone the repository and navigate to the project directory.
2. Install the Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application locally in Chrome:
   ```bash
   flutter run -d chrome
   ```

### 🌐 Deployment
This project is configured to deploy to Firebase Hosting. 

1. Build the optimized web release:
   ```bash
   flutter build web --release
   ```
2. Deploy the build to Firebase:
   ```bash
   npx firebase-tools deploy --only hosting
   ```

## 🎨 Design System
FitTrack Pro utilizes a sleek, dark-themed UI (`#0F172A` background) accented with neon teal (`#00E5FF`), smooth animations, and glassmorphic containers to deliver a premium user experience on both desktop and mobile web browsers.
