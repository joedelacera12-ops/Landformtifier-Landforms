import 'package:flutter/material.dart';
import 'landform_data.dart';
import 'landform_detail.dart';
import 'package:google_fonts/google_fonts.dart';

class LandformClassesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final landforms = getLandforms();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Landform Classes',
          style: GoogleFonts.robotoSlab(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Make it transparent
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Colors.blue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: landforms.length,
        itemBuilder: (context, index) {
          final landform = landforms[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 3,
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  landform.imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Return a placeholder widget if image fails to load
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
              title: Text(
                landform.name,
                style: GoogleFonts.robotoSlab(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LandformDetailPage(landform: landform),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}