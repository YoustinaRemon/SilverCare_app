# SilverCare Flutter App

An AI-powered health platform for elderly care — full Flutter conversion of the SilverCare web application.

# Features

-🌍 Multi-language Support
Supports English, Arabic, French, German, and Italian using Easy Localization.
-🤖 AI Health Assistant
Smart AI assistant that provides personalized health guidance and recommendations.
-🚨 Emergency SOS System
One-tap SOS alert with live location sharing for emergency situations.
-📍 Real-time Location Access
Uses GPS to detect and send the user’s current location during emergencies.
-💊 Medication Management
Add, track, and manage daily medications with reminders and status tracking.
-📊 Health Profile Tracking
Store and manage health information including blood pressure, sugar levels, allergies, and chronic diseases.
-🥗 Healthy Meal Marketplace
Browse and order nutritious meals tailored to health conditions.
-👥 Companion Booking System
Find and book trusted companions for elderly care and social support.
-🔐 Authentication System
Secure Sign In / Sign Up with Supabase Authentication.
-☁️ Cloud Database Integration
Uses Supabase for real-time data storage and synchronization.
-🌙 Dark & Light Theme Support
Toggle between light and dark mode for better accessibility.
-📱 Responsive Modern UI
Clean and user-friendly Flutter UI optimized for mobile devices.
-🔄 State Management with Provider
Efficient app-wide state management using Provider.
-🧭 Navigation with GoRouter
Structured and scalable routing system using GoRouter.
-📜 Emergency Alert History
Keeps records of previous SOS alerts and emergency activities.
-🎨 Custom Theming System
Consistent design system with reusable colors and typography.

---

## 📱 Screens

| Screen               | Description                                                |
| -------------------- | ---------------------------------------------------------- |
| **Landing**          | Hero section, features, CTA buttons                        |
| **Login / Register** | Supabase authentication                                    |
| **Dashboard**        | Stats overview, medication progress, health summary        |
| **Medications**      | Track daily meds, mark taken/skipped, add custom meds      |
| **Emergency**        | SOS button with GPS, quick contacts, alert history         |
| **Meals**            | Meal catalog with category filter, shopping cart, checkout |
| **Companions**       | Browse & book care companions                              |
| **AI Assistant**     | Chat interface powered by Groq LLM                         |
| **Health Profile**   | Edit vitals, chronic diseases, allergies                   |

---

## ⚙️ Setup

### 1. Install dependencies

```bash
cd silvercare_flutter
flutter pub get
```

### 2. Configure Supabase

In `lib/main.dart`, replace the placeholder values with your project credentials:

```dart
const String _supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const String _supabaseAnonKey = 'YOUR_ANON_KEY';
```

> Use the same Supabase project as your web app — same values as your `.env` file.

### 3. Configure Groq AI

In `lib/screens/ai_assistant/ai_assistant_screen.dart`, replace:

```dart
static const _groqApiKey = 'YOUR_GROQ_API_KEY';
```

> Use your `VITE_GROQ_API_KEY` from the web app's `.env`.

### 4. Android permissions

Add the following inside the `<manifest>` tag in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 5. iOS permissions

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>SilverCare needs your location for emergency SOS alerts.</string>
```

---

## 🚀 Run the app

```bash
flutter run
```

---

## 📦 Dependencies

| Package                | Purpose                                    |
| ---------------------- | ------------------------------------------ |
| `supabase_flutter`     | Same backend as the website                |
| `go_router`            | Declarative routing with auth redirects    |
| `provider`             | State management                           |
| `http`                 | Groq API calls                             |
| `geolocator`           | GPS for emergency SOS                      |
| `google_fonts`         | Inter + Playfair Display (matches website) |
| `flutter_animate`      | Smooth entrance animations                 |
| `cached_network_image` | Companion & meal images                    |
| `intl`                 | Date formatting                            |
| `easy_localization`    | Multi-language support                     |
| `shared_preferences`   | Local storage for offline medication logs  |

---

## 🗂️ Project Structure

```
lib/
├── main.dart                        # Entry point + router
├── theme/
│   └── app_theme.dart               # Colors, typography, component styles
├── services/
│   └── auth_service.dart            # Supabase auth state
├── providers/
│   └── medication_provider.dart     # Medication state + Supabase + local cache
├── widgets/
│   └── app_shell.dart               # Bottom nav + app bar
└── screens/
    ├── landing_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── dashboard/
    │   └── dashboard_screen.dart
    ├── medications/
    │   └── medications_screen.dart
    ├── emergency/
    │   └── emergency_screen.dart
    ├── meals/
    │   └── meals_screen.dart
    ├── companions/
    │   └── companions_screen.dart
    ├── ai_assistant/
    │   └── ai_assistant_screen.dart
    └── health_profile/
        └── health_profile_screen.dart
```

---

## 🗄️ Database Tables (Supabase)

| Table                | Description                              |
| -------------------- | ---------------------------------------- |
| `health_profiles`    | User vitals, chronic diseases, allergies |
| `medications`        | User-added medications                   |
| `medication_logs`    | Daily taken/skipped logs                 |
| `emergency_alerts`   | SOS history with GPS coordinates         |
| `companion_bookings` | Care companion reservations              |

---

## 🌍 Localization

The app uses `easy_localization` and supports Arabic and English.  
Translation files are located in `assets/translations/`.

> **Important:** Never pass translated strings as database values. Status fields like `taken` and `skipped` are always stored in English regardless of the app language.

---

## 🐛 Known Issues & Notes

- Default medications (Metformin, Aspirin, etc.) are stored locally via `SharedPreferences` and identified by IDs starting with `d`. They are not synced to Supabase.
- Custom medications added by the user are stored locally with IDs starting with `local_` and also cached in `SharedPreferences`.
- Only medications fetched from the `medications` Supabase table are synced to `medication_logs`.
