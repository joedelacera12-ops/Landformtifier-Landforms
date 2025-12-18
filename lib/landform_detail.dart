import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landform_data.dart';

class LandformDetailPage extends StatelessWidget {
  final Landform landform;

  const LandformDetailPage({Key? key, required this.landform}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          landform.name,
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Landform Image
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(51),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    landform.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Return a placeholder widget if image fails to load
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Landform Description
              Text(
                'About ${landform.name}',
                style: GoogleFonts.robotoSlab(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  landform.description,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Additional Information Section
              Text(
                'Additional Information',
                style: GoogleFonts.robotoSlab(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
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
                    _buildInfoItem(
                      icon: Icons.info,
                      title: "Classification",
                      value: "Geological Landform",
                    ),
                    Divider(height: 1),
                    _buildInfoItem(
                      icon: Icons.location_on,
                      title: "Common Locations",
                      value: _getCommonLocations(landform.name),
                    ),
                    Divider(height: 1),
                    _buildInfoItem(
                      icon: Icons.height,
                      title: "Typical Size",
                      value: _getTypicalSize(landform.name),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build info items
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green),
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
                    color: Colors.grey[800]!,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 14,
                    color: Colors.grey[600]!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get common locations for each landform
  String _getCommonLocations(String landformName) {
    switch (landformName) {
      case 'Volcano':
        return 'Pacific Ring of Fire, Iceland, Hawaii';
      case 'Hills':
        return 'Rolling countryside worldwide';
      case 'Island':
        return 'Oceans and seas globally';
      case 'Canyon':
        return 'Colorado Plateau, American Southwest';
      case 'Desert':
        return 'Sahara, Arabian Peninsula, Mojave';
      case 'Mountains':
        return 'Himalayas, Alps, Andes, Rockies';
      case 'Plain':
        return 'Central North America, Eurasian Steppe';
      case 'Peninsula':
        return 'Florida, Korean Peninsula, Italy';
      case 'Cave':
        return 'Limestone regions worldwide';
      case 'Plateau':
        return 'Tibetan Plateau, Colorado Plateau';
      default:
        return 'Various locations';
    }
  }

  // Helper method to get typical sizes for each landform
  String _getTypicalSize(String landformName) {
    switch (landformName) {
      case 'Volcano':
        return 'Variable, up to 10 km in diameter';
      case 'Hills':
        return 'Up to several kilometers high';
      case 'Island':
        return 'Few meters to thousands of kilometers';
      case 'Canyon':
        return 'Length: 10s-100s km, Depth: 100s m';
      case 'Desert':
        return 'Hundreds to thousands of square km';
      case 'Mountains':
        return 'Several to 8,000+ meters high';
      case 'Plain':
        return '10s to 1000s of square kilometers';
      case 'Peninsula':
        return 'Variable, from small to continental';
      case 'Cave':
        return 'Few meters to hundreds of kilometers';
      case 'Plateau':
        return '100s to 1000s of square kilometers';
      default:
        return 'Variable sizes';
    }
  }
}