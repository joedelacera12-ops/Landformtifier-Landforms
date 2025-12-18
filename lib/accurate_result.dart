import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class PredictionDetail {
  final String label;
  final double confidence;

  PredictionDetail({required this.label, required this.confidence});
}

class AccurateResultPage extends StatefulWidget {
  @override
  _AccurateResultPageState createState() => _AccurateResultPageState();
}

class _AccurateResultPageState extends State<AccurateResultPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("predictions");
  List<Map<dynamic, dynamic>> _predictions = [];
  bool _isLoading = true;

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
        List<Map<dynamic, dynamic>> predictionsList = [];
        data.forEach((key, value) {
          if (value is Map) {
            predictionsList.add({
              'id': value['id'] ?? '',
              'className': value['className'] ?? 'Unknown',
              'accuracy': value['accuracy'] ?? '0.0000',
              'timestamp': value['timestamp'] ?? 0,
              'allPredictions':
                  value['allPredictions'] ?? [], // Fetch all predictions
              'firebaseKey': key, // Store the Firebase key for deletion
            });
          }
        });

        // Sort by timestamp in descending order (newest first)
        predictionsList.sort(
          (a, b) => b['timestamp'].compareTo(a['timestamp']),
        );

        setState(() {
          _predictions = predictionsList;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $error')));
    }
  }

  // Function to delete a prediction
  Future<void> _deletePrediction(String firebaseKey, int index) async {
    try {
      await _dbRef.child(firebaseKey).remove();

      // Update the local list
      setState(() {
        _predictions.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prediction deleted successfully')),
      );
    } catch (error) {
      print('Error deleting prediction: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting prediction: $error')),
      );
    }
  }

  // Function to confirm deletion
  void _confirmDelete(String firebaseKey, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this prediction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePrediction(firebaseKey, index);
              },
              child: Text('Delete', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return 'Unknown';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  // Function to build the detailed prediction breakdown dialog
  void _showPredictionDetails(Map<dynamic, dynamic> prediction) {
    // Extract all predictions
    List<PredictionDetail> allPreds = [];
    if (prediction['allPredictions'] is List) {
      for (var pred in prediction['allPredictions']) {
        if (pred is Map &&
            pred['label'] != null &&
            pred['confidence'] != null) {
          allPreds.add(
            PredictionDetail(
              label: pred['label'],
              confidence: pred['confidence'] is double
                  ? pred['confidence']
                  : double.tryParse(pred['confidence'].toString()) ?? 0.0,
            ),
          );
        }
      }
    }

    // Sort predictions by confidence (highest first)
    allPreds.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Calculate total confidence of displayed predictions
    double totalConfidence = allPreds.fold(
      0.0,
      (sum, pred) => sum + pred.confidence,
    );

    // Normalize predictions to ensure they sum to exactly 100%
    List<PredictionDetail> normalizedPredictions = [];
    double cumulativeSum = 0.0;

    for (int i = 0; i < allPreds.length; i++) {
      double normalizedConfidence;
      if (i == allPreds.length - 1) {
        // For the last item, use the remaining percentage to ensure total is exactly 100%
        normalizedConfidence = 1.0 - cumulativeSum;
      } else {
        // Normalize proportionally
        normalizedConfidence = allPreds[i].confidence / totalConfidence;
        cumulativeSum += normalizedConfidence;
      }

      normalizedPredictions.add(
        PredictionDetail(
          label: allPreds[i].label,
          confidence: normalizedConfidence,
        ),
      );
    }

    // Recalculate total confidence after normalization
    double normalizedTotalConfidence = normalizedPredictions.fold(
      0.0,
      (sum, pred) => sum + pred.confidence,
    );

    // Calculate remaining percentage for classes other than the top prediction
    double topPredictionConfidence = normalizedPredictions.isNotEmpty
        ? normalizedPredictions.first.confidence
        : 0.0;
    double remainingPercentage =
        normalizedTotalConfidence - topPredictionConfidence;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the sheet to take full height if needed
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.8, // Use 80% of screen height
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prediction Details',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Selected prediction info
              Container(
                padding: EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      prediction['className'],
                      style: GoogleFonts.robotoSlab(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Accuracy: ${(double.parse(prediction['accuracy']) * 100).toStringAsFixed(2)}%',
                      style: GoogleFonts.robotoSlab(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Recorded: ${_formatTimestamp(prediction['timestamp'])}',
                      style: GoogleFonts.robotoSlab(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Prediction breakdown header
              Text(
                'Full Prediction Breakdown',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Top Prediction: ${normalizedPredictions.isNotEmpty ? normalizedPredictions.first.label : 'N/A'} (${(topPredictionConfidence * 100).toStringAsFixed(2)}%)',
                style: GoogleFonts.robotoSlab(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Remaining ${((remainingPercentage) * 100).toStringAsFixed(2)}% distributed among ${normalizedPredictions.length > 1 ? normalizedPredictions.length - 1 : 0} other classes:',
                style: GoogleFonts.robotoSlab(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 8),

              // Scrollable predictions list
              Expanded(
                child: ListView.builder(
                  itemCount: normalizedPredictions.length,
                  itemBuilder: (context, index) {
                    final pred = normalizedPredictions[index];
                    double percentage = pred.confidence * 100;
                    bool isTopPrediction = index == 0;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                if (isTopPrediction)
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                SizedBox(width: isTopPrediction ? 4 : 0),
                                Expanded(
                                  child: Text(
                                    pred.label,
                                    style: GoogleFonts.robotoSlab(
                                      fontSize: 12,
                                      fontWeight: isTopPrediction
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${percentage.toStringAsFixed(2)}%',
                              style: GoogleFonts.robotoSlab(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: pred.confidence,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isTopPrediction
                                            ? const Color.fromARGB(
                                                255,
                                                255,
                                                102,
                                                0,
                                              )
                                            : const Color.fromARGB(
                                                255,
                                                253,
                                                219,
                                                27,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16),
              // Total
              Text(
                'Total: ${(normalizedTotalConfidence * 100).toStringAsFixed(2)}%',
                style: GoogleFonts.robotoSlab(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prediction History',
          style: GoogleFonts.robotoSlab(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        foregroundColor: Colors.white,
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _predictions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No prediction data available',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      prediction['className'],
                      style: GoogleFonts.robotoSlab(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.precision_manufacturing,
                              size: 16,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Accuracy: ${(double.parse(prediction['accuracy']) * 100).toStringAsFixed(2)}%',
                              style: GoogleFonts.robotoSlab(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              _formatTimestamp(prediction['timestamp']),
                              style: GoogleFonts.robotoSlab(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.blue),
                          onPressed: () =>
                              _confirmDelete(prediction['firebaseKey'], index),
                        ),
                        Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                    onTap: () {
                      // Show the detailed prediction breakdown
                      _showPredictionDetails(prediction);
                    },
                  ),
                );
              },
            ),
    );
  }
}