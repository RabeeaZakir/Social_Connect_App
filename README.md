Social Connect - Mobile App Development Internship Task
Social Connect is a minimal, real-time social media platform built using Flutter and Firebase. This project was developed as a 3-week internship task, demonstrating expertise in state management, real-time database integration, and professional UI/UX design.

🚀 Project Milestones
Week 1: Foundation & Authentication
Authentication: Secure Sign-Up, Login, and Forgot Password flows using Firebase Auth.

Profile Setup: User-centric profile creation and management.

Navigation: Robust navigation logic using BottomNavigationBar and Navigator stacks.

Week 2: Social Core & State Management
Real-time Feed: Dynamic feed fetching data directly from Cloud Firestore.

CRUD Operations: Users can Create, Edit, and Delete their own posts seamlessly.

Interactive Engagement: * Like System: Real-time toggling of likes with visual feedback.

Comment System: Interactive showModalBottomSheet for viewing and adding comments.

User Discovery: Navigable user profiles from the main feed.

State Management: Efficient global state handling using Provider.

Week 3: Polish, UI, & Notifications
Real-time Synchronization: Built using StreamBuilder for instantaneous UI updates (Likes/Comments).

Advanced UX:

Timestamp Formatting: Used timeago to display human-readable time (e.g., "5 minutes ago").

Interactive Notifications: Integrated flutter_local_notifications for real-time engagement alerts.

Performance: Optimized rendering and optimized try-catch blocks for robust error handling.

🛠️ Tech Stack
Frontend: Flutter (Dart)

Backend: Firebase (Cloud Firestore, Authentication)

State Management: Provider

Packages: timeago, flutter_local_notifications, lottie, firebase_core.

⚙️ Installation & Setup
Clone the repository:

Bash
git clone https://github.com/RabeeaZakir/social-connect-app.git
Setup Firebase:

Create a project in Firebase Console.

Place your google-services.json in the android/app/ directory.

Install dependencies:

Bash
flutter pub get
Run the app:

Bash
flutter run
Developed as part of a 3-week Mobile App Development Internship.
