# SilverCare Flutter App

An AI-powered health platform for elderly care — full Flutter conversion of the SilverCare web application.

---

## 🚀 Features

- 🌍 **Multi-language Support**  
  Full localization for English, Arabic, French, German, and Italian.

- 🤖 **AI Health Assistant**  
  Integrated with Groq LLM for personalized health guidance.

- 🚨 **Emergency SOS System**  
  One-tap emergency alerts with real-time GPS location sharing.

- 💊 **Medication Management**  
  Track daily medications, log status (_Taken / Skipped_), and sync with cloud/local cache.

- 🥗 **Healthy Meal Marketplace**  
  Browse nutritious, condition-specific meals with a structured cart and checkout process.

- 👥 **Companion Booking**  
  Browse and book professional care companions.

- 🔒 **Secure Authentication**  
  Integrated with Supabase Authentication.

- 🌙 **Adaptive UI**  
  Light and Dark theme support with a modern responsive design.

- 🏗️ **Clean Architecture**  
  Modularized widgets with clear separation of concerns (_Models, Providers, Services_).

---

## 📱 Project Structure

The project follows a scalable modular architecture:

```plaintext
lib/
├── models/           # Data models (CartItem, Meal, etc.)
├── providers/        # State management (MedicationProvider, ThemeProvider)
├── services/         # API & Auth services (AuthService)
├── theme/            # App theme configurations
├── widgets/          # Reusable UI components
│   ├── MedicationCard
│   └── CategoryFilter
└── screens/          # Main app screens
    ├── ai_assistant/
    ├── cart/         # Shopping cart & checkout logic
    ├── meals/        # Meal marketplace
    └── medications/  # Medication tracking
```

⚙️ Setup & Configuration

1️⃣ Installation
flutter pub get
2️⃣ Configuration
Supabase

Replace the following values in lib/main.dart:

\_supabaseUrl
\_supabaseAnonKey
Groq AI

Replace the API key in:

lib/screens/ai_assistant/ai_assistant_screen.dart
\_groqApiKey
🔐 Required Permissions
Android (AndroidManifest.xml)
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
iOS (Info.plist)
<key>NSLocationWhenInUseUsageDescription</key>
<string>SilverCare needs your location for emergency SOS alerts.</string>

🌍 Localization

The app supports 5 languages using easy_localization.

Supported Languages
English 🇺🇸
Arabic 🇪🇬
French 🇫🇷
German 🇩🇪
Italian 🇮🇹
Translation Files

Located in:

assets/translations/

⚠️ Note: Always use English keys for internal logic
(e.g. taken, skipped) and use .tr() for UI strings.

📦 Key Dependencies
Package Purpose
supabase_flutter Cloud backend & Authentication
go_router Scalable navigation
provider Efficient state management
easy_localization Multi-language support
geolocator GPS for SOS alerts
flutter_tts Text-to-Speech for AI responses
shared_preferences Local data persistence
🚀 Run the App
Debug Mode
flutter run
Profile Mode (Performance Testing)
flutter run --profile
🛠 Recent Updates
✅ Refactored complex screens into reusable widgets and dedicated files.
✅ Implemented a complete Cart & Checkout flow.
✅ Expanded localization support to 5 languages.
✅ Fixed navigation and Gradle compilation issues.
✅ Improved app structure and maintainability.
❤️ Built With Care

Built with ❤️ to improve elderly healthcare through technology, accessibility, and AI.

```

```
