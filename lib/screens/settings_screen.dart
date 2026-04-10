import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- 1. THEME & SETTINGS LOGIC (Merged) ---
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            cardColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF3F5F9),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black87),
            ),
          );
  }
}

// --- 2. THE SETTINGS SCREEN (Detailed & Functional) ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Activity", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Section
            _buildUserCard(user, themeProvider),

            _buildSectionHeader("Appearance"),
            SwitchListTile(
              secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.amber),
              title: const Text("Dark Mode"),
              subtitle: Text(themeProvider.isDarkMode ? "Deep black theme active" : "Light theme active"),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),

            _buildSectionHeader("How you use Social Connect"),
            _buildListTile(
              context,
              Icons.history, 
              "Your Activity", 
              "Check how much time you spend and manage your interactions.",
              _showActivityDetails,
            ),
            _buildListTile(
              context,
              Icons.verified_user_outlined, 
              "Account Status", 
              "Check if your account has any strikes or restrictions.",
              _showAccountStatus,
            ),

            _buildSectionHeader("Who can see your content"),
            _buildListTile(
              context,
              Icons.lock_outline, 
              "Privacy & Security", 
              "Manage your blocked list, tags, and two-factor authentication.",
              _showPrivacyDetails,
            ),

            _buildSectionHeader("Support & Info"),
            _buildListTile(
              context,
              Icons.help_outline, 
              "Help Center", 
              "Get support or report a problem with the app.",
              _showHelpCenter,
            ),
            _buildListTile(
              context,
              Icons.info_outline, 
              "About", 
              "Version 2.0.1 - Made with Love at COMSATS.",
              _showAboutInfo,
            ),

            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () => FirebaseAuth.instance.signOut(),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildUserCard(User? user, ThemeProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple,
            child: Text(user?.email?[0].toUpperCase() ?? "U", style: const TextStyle(fontSize: 24, color: Colors.white)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.email ?? "User Email", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text("Active Member", style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.qr_code, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String subtitle, Function(BuildContext) onTap) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () => onTap(context),
    );
  }

  // --- DETAILED BOTTOM SHEETS (Functions) ---

  void _showAccountStatus(BuildContext context) {
    _showCustomSheet(context, "Account Status", Icons.verified, Colors.green, 
      "Your account is in good standing. No violations found. \n\nVerified Status: Active\nCommunity Guidelines: Passed");
  }

  void _showActivityDetails(BuildContext context) {
    _showCustomSheet(context, "Your Activity", Icons.bar_chart, Colors.blue, 
      "Daily Average: 45 Minutes\nPosts Shared: 12\nLikes Given: 156\n\nYou are in the top 10% of active users this week!");
  }

  void _showPrivacyDetails(BuildContext context) {
    _showCustomSheet(context, "Privacy & Security", Icons.security, Colors.orange, 
      "Two-Factor Authentication: ENABLED\nAccount Privacy: Public\nBlocked Contacts: 0\n\nYour data is encrypted with Firebase SSL.");
  }

  void _showHelpCenter(BuildContext context) {
    _showCustomSheet(context, "Help Center", Icons.contact_support, Colors.purple, 
      "Email: support@socialconnect.com\nTwitter: @SocialConnectSupport\n\nResponse time: Under 24 hours.");
  }

  void _showAboutInfo(BuildContext context) {
    _showCustomSheet(context, "About Social Connect", Icons.info, Colors.grey, 
      "Developed by: Rabeea Zakir\nReg No: SP23-BSE-032\nCampus: CUI Abbottabad\n\nSpecial thanks to Flutter and Firebase.");
  }

  void _showCustomSheet(BuildContext context, String title, IconData icon, Color color, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () => Navigator.pop(context), 
              child: const Text("Got it!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      ),
    );
  }
}