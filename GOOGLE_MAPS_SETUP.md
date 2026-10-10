# Google Maps Platform Setup Guide for Universtree

This guide explains how to configure Google Maps Platform (Places Autocomplete, Maps SDK for Android, Maps JavaScript API, and Geocoding API) for the **Universtree College Registration Workflow**.

---

## 1. Google Cloud Console Setup

1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Select your project: **`universtree-3d91e`**.
3. Ensure **Billing** is enabled for the project (required by Google Maps Platform APIs).

---

## 2. Enable Required Google APIs

In Google Cloud Console under **APIs & Services > Library**, search for and enable the following APIs:

1. **Maps SDK for Android**
2. **Maps JavaScript API** (for Flutter Web)
3. **Places API (New)** (for Autocomplete & Place Details)
4. **Geocoding API** (for address component extraction)

---

## 3. Create Separate API Keys

Create **two separate API keys** under **APIs & Services > Credentials**:

### Key 1: `Universtree Android Maps Key`
- **Application Restriction**: `Android apps`
- **Package Name**: `com.universtree.app`
- **SHA-1 Fingerprint**: Obtain using Gradle:
  ```powershell
  cd android
  .\gradlew signingReport
  ```
- **API Restrictions**: Restrict key to *Maps SDK for Android*, *Places API*, and *Geocoding API*.

### Key 2: `Universtree Web Maps Key`
- **Application Restriction**: `Websites` / `HTTP referrers`
- **Allowed Referrers**:
  - `http://localhost:*`
  - `http://127.0.0.1:*`
  - `https://universtree-3d91e.web.app/*`
  - `https://universtree-3d91e.firebaseapp.com/*`
- **API Restrictions**: Restrict key to *Maps JavaScript API*, *Places API*, and *Geocoding API*.

---

## 4. Environment Variables Configuration

Add the API keys to your local `.env` file or pass them using `--dart-define`:

```env
# Google Maps Platform Secrets
GOOGLE_MAPS_PLACES_API_KEY="AIzaSyYourAndroidAndPlacesApiKey"
GOOGLE_MAPS_WEB_API_KEY="AIzaSyYourWebApiKey"
```

When building or running from command line:
```bash
flutter run --dart-define=GOOGLE_MAPS_PLACES_API_KEY=AIzaSy... --dart-define=GOOGLE_MAPS_WEB_API_KEY=AIzaSy...
```

---

## 5. Platform Native Setup

### Android (`android/app/src/main/AndroidManifest.xml`)
The API key is referenced inside `AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_ANDROID_API_KEY}" />
```

### Flutter Web (`web/index.html`)
The Web key is loaded inside `<head>` in `web/index.html`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_MAPS_API_KEY&libraries=places"></script>
```

---

## 6. Troubleshooting Common Google Maps Errors

| Error Code | Root Cause | Solution |
| :--- | :--- | :--- |
| `ApiNotActivatedMapError` | A required Google API is disabled in Cloud Console | Enable *Maps SDK for Android*, *Maps JavaScript API*, and *Places API*. |
| `RefererNotAllowedMapError` | Domain / localhost is not listed under HTTP Referrers | Add `http://localhost:*` to Web Key HTTP referrer restrictions. |
| `BillingNotEnabledMapError` | Google Cloud Billing is inactive | Associate a valid billing account with `universtree-3d91e`. |
| `REQUEST_DENIED` | Invalid API key or restriction mismatch | Check package name `com.universtree.app` and SHA-1 fingerprint. |
| `ZERO_RESULTS` | Place ID or location query returned no matches | Try a broader institution name or city query. |

---

## 7. Build & Verification Commands

```bash
# Fetch dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit & widget test suite
flutter test

# Run Android Debug build
flutter run

# Run Web Debug build
flutter run -d chrome
```
