import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.robotoSlab(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Colors.blue,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.green.withAlpha(51),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Landform Enthusiast',
                              style: GoogleFonts.robotoSlab(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Explorer of geological wonders',
                              style: GoogleFonts.robotoSlab(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Member since January 2025',
                              style: GoogleFonts.robotoSlab(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),

              // Statistics Section
              Text(
                "Statistics",
                style: GoogleFonts.robotoSlab(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStatItem(
                      icon: Icons.camera_alt,
                      title: "Photos Taken",
                      value: "42",
                    ),
                    Divider(height: 1),
                    _buildStatItem(
                      icon: Icons.category,
                      title: "Landform Types Identified",
                      value: "8",
                    ),
                    Divider(height: 1),
                    _buildStatItem(
                      icon: Icons.star,
                      title: "Highest Accuracy",
                      value: "96.7%",
                    ),
                    Divider(height: 1),
                    _buildStatItem(
                      icon: Icons.timer,
                      title: "Total Time Spent",
                      value: "12h 35m",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Landform Classes Section
              Center(
                child: Text(
                  "Landform Classes",
                  style: GoogleFonts.robotoSlab(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildClassItem("Volcano"),
                    Divider(height: 1),
                    _buildClassItem("Hills"),
                    Divider(height: 1),
                    _buildClassItem("Island"),
                    Divider(height: 1),
                    _buildClassItem("Canyon"),
                    Divider(height: 1),
                    _buildClassItem("Desert"),
                    Divider(height: 1),
                    _buildClassItem("Mountains"),
                    Divider(height: 1),
                    _buildClassItem("Plain"),
                    Divider(height: 1),
                    _buildClassItem("Peninsula"),
                    Divider(height: 1),
                    _buildClassItem("Cave"),
                    Divider(height: 1),
                    _buildClassItem("Plateau"),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Achievements Section
              Center(
                child: Text(
                  "Achievements",
                  style: GoogleFonts.robotoSlab(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildAchievementItem(
                      icon: Icons.explore,
                      title: "Landform Explorer",
                      description: "Classified 5 different landform types",
                      unlocked: true,
                    ),
                    Divider(height: 1),
                    _buildAchievementItem(
                      icon: Icons.camera_alt,
                      title: "Photo Enthusiast",
                      description: "Took 10 photos of landforms",
                      unlocked: true,
                    ),
                    Divider(height: 1),
                    _buildAchievementItem(
                      icon: Icons.star,
                      title: "Accuracy Master",
                      description: "Achieved 95%+ accuracy 3 times",
                      unlocked: false,
                    ),
                    Divider(height: 1),
                    _buildAchievementItem(
                      icon: Icons.public,
                      title: "Landform Expert",
                      description: "Unlock all achievements",
                      unlocked: false,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Settings Section
              Text(
                "Settings",
                style: GoogleFonts.robotoSlab(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.notifications,
                      title: "Notifications",
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeTrackColor: Colors.blue,
                      ),
                    ),
                    Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.dark_mode,
                      title: "Dark Mode",
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {},
                        activeTrackColor: Colors.blue,
                      ),
                    ),
                    Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.language,
                      title: "Language",
                      trailing: Text(
                        "English",
                        style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Logout Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Logout",
                            style: GoogleFonts.robotoSlab(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "Are you sure you want to logout?",
                            style: GoogleFonts.robotoSlab(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle logout logic here
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  },
  child: Text(
    "Logout",
    style: GoogleFonts.robotoSlab(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build stat items
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.robotoSlab(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.robotoSlab(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build class items
  Widget _buildClassItem(String className) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.green),
          SizedBox(width: 16),
          Text(
            className,
            style: GoogleFonts.robotoSlab(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build achievement items
  Widget _buildAchievementItem({
    required IconData icon,
    required String title,
    required String description,
    required bool unlocked,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: unlocked ? Colors.amber : Colors.grey,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: unlocked ? Colors.grey[800] : Colors.grey[500],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 14,
                    color: unlocked ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  // Helper method to build setting items
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.robotoSlab(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}