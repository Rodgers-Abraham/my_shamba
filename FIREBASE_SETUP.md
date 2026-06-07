// You need to register your app in the Firebase Console:
// 1. Go to https://console.firebase.google.com/
// 2. Add an Android app with the package name "com.example.My Shamba"
// 3. Download "google-services.json" and place it in the android/app/ directory

// For Android build configuration:
// 1. Add this to android/build.gradle.kts (project level):
//    plugins {
//        id("com.google.gms.google-services") version "4.4.2" apply false
//    }

// ... (existing content) ...

// 3. Firestore Security Rules:
// Go to the Firebase Console -> Firestore Database -> Rules tab.
// Paste the following rules to allow users to save their profiles and farm data:
//
// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//     // Users can only read/write their own profile
//     match /users/{userId} {
//       allow read, write: if request.auth != null && request.auth.uid == userId;
//     }
//     
//     // Authenticated users can manage their farms and all sub-data
//     // (This rule allows access to any document in 'farms' if logged in)
//     match /farms/{farmId} {
//       allow read, write: if request.auth != null;
//       
//       // Allows access to sub-collections like assets, ledger, harvests
//       match /{allSubcollections=**} {
//         allow read, write: if request.auth != null;
//       }
//     }
//   }
// }
