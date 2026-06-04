# FitTrack Pro: Complete Project Overview

This document is your ultimate guide to understanding exactly how **FitTrack Pro** was built. It is written in simple terms so you can understand the architecture, make your own changes, and deploy updates completely on your own!

---

## 1. The Technology Stack
We used three main technologies to build this app:

* **Flutter:** The framework used to write the app. It uses the **Dart** programming language. Flutter allows you to write one codebase and run it on Web, iOS, and Android.
* **Firebase:** Google's backend service. We used it for three things:
  * **Authentication:** Letting users sign up and log in securely.
  * **Cloud Firestore:** A NoSQL database where we save the users' daily tracking data.
  * **Hosting:** The server that hosts your web app so people can access it via a URL.
* **Provider (State Management):** A Flutter package we used to manage the "state" (the live data) of the app so that when data changes, the screen updates automatically.

---

## 2. How the Code is Organized
If you look inside the `lib/` folder, you will see it is divided into a few key folders. This is a standard, professional way to organize an app:

### 📁 `models/` (The Blueprints)
* **`daily_record.dart`**: Think of this as the "blueprint" for a single day of tracking. It defines that a day has a date, a weight, an amount of water, protein, and 6 meals. It also contains the logic to convert this data into JSON (so it can be saved to Firebase) and back.

### 📁 `services/` (The Backend Bridge)
* **`storage_service.dart`**: This is the only file that actually talks directly to the Firestore Database. 
  * It listens to the database in real-time.
  * It saves new records (like when you move a slider).
  * It looks through all past records to find your **Custom Foods**.

### 📁 `providers/` (The Brains)
* **`daily_tracker_provider.dart`**: This sits between the UI (the screen) and the Service. When you move a slider, the screen tells this provider. The provider updates the `daily_record`, calculates your "Streak", and tells the `storage_service` to save it. 
* **`analytics_provider.dart`**: Does the math for the charts (averages, min/max weight, etc.).

### 📁 `screens/` (The UI/Visuals)
* This contains the actual screens you see (Dashboard, Daily Tracker, Analytics, History). 
* **The Magic of Auto-Save:** In `daily_tracker_screen.dart`, we hooked up the sliders so that every time they move, they immediately tell the provider to save. There is no "Save Button" needed!

---

## 3. Key Features We Built Together

> [!NOTE]
> **The Custom Food Picker**
> We replaced the default dropdown with a powerful `showModalBottomSheet`. We programmed it so that `storage_service.dart` scans the database for any food you've ever typed. It formats them using **Title Case** (e.g., "apple" -> "Apple") and groups them under a "YOUR CUSTOM FOODS" header, separating them from the default presets.

> [!TIP]
> **Streak Logic & Timezones**
> We encountered bugs where data was saving on the wrong day. We fixed this by forcing the app to save dates explicitly at "Midnight Local Time". We also built a streak calculator that checks if the previous day had a 100% score to keep the fire icon burning on the dashboard!

> [!IMPORTANT]
> **The PWA (Progressive Web App)**
> We made the web app feel like a native mobile app. We updated `web/manifest.json` and `web/index.html` to change the app's name to **FitTracker** and forced it to use your custom green leaf icon when someone taps "Add to Home Screen" on their phone.

---

## 4. How to Work on This App on Your Own

If you want to add new features or change colors, here is your cheat sheet for doing it yourself:

### Step 1: Run the App Locally
Open your terminal in the project folder (`/Users/sangeetha/Desktop/fitness app`) and run:
```bash
flutter run -d chrome
```
This opens the app in Chrome. If you change the code and save the file, you can press **`r`** in the terminal to "Hot Restart" and instantly see your changes without waiting!

### Step 2: Check for Errors
Before you release an update, it's always good to make sure your code is clean. Run:
```bash
flutter analyze
```
This will tell you if you missed a semicolon or made a typo.

### Step 3: Build the Production Version
When you are happy with your changes and want to share them with the world, you need to compile the Dart code into optimized Javascript. Run:
```bash
flutter build web --release
```
This takes about 30 seconds and puts all the final files into the `build/web/` folder.

### Step 4: Deploy to Firebase
Finally, push those new files up to Google's servers by running:
```bash
npx firebase-tools deploy --only hosting
```
Once that finishes, your changes are live at your `.web.app` URL for everyone to see!

---

## Final Words
You now have a fully functioning, database-backed, professionally architected Flutter application. If you ever want to add new features—like a "Water Goal" setting, or a "Social Feed" to share streaks with friends—you just follow the same pattern:
1. Update the **Model** (`daily_record.dart`)
2. Update the **Provider** to handle the logic.
3. Update the **Screen** to show it to the user!
