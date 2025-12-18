import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landform_identifier/home_page.dart'; // Import HomePage
import 'dart:async'; // Import for Timer

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Automatically navigate to HomePage after 3 seconds
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/background_image/background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Full-screen semi-transparent overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withAlpha(77),
          ),
          // Content overlay
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Content container
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // App Logo with direct shadow on image layer
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 10,
                      ),
                      child: PhysicalModel(
                        color: const Color.fromARGB(0, 255, 255, 255),
                        elevation: 8,
                        shadowColor: const Color.fromARGB(
                          255,
                          7,
                          7,
                          7,
                        ).withAlpha(51),
                        child: Image.asset(
                          'assets/background_image/logo.png',
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // App Title
                    Text(
                      'Landformtifier',
                      style: GoogleFonts.robotoSlab(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    // App Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Identify landforms with AI-powered image recognition',
                        style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: Colors.white.withAlpha(230),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: GoogleFonts.robotoSlab(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}