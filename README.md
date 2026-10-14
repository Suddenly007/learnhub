# LearnHub starter (Flutter + Firebase)

One Flutter project, two apps:
- `lib/main_user.dart`  : learner app (sign up, browse published courses and lessons)
- `lib/main_admin.dart` : admin panel (create courses, upload lessons, publish/unpublish)

## Setup

1. Install Flutter, Node.js, and the Firebase CLI (`npm i -g firebase-tools`).
2. Create the project shell, then copy these files over it:
   ```
   flutter create learnhub
   cd learnhub
   # copy lib/, firestore.rules, storage.rules, firebase.json, tools/ from this starter
   flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage file_picker
   ```
3. In the Firebase console: create a project, enable **Authentication > Email/Password**, **Firestore**, and **Storage**.
   (Storage may require the pay-as-you-go plan on new projects; check the console.)
4. Connect the app (this generates `lib/firebase_options.dart`):
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
5. Deploy the security rules:
   ```
   firebase login
   firebase use <your-project-id>
   firebase deploy --only firestore:rules,storage
   ```
6. Make yourself an admin: sign up once in the user app, then
   ```
   cd tools && npm i firebase-admin
   # save your service account key as tools/serviceAccount.json (never commit it)
   node set_admin.js you@example.com
   ```
   Sign out and back in so the new claim is picked up.

## Run
```
flutter run -t lib/main_user.dart
flutter run -d chrome -t lib/main_admin.dart
```

## Known limits of this first step
- Lessons list and upload, but there are no video / audio / document viewers yet.
- Files are served via Firebase Storage download URLs (fine for testing; see notes on video streaming and signed access).
- Deleting a course does not remove its lessons or stored files.
