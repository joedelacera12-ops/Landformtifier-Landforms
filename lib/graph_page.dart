import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("predictions");
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = true;
  Map<String, int> _classFrequency = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await _dbRef.orderByChild('timestamp').once();
      final data = snapshot.snapshot.value;

      if (data != null && data is Map) {
        List<Map<String, dynamic>> predictionsList = [];
        data.forEach((key, value) {
          if (value is Map) {
            predictionsList.add({
              'id': value['id'] ?? '',
              'className': value['className'] ?? 'Unknown',
              'accuracy': value['accuracy'] ?? '0.0000',
              'timestamp': value['timestamp'] ?? 0,
            });
          }
        });

        // Sort by timestamp in descending order (newest first)
        predictionsList.sort(
          (a, b) => b['timestamp'].compareTo(a['timestamp']),
        );

        setState(() {
          _predictions = predictionsList;
          _calculateClassFrequency();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $error')));
    }
  }

  void _calculateClassFrequency() {
    Map<String, int> frequency = {};
    
    for (var prediction in _predictions) {
      String className = prediction['className'] ?? 'Unknown';
      
      // Handle numeric prefixes (e.g., "0 Volcano")
      if (className.contains(' ')) {
        List<String> parts = className.split(' ');
        if (parts.length > 1 && int.tryParse(parts[0]) != null) {
          className = parts.sublist(1).join(' ');
        }
      }

      // Count frequency for every class found
      frequency[className] = (frequency[className] ?? 0) + 1;
    }

    setState(() {
      _classFrequency = frequency;
    });
  }

  List<FlSpot> _generateSpots() {
    List<FlSpot> spots = [];
    int index = 0;

    _classFrequency.forEach((className, count) {
      spots.add(FlSpot(index.toDouble(), count.toDouble()));
      index++;
    });

    return spots;
  }

  List<String> _getXAxisLabels() {
    List<String> labels = [];
    
    _classFrequency.forEach((className, count) {
      labels.add(className);
    });

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prediction Frequency',
          style: GoogleFonts.robotoSlab(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
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
        foregroundColor: Colors.white,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _fetchData)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _predictions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No prediction data available',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: Text('Refresh Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color
                      foregroundColor: Colors.white, // Text color
                    ),
                  ),
                ],
              ),
            )
          : _buildChart(),
    );
  }

  Widget _buildChart() {
    if (_classFrequency.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: GoogleFonts.robotoSlab(fontSize: 18),
        ),
      );
    }

    List<FlSpot> spots = _generateSpots();
    List<String> xAxisLabels = _getXAxisLabels();

    // Calculate max Y value and determine appropriate interval
    double maxYValue = _classFrequency.values.fold<double>(
      0,
      (max, value) => value > max ? value.toDouble() : max,
    );

    // Determine y-axis interval based on max value
    int yInterval = 1;
    if (maxYValue > 10) {
      yInterval = (maxYValue / 5).ceil(); // Show approximately 5 labels
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Frequency by Landform',
              style: GoogleFonts.robotoSlab(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Change title color to blue
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Shows how often each landform was predicted',
              style: GoogleFonts.robotoSlab(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            // Line chart
            SizedBox(
              height: 350,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 70,
                        interval: 1, // Show all labels
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < xAxisLabels.length) {
                            String className = xAxisLabels[index];
                            // Truncate long names for display
                            String displayName = className.length > 12
                                ? '${className.substring(0, 12)}..'
                                : className;
                            return Transform.rotate(
                              angle: -math.pi / 4, // Slant the text
                              child: Text(
                                displayName,
                                style: GoogleFonts.robotoSlab(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: yInterval
                            .toDouble(), // Dynamic interval to prevent overlap
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.robotoSlab(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: (_classFrequency.length - 1).toDouble(),
                  minY: 0,
                  maxY: (maxYValue * 1.2) + 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved:
                          false, // Make it straight for better readability
                      color: Colors.blue,
                      barWidth: 1,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 2,
                            color: Colors.green,
                            strokeWidth: 2,
                            strokeColor: Colors.greenAccent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withAlpha(100),
                            Colors.blue.withAlpha(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green, // Changed from Colors.green to a specific color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class Frequencies:',
            style: GoogleFonts.robotoSlab(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          // Organize class names on the left and frequencies on the right
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _classFrequency.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Class name on the left
                    Text(
                      entry.key,
                      style: GoogleFonts.robotoSlab(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Frequency on the right
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          2,
                          190,
                          80,
                        ), // Changed from Colors.green to a specific color
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: GoogleFonts.robotoSlab(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}