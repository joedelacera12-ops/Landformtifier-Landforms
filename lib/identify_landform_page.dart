import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:firebase_database/firebase_database.dart';
import 'landform_data.dart'; // For class names if needed

class IdentifyLandformPage extends StatefulWidget {
  const IdentifyLandformPage({super.key});

  @override
  State<IdentifyLandformPage> createState() => _IdentifyLandformPageState();
}

class _IdentifyLandformPageState extends State<IdentifyLandformPage> {
  File? _image;
  bool _isCameraActive = false;
  bool _isProcessing = false;
  bool _modelLoaded = false;
  
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  
  Interpreter? _interpreter;
  List<String> _labels = [];
  
  // Prediction results
  String _predictionLabel = '';
  double _confidence = 0.0;
  List<Map<String, dynamic>> _topPredictions = [];

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("predictions");

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions();
      // Use metal delegate for iOS or gpu delegate for Android if available?
      // For now, keep it simple with default CPU
      
      _interpreter = await Interpreter.fromAsset('tflite/model_unquant.tflite', options: options);
      
      final labelData = await rootBundle.loadString('assets/tflite/labels.txt');

      _labels = labelData.split('\n').where((s) => s.isNotEmpty).map((s) {
        // CLEAN LABEL: Strip leading numbers (e.g. "0 Volcano" -> "Volcano")
        final parts = s.split(' ');
        if (parts.length > 1 && int.tryParse(parts[0]) != null) {
          return parts.sublist(1).join(' ');
        }
        return s;
      }).toList();
      
