# Social Connect 📱
**Minimal, Real-Time Social Media Platform**

Social Connect is a high-performance social media application built with **Flutter** and **Firebase**. Developed as a comprehensive 3-week internship project, it showcases real-time data synchronization, secure authentication, and a user-centric UI/UX.

---

## 🚀 Internship Milestones

### Week 1: Foundation & Security
* **Authentication:** Secure Sign-Up, Login, and Password Recovery using Firebase Auth.
* **Profile Architecture:** Personal user data management and profile setup.
* **Core Navigation:** Seamless transition between features using `BottomNavigationBar`.

### Week 2: Social Core & Real-time Interaction
* **Live Feed:** Dynamic content fetching using Cloud Firestore.
* **Full CRUD Operations:** Users can Create, Edit, and Delete posts with instant updates.
* **Engagement Engine:** * **Like System:** Real-time state toggling for post likes.
    * **Comment Module:** Interactive `showModalBottomSheet` for deep engagement.
* **Discovery:** Navigable user profiles directly from the feed.

### Week 3: Advanced UX & Optimization 
* **Real-time Sync:** Powered by `StreamBuilder` for zero-lag UI updates.
* **Notification System:** * **Interactive Popups:** In-app SnackBar alerts for likes and comments.
    * **Permanent History:** Cloud-stored notification center for persistence.
* **Robust Search:** Secure user discovery with fail-safe error handling for missing data fields.
* **Human-Readable UX:** Integrated `timeago` for intuitive timestamps.

---

## 🛠️ Tech Stack
* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Firestore & Auth)
* **State Management:** Provider / State-driven Streams
* **Key Packages:** `cloud_firestore`, `firebase_auth`, `timeago`, `lottie`

---

## ⚙️ Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/RabeeaZakir/social-connect-app.git](https://github.com/RabeeaZakir/social-connect-app.git)
# Setup Firebase:
Create a project in Firebase Console.
Place your google-services.json in the android/app/ directory.

# Install dependencies:
Bash
flutter pub get

# Run the app:
Bash
flutter run
