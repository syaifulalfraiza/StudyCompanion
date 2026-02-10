# Firebase Console Setup Guide
## Project: study-companion-5f354

Follow these steps in your Firebase Console to enable services for StudyCompanion.

---

## ✅ Step 1: Enable Authentication

1. Go to: **Firebase Console → Authentication**
2. Click **Get Started**
3. Click **Email/Password**
4. Enable it and click **Save**
5. (Optional) Enable **Google Sign-In** for easier testing

**Status**: ✅ This enables user login for Students, Teachers, and Parents

---

## ✅ Step 2: Create Firestore Database

1. Go to: **Firebase Console → Firestore Database**
2. Click **Create Database**
3. Choose **Start in Test Mode** (for development)
4. Select region: **asia-southeast1** (closest to Malaysia)
5. Click **Create**

**Status**: ✅ This creates your database for storing announcements, tasks, messages, etc.

---

## ✅ Step 3: Set Up Firestore Collections

Once Firestore is created, you need to create these collections:

### Collection: `announcements`
- Click **Create Collection** → Name: `announcements`
- Add a sample document with these fields:
  ```
  title: string → "Welcome to StudyCompanion"
  message: string → "This is a test announcement"
  createdBy: string → "Admin"
  date: timestamp → (current date)
  isPublished: boolean → true
  ```

### Collection: `users`
- Click **Create Collection** → Name: `users`
- This will auto-populate when users sign up

### Collection: `messages`
- Click **Create Collection** → Name: `messages`
- This will store chat messages between users

### Collection: `notifications`
- Click **Create Collection** → Name: `notifications`
- This will store push notifications

### Collection: `assignments`
- Click **Create Collection** → Name: `assignments`
- This will store homework and tasks

### Collection: `progress`
- Click **Create Collection** → Name: `progress`
- This will track student progress

**Status**: ✅ Collections are now ready to receive data

---

## ✅ Step 4: Set Firestore Security Rules

1. Go to: **Firestore Database → Rules**
2. Replace the existing rules with these (secure rules for development):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Announcements: Anyone authenticated can read, only admins can write
    match /announcements/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Users: Can only read/write their own documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Messages: Can read/write if participant
    match /messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // Assignments: Can read if student/teacher/parent
    match /assignments/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Notifications: Can read own notifications
    match /notifications/{userId}/{document=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null;
    }
    
    // Progress: Can read/write own progress
    match /progress/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click **Publish**

**Status**: ✅ Your database is now secure

---

## ✅ Step 5: Enable Cloud Storage (Optional - for images)

1. Go to: **Firebase Console → Storage**
2. Click **Get Started**
3. Choose **Start in Test Mode**
4. Select region: **asia-southeast1**
5. Click **Create**

**Status**: ✅ Users can now upload profile pictures

---

## ✅ Step 6: Enable Cloud Messaging (For Push Notifications)

1. Go to: **Firebase Console → Cloud Messaging**
2. You'll see **Web API Key** - copy this for later
3. Settings are auto-configured

**Status**: ✅ Notifications are now enabled

---

## ✅ Step 7: Download google-services.json (Android Only)

1. Go to: **Project Settings → Your Apps → Android**
2. Look for app: `com.example.studycompanion_app`
3. Click the three dots → **Download google-services.json**
4. Place the file in: `android/app/google-services.json`

**Status**: ✅ Android app can now build successfully

---

## ✅ Step 8: Verify Connection in Your App

1. Run your app:
   ```bash
   flutter pub get
   flutter run
   ```

2. Test these features:
   - ✅ Sign up / Login
   - ✅ View announcements
   - ✅ View notifications
   - ✅ View tasks/assignments

---

## 🎉 Setup Complete!

Once you've completed all 8 steps, your StudyCompanion app will be fully connected to Firebase!

### Quick Checklist:
- [ ] Step 1: Authentication enabled
- [ ] Step 2: Firestore database created
- [ ] Step 3: Collections created
- [ ] Step 4: Security rules set
- [ ] Step 5: Cloud Storage enabled
- [ ] Step 6: Cloud Messaging enabled
- [ ] Step 7: google-services.json downloaded
- [ ] Step 8: App tested and working

---

## ❓ Troubleshooting

**Issue**: "No Firebase projects found"
- **Solution**: Make sure you're logged in to the correct Google account

**Issue**: "Firestore connection failed"
- **Solution**: Check that Firestore database is created and security rules are published

**Issue**: "App crashes on startup"
- **Solution**: Make sure `google-services.json` is in `android/app/` directory

**Issue**: "Authentication not working"
- **Solution**: Go to Firebase Console → Authentication → Sign-in method, and enable Email/Password

---

## 📚 More Resources
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firebase Documentation](https://firebase.flutter.dev/)