      setState(() {
        _modelLoaded = true;
      });
      debugPrint("Model loaded successfully");
    } catch (e) {
      debugPrint("Error loading model: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading AI model: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isCameraActive = false; // Disable camera preview if active
          _predictionLabel = ''; // Reset prediction
          _topPredictions = [];
        });
        
        // Auto-analyze
        _analyzeImage(_image!);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _toggleCamera() async {
    if (_isCameraActive) {
      // Close camera
      await _stopCamera();
    } else {
      // Open camera
      await _startCamera();
    }
  }

  Future<void> _startCamera() async {
    if (_cameras.isEmpty) {
      await _initializeCamera();
    }
    
    if (_cameras.isNotEmpty) {
      try {
        await _stopCamera(); // Stop if running
        
        _controller = CameraController(_cameras[0], ResolutionPreset.medium);
        await _controller!.initialize();
        
        setState(() {
          _isCameraActive = true;
          _image = null; // Clear static image
          _predictionLabel = '';
          _topPredictions = [];
        });
      } catch (e) {
        debugPrint("Error starting camera: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No camera available')),
      );
    }
  }

  Future<void> _stopCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    setState(() {
      _isCameraActive = false;
    });
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile file = await _controller!.takePicture();
        await _stopCamera(); // Stop camera preview
        
        setState(() {
          _image = File(file.path);
        });
        
        // Auto-analyze
        _analyzeImage(_image!);
      } catch (e) {
        debugPrint("Error capturing image: $e");
      }
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    if (!_modelLoaded || _interpreter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model not loaded yet')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Process Image
      final img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());
      if (originalImage == null) return;

      // Resize to 224x224 (typical for Teachable Machine models)
      final img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

      // 2. Convert to Float32List [1, 224, 224, 3]
      // Standard Teachable Machine export uses float32
      // Normalization is usually (pixel / 255.0) for standard models or ((pixel / 127.5) - 1) for Quantized/MobileNet
      // model_unquant.tflite usually is float32. We'll try pixel/255.0 first.
      
      var input = Float32List(1 * 224 * 224 * 3);
      var buffer = Float32List.view(input.buffer);
      int pixelIndex = 0;
      
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // image package v4 uses r,g,b accessors
           buffer[pixelIndex++] = (pixel.r - 127.5) / 127.5;
           buffer[pixelIndex++] = (pixel.g - 127.5) / 127.5;
           buffer[pixelIndex++] = (pixel.b - 127.5) / 127.5;
        }
      }

      // 3. Reshape input tensor [1, 224, 224, 3]
      final inputTensor = input.reshape([1, 224, 224, 3]);
      
      // 4. Output tensor [1, num_classes]
      final outputTensor = Float32List(1 * _labels.length).reshape([1, _labels.length]);

      // 5. Run Inference
      _interpreter!.run(inputTensor, outputTensor);

      // 6. Parse Results
      var outputBuffer = List<double>.from(outputTensor[0] as List);
      
      // CHECK: Apply Softmax if model outputs logits (raw scores)
      // If values are outside [0,1] or sum is significantly != 1.0, we apply softmax
      double sum = outputBuffer.fold(0, (a, b) => a + b);
      bool isLogits = outputBuffer.any((v) => v < 0 || v > 1) || sum < 0.9 || sum > 1.1;
      
      if (isLogits) {
        outputBuffer = _softmax(outputBuffer);
      }
      
      List<Map<String, dynamic>> predictions = [];
      for (int i = 0; i < outputBuffer.length; i++) {
        if (i < _labels.length) {
          predictions.add({
            'label': _labels[i],
            'confidence': outputBuffer[i],
          });
        }
      }
      
      // Sort by confidence
      predictions.sort((a, b) => b['confidence'].compareTo(a['confidence']));
      
      setState(() {
        _topPredictions = predictions;
        if (predictions.isNotEmpty) {
          _predictionLabel = predictions.first['label'];
          _confidence = predictions.first['confidence'];
          
          // Save result to Firebase (optional history)
          _savePredictionToHistory(_predictionLabel, _confidence);
        }
        _isProcessing = false;
      });

    } catch (e) {
      debugPrint("Error analyzing image: $e");
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    }
  }
  
  void _savePredictionToHistory(String label, double confidence) {
      try {
        final newRef = _dbRef.push();
        newRef.set({
          'id': newRef.key,
          'className': label,
          'accuracy': confidence.toString(),
          'timestamp': ServerValue.timestamp,
        });
      } catch (e) {
        debugPrint("Error saving to history: $e");
      }
  }

  void _showCorrectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Correct Prediction / Train'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _labels.length,
              itemBuilder: (context, index) {
                final label = _labels[index];
                return ListTile(
                  title: Text(label),
                  onTap: () {
                    // Save Correction
                     _saveCorrection(label);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveCorrection(String correctLabel) async {
    // Save correction data for future training
    // We store the original file path (if local) or similar, plus the correct label
    try {
        final correctionsRef = FirebaseDatabase.instance.ref("corrections");
        await correctionsRef.push().set({
            'original_prediction': _predictionLabel,
            'original_confidence': _confidence,
            'correct_label': correctLabel,
            'image_path': _image != null ? _image!.path : 'camera_capture', 
            'timestamp': ServerValue.timestamp,
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thanks! Correction saved for training.')),
        );
    } catch (e) {
        debugPrint("Error saving correction: $e");
    }
  }

  // Helper: Softmax function to convert logits to probabilities
  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return [];
    double maxLogit = logits.reduce(math.max);
    List<double> expValues = logits.map((l) => math.exp(l - maxLogit)).toList();
    double sumExp = expValues.reduce((a, b) => a + b);
    return expValues.map((e) => e / sumExp).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Identify Landform',
          style: GoogleFonts.robotoSlab(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Preview Area
          Expanded(
            child: Container(
              color: Colors.black,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                    if (_isCameraActive && _controller != null && _controller!.value.isInitialized)
                        CameraPreview(_controller!)
                    else if (_image != null)
                        Image.file(_image!, fit: BoxFit.contain)
                    else 
                        Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(Icons.image, color: Colors.grey, size: 60),
                                    const SizedBox(height: 10),
                                    Text('Select an image or take a photo', style: GoogleFonts.robotoSlab(color: Colors.grey)),
                                ],
                            ),
                        ),
                        
                    if (_isProcessing)
                        Container(
                            color: Colors.black54,
                            child: const Center(child: CircularProgressIndicator()),
                        ),
                ],
              ),
            ),
          ),
          
          // Results Area
          if (_predictionLabel.isNotEmpty && !_isCameraActive)
             Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                     color: Colors.white,
                     boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
                     borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                 ),
                 child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                         Text(
                             'Prediction: $_predictionLabel',
                             style: GoogleFonts.robotoSlab(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
                         ),
                         Text(
                             'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                             style: GoogleFonts.robotoSlab(fontSize: 16, color: Colors.grey[700]),
                         ),
                         const SizedBox(height: 10),
                         
                         // Correction / Train Button
                         OutlinedButton.icon(
                             onPressed: _showCorrectionDialog,
                             icon: const Icon(Icons.rate_review, size: 18),
                             label: const Text('Correct this Prediction (Train)'),
                        ),
                     ],
                 ),
             ),
             
          // Controls
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                    heroTag: "gallery",
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                    backgroundColor: Colors.green[700],
                ),
                const SizedBox(width: 20),
                FloatingActionButton.extended(
                    heroTag: "camera",
                    onPressed: _isCameraActive 
                        ? _captureImage 
                        : _toggleCamera,
                    icon: Icon(_isCameraActive ? Icons.camera : Icons.camera_alt),
                    label: Text(_isCameraActive ? "Capture" : "Camera"),
                    backgroundColor: Colors.blue[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _interpreter?.close();
    _controller?.dispose();
    super.dispose();
  }
}
