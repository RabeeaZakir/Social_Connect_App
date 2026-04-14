# 📱 Social Connect
Social Connect is a high-performance, real-time social media platform designed to provide a seamless user experience. Built with Flutter and Firebase, this project was developed as a comprehensive internship milestone at DevelopersHub Corporation. It demonstrates expertise in real-time data synchronization, secure cloud architecture, and modern UI/UX principles.

# ✨ Key Features
Real-Time Feed: Dynamic post fetching with instant UI updates using StreamBuilder.
Full CRUD Support: Users can create, edit, and delete posts with real-time Firestore synchronization.
Advanced Profile Management: * Custom Profile Grid (Instagram-style).
Dynamic Profile Editing (Name, Bio, and Profile Picture via URL).
Engagement Suite: * Like System: Real-time like/unlike toggling.
Comment Module: Interactive bottom-sheet comments.
Follow/Unfollow: Functional social graph with follower/following counts.
Search & Discovery: Robust user search functionality with fail-safe error handling.
Notification Engine: * In-app SnackBar alerts.
Persistent Notification Center stored in Cloud Firestore.

# 🚀 Internship Milestones
# Week 1: Foundation & Security
Authentication: Secure Sign-Up, Login, and Password Recovery using Firebase Auth.
Profile Architecture: Personal user data management and initial profile setup.
Core Navigation: Seamless transition using BottomNavigationBar.

# Week 2: Social Core & Interaction
Engagement Engine: Integrated a real-time Like system and interactive Comment modules using showModalBottomSheet.
User Connectivity: Developed navigable user profiles directly from the feed to enhance discovery.
Cloud Integration: Established Firestore structures for scalable post management.

# Week 3: Advanced UX & Optimization
Profile Grid & DP Fix: Implemented a professional grid view for user posts and a dynamic DP update system via image URLs.
Notification History: Created a permanent history center for likes and comments.
Performance: Optimized UI lag using specialized Stream handling and timeago for human-readable timestamps.

# 🛠️ Tech Stack
Frontend: Flutter (Dart)
Backend: Firebase (Firestore & Authentication)
Fonts: Google Fonts (Poppins / Montserrat)
Key Packages: * cloud_firestore (Database)
firebase_auth (Security)
timeago (UX)
google_fonts (Styling)

# ⚙️ Installation & Setup
Clone the Repository:

Bash
git clone https://github.com/RabeeaZakir/social-connect-app.git

# Firebase Configuration:
Create a project in the Firebase Console.
Register your Android/iOS app.
Download google-services.json and place it in android/app/.

# Install Dependencies:

Bash
flutter pub get
Run the Project:

Bash
flutter run


git push origin main
