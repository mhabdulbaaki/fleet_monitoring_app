# Fleet Monitoring App

A Flutter application to monitor a fleet of vehicles in real-time, displaying their locations on a map and providing detailed information about each vehicle.

## Features
- **Real-time Map View**: Displays all cars on a Google Maps interface
- **Car Details**: View detailed information about each car (speed, status, location)
- **Search and Filter**: Find specific cars by name or ID, and filter by status (Moving/Parked)
- **Real-time Updates**: Automatically refreshes car locations every 5 seconds
- **Tracking Mode**: Focus on a specific car and track its movement
- **Offline Support**: Caches car data for offline viewing

## Screenshots
[App Screen Recording](https://drive.proton.me/urls/V0CQ83D85M#g654uDjP2L4g)


## Prerequisites

- Flutter SDK (version 3.0 or later)
- Android Studio / VS Code
- A Google Maps API key (for map functionality)



### Step 1: Clone the repository

```bash
git clone https://github.com/mhabdulbaaki/fleet_monitoring_app.git
cd fleet_monitoring_app
```

### Step 2: Install dependencies

```bash
flutter pub get
```

### Step 3: Set up Google Maps API Key

1. Get a Google Maps API key from the [Google Cloud Console](https://console.cloud.google.com/)
2. Add your API key to the project:

For Android:
- Open `android/app/src/main/AndroidManifest.xml`
- Add your API key:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY" />
```

For iOS:
- Open `ios/Runner/AppDelegate.swift`
- Add:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```

### Step 4: Run the app

```bash
flutter run
```

## Architecture

This app uses:
- **Provider** for state management
- **Google Maps Flutter** for map integration
- **HTTP** for API calls
- **SharedPreferences** for local storage


## Assumptions and Limitations
- For a smoother animation/simulation of vehicles moving, I used a static mock data for the fleet of cars
- The google maps was only set up for android, so kindly test with an android device
- The app currently uses a mock API service with simulated car movements
- The map is centered on a default location (-1.950, 30.059)


