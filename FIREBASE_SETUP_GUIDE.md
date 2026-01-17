# Firebase Setup Guide for Destiny Decoder
**Date**: January 17, 2026  
**Purpose**: Complete Firebase Cloud Messaging (FCM) integration for push notifications  
**Target**: Android, iOS, and Backend Python

---

## Table of Contents
1. [Phase 1: Firebase Project Setup](#phase-1-firebase-project-setup)
2. [Phase 2: Android Configuration](#phase-2-android-configuration)
3. [Phase 3: iOS Configuration](#phase-3-ios-configuration)
4. [Phase 4: Flutter Integration](#phase-4-flutter-integration)
5. [Phase 5: Backend Python Setup](#phase-5-backend-python-setup)
6. [Phase 6: Testing](#phase-6-testing)
7. [Troubleshooting](#troubleshooting)

---

## Phase 1: Firebase Project Setup

### Step 1.1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. **Project Name**: `destiny-decoder` (or your preference)
4. **Analytics**: Enable Google Analytics (optional but recommended)
5. Click **Create project**
6. Wait for project creation to complete (1-2 minutes)

### Step 1.2: Register Apps
After project creation, you'll see the dashboard.

#### Register Android App
1. Click **Android** icon (or "Add app" → Android)
2. **Package name**: `com.example.destiny_decoder_app` (must match pubspec.yaml)
   - Check your `android/app/build.gradle` for actual package name
3. **App nickname**: `Destiny Decoder Android`
4. **SHA-1 certificate hash**: [See Step 1.3 below]
5. Click **Register app**
6. Download `google-services.json`
7. Place in: `android/app/`
8. Click **Next** twice → **Continue to console**

#### Register iOS App
1. Click **iOS** icon (or "Add app" → iOS)
2. **Bundle ID**: `com.example.destinyDecoderApp` (from ios/Runner/Info.plist)
   - Check: `ios/Runner.xcodeproj/project.pbxproj` for actual bundle ID
3. **App nickname**: `Destiny Decoder iOS`
4. **App Store ID**: Leave blank (not needed for development)
5. Click **Register app**
6. Download `GoogleService-Info.plist`
7. [See Step 3.2 for where to place it]
8. Click **Next** twice → **Continue to console**

### Step 1.3: Get Android SHA-1 Certificate Hash (Required!)

**Option A: Using Gradle (Recommended)**
```bash
# In terminal, navigate to android folder
cd android

# Run this command
./gradlew signingReport

# Look for output like:
# Variant: debug
# Config: debug
# Store: ~/.android/keystore
# Alias: ...
# MD5: ...
# SHA1: AA:BB:CC:DD:...  <-- COPY THIS
# SHA-256: ...
```

Copy the **SHA1** value (the one with colons).

**Option B: Manual (if gradle fails)**
```bash
# If using default debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# On Windows:
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Once you have SHA1 (e.g., `AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD`):
1. Go back to Firebase Console
2. Android app settings → **Add fingerprint**
3. Paste the SHA1 value
4. Click **Save**

---

## Phase 2: Android Configuration

### Step 2.1: Add google-services.json
1. You downloaded `google-services.json` in Phase 1
2. Place it at: `android/app/google-services.json`
3. Verify path is correct: `ls android/app/google-services.json`

### Step 2.2: Update Android build.gradle Files

**File: `android/build.gradle` (project-level)**

Add Google services plugin (if not already present):

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // ... existing dependencies ...
        classpath 'com.google.gms:google-services:4.3.15'  // Add this line
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

**File: `android/app/build.gradle` (app-level)**

Add at the END of file (after android block):

```gradle
apply plugin: 'com.google.gms.google-services'  // Add this line at the very end
```

### Step 2.3: Update AndroidManifest.xml

**File: `android/app/src/main/AndroidManifest.xml`**

Add these permissions inside `<manifest>` tag (if not already present):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.destiny_decoder_app">

    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <application>
        <!-- ... rest of configuration ... -->
    </application>
</manifest>
```

### Step 2.4: Verify Firebase Dependency

**File: `android/app/build.gradle`**

Make sure Firebase dependencies are present in `dependencies` block:

```gradle
dependencies {
    // ... existing dependencies ...
    
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-analytics'
}
```

---

## Phase 3: iOS Configuration

### Step 3.1: Add GoogleService-Info.plist

1. You downloaded `GoogleService-Info.plist` in Phase 1
2. Open Xcode:
   ```bash
   cd ios
   open Runner.xcworkspace  # NOT Runner.xcodeproj
   ```
3. Right-click **Runner** in Xcode → **Add Files to "Runner"**
4. Select the `GoogleService-Info.plist` file
5. Make sure:
   - ✅ **Copy items if needed** is checked
   - ✅ **Add to targets: Runner** is checked
6. Click **Add**
7. Verify: Drag `GoogleService-Info.plist` into Xcode window to see it listed

### Step 3.2: Update iOS Podfile

**File: `ios/Podfile`**

Find the `target 'Runner' do` section and add:

```ruby
target 'Runner' do
  flutter_root = File.expand_path(File.join(packages_config_directory, '..', '..'))
  load File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper')

  flutter_ios_podfile_setup

  # Add this pod
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_post_install(installer, target)
    end
  end
end
```

### Step 3.3: Update Info.plist for Push Notifications

**File: `ios/Runner/Info.plist`**

Add these keys inside the `<dict>` section:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

(These allow iOS to handle notifications in background)

### Step 3.4: Enable Push Capability in Xcode

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select **Runner** project (left sidebar)
3. Select **Runner** target
4. Go to **Signing & Capabilities** tab
5. Click **+ Capability** button
6. Search for **"Push Notifications"**
7. Select and add it
8. Verify it appears in the Signing & Capabilities list

### Step 3.5: Clean and Get Pods

```bash
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks/
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

cd ..
flutter clean
flutter pub get

cd ios
pod install --repo-update

cd ..
```

---

## Phase 4: Flutter Integration

### Step 4.1: Add Flutter Firebase Packages

**File: `pubspec.yaml`**

Add these dependencies in the `dependencies` section:

```yaml
dependencies:
  # ... existing dependencies ...
  firebase_core: ^2.24.0
  firebase_messaging: ^14.6.0
  firebase_analytics: ^10.7.0
```

### Step 4.2: Install Dependencies

```bash
flutter pub get
```

### Step 4.3: Create Firebase Service File

**File: `lib/core/firebase/firebase_service.dart`**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal();
  
  late FirebaseMessaging _firebaseMessaging;
  
  /// Initialize Firebase
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _firebaseMessaging = FirebaseMessaging.instance;
      
      // Request permission for notifications (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carryforward: true,
        criticalSound: false,
        provisional: false,
        sound: true,
      );
      
      print('User granted permission: ${settings.authorizationStatus}');
      
      // Set up foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message: ${message.notification?.title}');
        _handleMessage(message);
      });
      
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      
      return token;
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }
  
  /// Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }
  
  /// Register token with your backend
  Future<void> registerTokenWithBackend(String token) async {
    try {
      // TODO: Call your backend API to save token
      // POST /api/notifications/tokens/register
      // Payload: { "token": token, "platform": "android|ios" }
      print('Register token with backend: $token');
    } catch (e) {
      print('Error registering token: $e');
    }
  }
  
  /// Handle incoming message
  static void _handleMessage(RemoteMessage message) {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
    
    // TODO: Handle notification (show snackbar, navigate, etc.)
  }
}

/// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // TODO: Handle background notification
}
```

### Step 4.4: Create Firebase Options File

**File: `lib/core/firebase/firebase_options.dart`**

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions has not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions has not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions has not been configured for the current platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',  // From google-services.json
    appId: 'YOUR_ANDROID_APP_ID',    // From google-services.json
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',  // From google-services.json
    projectId: 'destiny-decoder',
    storageBucket: 'destiny-decoder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',  // From GoogleService-Info.plist
    appId: 'YOUR_IOS_APP_ID',    // From GoogleService-Info.plist
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',  // From GoogleService-Info.plist
    projectId: 'destiny-decoder',
    storageBucket: 'destiny-decoder.appspot.com',
    iosBundleId: 'com.example.destinyDecoderApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'destiny-decoder',
    storageBucket: 'destiny-decoder.appspot.com',
    iosBundleId: 'com.example.destinyDecoderApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'destiny-decoder',
    storageBucket: 'destiny-decoder.appspot.com',
  );
}
```

**To fill in the values above**:
1. Go to Firebase Console → Project Settings (gear icon)
2. Go to **Service Accounts** tab
3. Copy `messagingSenderId` value
4. Go to **General** tab
5. Scroll down to see Web API Key and other platform-specific keys
6. Copy and paste into the file above

### Step 4.5: Initialize Firebase in main.dart

**File: `lib/main.dart`**

```dart
import 'core/firebase/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService().initialize();
  
  runApp(const MyApp());
}
```

### Step 4.6: Create Analytics Service

**File: `lib/core/analytics/analytics_service.dart`**

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }
  
  /// Log calculation completed
  static Future<void> logCalculationCompleted(int lifeSeal) async {
    await _analytics.logEvent(
      name: 'calculation_completed',
      parameters: {
        'life_seal': lifeSeal,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// Log PDF export
  static Future<void> logPdfExport() async {
    await _analytics.logEvent(
      name: 'pdf_exported',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// Log reading saved
  static Future<void> logReadingSaved() async {
    await _analytics.logEvent(
      name: 'reading_saved',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// Set user property
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
```

---

## Phase 5: Backend Python Setup

### Step 5.1: Install Python Firebase Admin SDK

```bash
pip install firebase-admin

# Add to requirements.txt
echo "firebase-admin==6.2.0" >> requirements.txt
```

### Step 5.2: Download Service Account Key

1. Firebase Console → **Project Settings** (gear icon)
2. **Service Accounts** tab
3. Click **Generate New Private Key**
4. Save as `firebase-service-account-key.json`
5. Place in: `backend/` directory (root of backend)
6. **⚠️ IMPORTANT**: Add to `.gitignore`:
   ```
   firebase-service-account-key.json
   ```

### Step 5.3: Create Firebase Admin Service

**File: `backend/app/services/firebase_admin_service.py`**

```python
import firebase_admin
from firebase_admin import credentials, messaging
from pathlib import Path
import os
from typing import Optional, List
import logging

logger = logging.getLogger(__name__)

class FirebaseAdminService:
    """Service to interact with Firebase Cloud Messaging"""
    
    _instance = None
    _initialized = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not FirebaseAdminService._initialized:
            self._initialize_firebase()
            FirebaseAdminService._initialized = True
    
    @staticmethod
    def _initialize_firebase():
        """Initialize Firebase Admin SDK"""
        try:
            # Path to service account key
            service_account_path = Path(__file__).parent.parent.parent / "firebase-service-account-key.json"
            
            if not service_account_path.exists():
                logger.warning(f"Firebase service account key not found at {service_account_path}")
                logger.warning("Firebase messaging will be disabled")
                return
            
            # Initialize Firebase
            cred = credentials.Certificate(str(service_account_path))
            firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin SDK initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
            raise
    
    @staticmethod
    def send_notification(
        token: str,
        title: str,
        body: str,
        data: Optional[dict] = None
    ) -> Optional[str]:
        """
        Send notification to a single device
        
        Args:
            token: FCM device token
            title: Notification title
            body: Notification body
            data: Additional data payload
            
        Returns:
            Message ID if successful, None otherwise
        """
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                token=token,
            )
            
            message_id = messaging.send(message)
            logger.info(f"Notification sent to {token}: {message_id}")
            return message_id
            
        except Exception as e:
            logger.error(f"Failed to send notification to {token}: {e}")
            return None
    
    @staticmethod
    def send_multicast(
        tokens: List[str],
        title: str,
        body: str,
        data: Optional[dict] = None
    ) -> dict:
        """
        Send notification to multiple devices
        
        Args:
            tokens: List of FCM device tokens
            title: Notification title
            body: Notification body
            data: Additional data payload
            
        Returns:
            Dict with success_count, failure_count, failures list
        """
        try:
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                tokens=tokens,
            )
            
            response = messaging.send_multicast(message)
            
            logger.info(
                f"Multicast notification sent: "
                f"success={response.success_count}, "
                f"failure={response.failure_count}"
            )
            
            return {
                "success_count": response.success_count,
                "failure_count": response.failure_count,
                "failures": response.errors,
            }
            
        except Exception as e:
            logger.error(f"Failed to send multicast notification: {e}")
            return {
                "success_count": 0,
                "failure_count": len(tokens),
                "failures": [str(e)],
            }
    
    @staticmethod
    def send_topic_notification(
        topic: str,
        title: str,
        body: str,
        data: Optional[dict] = None
    ) -> Optional[str]:
        """
        Send notification to all subscribers of a topic
        
        Args:
            topic: Topic name (e.g., 'daily_insights')
            title: Notification title
            body: Notification body
            data: Additional data payload
            
        Returns:
            Message ID if successful, None otherwise
        """
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                topic=topic,
            )
            
            message_id = messaging.send(message)
            logger.info(f"Topic notification sent to '{topic}': {message_id}")
            return message_id
            
        except Exception as e:
            logger.error(f"Failed to send topic notification: {e}")
            return None
```

### Step 5.4: Update Backend Models to Store FCM Tokens

**File: `backend/app/models/notification_models.py`** (create if doesn't exist)

```python
from sqlalchemy import Column, String, DateTime, Boolean, Integer
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class FCMToken(Base):
    """Store FCM tokens for push notifications"""
    __tablename__ = "fcm_tokens"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=True, index=True)  # Optional: if you have user accounts
    token = Column(String, unique=True, index=True, nullable=False)
    platform = Column(String, nullable=False)  # 'android' or 'ios'
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_used = Column(DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f"<FCMToken token={self.token[:20]}... platform={self.platform}>"


class NotificationPreference(Base):
    """User's notification preferences"""
    __tablename__ = "notification_preferences"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, unique=True, index=True, nullable=True)
    daily_insights = Column(Boolean, default=True)
    blessed_days = Column(Boolean, default=True)
    weekly_forecast = Column(Boolean, default=True)
    personal_month = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f"<NotificationPreference user_id={self.user_id}>"
```

### Step 5.5: Create Notification API Routes

**File: `backend/app/api/routes/notifications.py`** (update existing file)

```python
from fastapi import APIRouter, HTTPException, status, Depends
from typing import Optional
from datetime import datetime
import logging

from ..schemas import TokenRequest, TokenResponse
from ...services.firebase_admin_service import FirebaseAdminService

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/notifications", tags=["notifications"])

firebase_service = FirebaseAdminService()

@router.post("/tokens/register", response_model=TokenResponse)
async def register_fcm_token(request: TokenRequest):
    """
    Register FCM token for push notifications
    
    Parameters:
    - token: FCM device token
    - platform: 'android' or 'ios'
    - user_id: Optional user ID (if using accounts)
    
    Returns:
    - Confirmation with token registered status
    """
    try:
        # TODO: Save token to database
        # db.add(FCMToken(token=request.token, platform=request.platform))
        # db.commit()
        
        return {
            "success": True,
            "message": f"Token registered for {request.platform}",
            "token": request.token[:20] + "...",
        }
    except Exception as e:
        logger.error(f"Error registering token: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.post("/send-test")
async def send_test_notification(token: str):
    """
    Send test notification to verify setup
    
    Used for debugging and validation only
    """
    try:
        message_id = firebase_service.send_notification(
            token=token,
            title="Test Notification",
            body="This is a test notification from Destiny Decoder"
        )
        
        if message_id:
            return {
                "success": True,
                "message": f"Test notification sent",
                "message_id": message_id,
            }
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to send notification"
            )
            
    except Exception as e:
        logger.error(f"Error sending test notification: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.post("/daily-insight")
async def send_daily_insight_notification(
    token: str,
    life_seal: int,
    power_number: int
):
    """
    Send daily insight notification
    
    Parameters:
    - token: FCM device token
    - life_seal: User's life seal number
    - power_number: Today's power number
    
    Returns:
    - Success status and message ID
    """
    try:
        message_id = firebase_service.send_notification(
            token=token,
            title=f"Your Power Number Today is {power_number}",
            body="Tap to explore your daily insight",
            data={
                "type": "daily_insight",
                "life_seal": str(life_seal),
                "power_number": str(power_number),
            }
        )
        
        if message_id:
            return {
                "success": True,
                "message_id": message_id,
            }
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to send notification"
            )
            
    except Exception as e:
        logger.error(f"Error sending daily insight: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
```

### Step 5.6: Create Notification Scheduler

**File: `backend/app/services/notification_scheduler.py`**

```python
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from datetime import datetime, timedelta
import logging

from .firebase_admin_service import FirebaseAdminService
from ..core.numerology import calculate_power_number, get_blessed_status

logger = logging.getLogger(__name__)
scheduler = BackgroundScheduler()
firebase_service = FirebaseAdminService()

class NotificationScheduler:
    """Schedule and send notifications at specific times"""
    
    @staticmethod
    def start_scheduler():
        """Start the background scheduler"""
        if not scheduler.running:
            # Schedule daily insights at 8 AM
            scheduler.add_job(
                NotificationScheduler.send_daily_insights,
                CronTrigger(hour=8, minute=0),
                id='daily_insights',
                name='Send daily insights',
                replace_existing=True,
            )
            
            # Schedule blessed day notifications at 7 AM
            scheduler.add_job(
                NotificationScheduler.send_blessed_day_alerts,
                CronTrigger(hour=7, minute=0),
                id='blessed_days',
                name='Send blessed day alerts',
                replace_existing=True,
            )
            
            # Schedule weekly reflection on Sunday at 6 PM
            scheduler.add_job(
                NotificationScheduler.send_weekly_reflection,
                CronTrigger(day_of_week=6, hour=18, minute=0),  # Sunday
                id='weekly_reflection',
                name='Send weekly reflection',
                replace_existing=True,
            )
            
            scheduler.start()
            logger.info("Notification scheduler started")
        else:
            logger.info("Scheduler already running")
    
    @staticmethod
    def stop_scheduler():
        """Stop the background scheduler"""
        if scheduler.running:
            scheduler.shutdown()
            logger.info("Notification scheduler stopped")
    
    @staticmethod
    def send_daily_insights():
        """Send daily insight notifications to all users"""
        try:
            logger.info("Executing daily insights job...")
            
            # TODO: Get all active users with notifications enabled
            # TODO: For each user:
            #   - Get their life seal from database
            #   - Calculate power number for today
            #   - Get their FCM tokens
            #   - Send notification via firebase_service.send_multicast()
            
            logger.info("Daily insights sent successfully")
            
        except Exception as e:
            logger.error(f"Error in daily insights job: {e}")
    
    @staticmethod
    def send_blessed_day_alerts():
        """Send blessed day notifications"""
        try:
            logger.info("Executing blessed day alerts job...")
            
            # TODO: Get all active users with blessed day notifications enabled
            # TODO: For each user:
            #   - Get their life seal from database
            #   - Check if today is blessed day
            #   - Send notification if blessed
            
            logger.info("Blessed day alerts sent successfully")
            
        except Exception as e:
            logger.error(f"Error in blessed day alerts job: {e}")
    
    @staticmethod
    def send_weekly_reflection():
        """Send weekly reflection notifications"""
        try:
            logger.info("Executing weekly reflection job...")
            
            # TODO: Get all active users with weekly notifications enabled
            # TODO: For each user:
            #   - Send weekly reflection prompt
            #   - Include weekly themes data
            
            logger.info("Weekly reflections sent successfully")
            
        except Exception as e:
            logger.error(f"Error in weekly reflection job: {e}")
```

### Step 5.7: Install APScheduler

```bash
pip install apscheduler

# Add to requirements.txt
echo "apscheduler==3.10.4" >> requirements.txt
```

### Step 5.8: Initialize Scheduler in main.py

**File: `backend/main.py`**

```python
from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.services.notification_scheduler import NotificationScheduler

# Create lifespan context manager
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    NotificationScheduler.start_scheduler()
    yield
    # Shutdown
    NotificationScheduler.stop_scheduler()

app = FastAPI(lifespan=lifespan)

# ... rest of your FastAPI setup ...
```

---

## Phase 6: Testing

### Step 6.1: Test FCM Token Registration

```bash
# Test registering a token (get a real token from your app first)
curl -X POST "http://localhost:8000/api/notifications/tokens/register" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "your_fcm_token_here",
    "platform": "android"
  }'
```

### Step 6.2: Test Sending Notification

```bash
# Replace with actual token from your device
curl -X POST "http://localhost:8000/api/notifications/send-test?token=YOUR_FCM_TOKEN" \
  -H "Content-Type: application/json"
```

### Step 6.3: Manual Testing on Device

**For Android:**
1. Build and run: `flutter run`
2. Check Android Studio logcat for FCM token
3. Copy token
4. Use curl command from Step 6.2 to send test notification
5. Should receive notification on device

**For iOS:**
1. Build and run: `flutter run -d iPhone` (or simulator)
2. Check Xcode console for FCM token
3. Copy token
4. Use curl command from Step 6.2
5. Should receive notification on device

### Step 6.4: Check Logs

**Backend logs**:
```bash
# If using uvicorn
uvicorn backend.main:app --reload --log-level debug
```

Look for:
- `Firebase Admin SDK initialized successfully`
- `Notification sent to {token}:`
- `Scheduler started`

**Flutter logs**:
```bash
flutter run
```

Look for:
- `FCM Token: ...`
- `Foreground message: ...`

---

## Troubleshooting

### Issue 1: "google-services.json not found"
**Solution**:
- Check file is at `android/app/google-services.json`
- Verify package name in google-services.json matches your app's package name
- Run: `flutter clean && flutter pub get`

### Issue 2: "SHA-1 Certificate not valid"
**Solution**:
- Generate new SHA-1 using: `./gradlew signingReport`
- Add the EXACT SHA-1 value to Firebase Console
- Run: `flutter clean`

### Issue 3: iOS pod install fails
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock .symlinks/
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### Issue 4: "Firebase App not initialized"
**Solution**:
- Ensure `GoogleService-Info.plist` is added to Xcode (not just file system)
- Check in Xcode: Runner → Build Phases → Copy Bundle Resources (should list the plist)
- Restart Xcode

### Issue 5: Notifications not received
**Solution**:
- Verify FCM token registered successfully
- Check Firebase Console → Cloud Messaging for any errors
- Test with sending test notification first
- Check app has notification permission granted
- On Android: Check notification channels are set up
- On iOS: Check notification permission dialog was accepted

### Issue 6: "Flask/FastAPI app crashes after Firebase init"
**Solution**:
- Firebase Admin SDK is singleton, initialize once
- Use lifespan context manager as shown in Step 5.8
- Check firebase-service-account-key.json path is correct
- File should be at `backend/firebase-service-account-key.json`

### Issue 7: "Module 'firebase_admin' not found"
**Solution**:
```bash
pip install firebase-admin==6.2.0
pip install apscheduler==3.10.4

# Verify installation
python -c "import firebase_admin; print(firebase_admin.__version__)"
```

---

## Next Steps After Setup

1. **Wire up database** (Step 5.4): Actually store tokens in DB
2. **Complete scheduler jobs** (Step 5.6): Implement the TODO sections
3. **Add analytics tracking** (Phase 4.6): Log when notifications are sent
4. **Test end-to-end**: Register token → Send notification → Verify receipt
5. **Deploy to Firebase Hosting**: (Optional for web)

---

## File Structure Checklist

```
✅ android/app/google-services.json
✅ android/app/src/main/AndroidManifest.xml (with POST_NOTIFICATIONS permission)
✅ android/build.gradle (with google-services plugin)
✅ android/app/build.gradle (with firebase dependencies)
✅ ios/Runner/GoogleService-Info.plist (added via Xcode)
✅ ios/Runner/Info.plist (with push notification keys)
✅ ios/Podfile (with Firebase pods)
✅ pubspec.yaml (with firebase packages)
✅ lib/core/firebase/firebase_service.dart
✅ lib/core/firebase/firebase_options.dart
✅ lib/core/analytics/analytics_service.dart
✅ lib/main.dart (with Firebase initialization)
✅ backend/firebase-service-account-key.json (in .gitignore!)
✅ backend/app/services/firebase_admin_service.py
✅ backend/app/services/notification_scheduler.py
✅ backend/app/models/notification_models.py
✅ backend/app/api/routes/notifications.py
✅ backend/main.py (with lifespan and scheduler)
✅ requirements.txt (with firebase-admin and apscheduler)
```

---

## Success Indicators

When setup is complete, you should be able to:
- ✅ See FCM token logged on app startup
- ✅ Send test notification via curl
- ✅ Receive notification on device
- ✅ See notification in Firebase Console metrics
- ✅ See all logs in backend console

Good luck! 🚀

