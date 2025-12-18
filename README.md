# Landformtifier-Landforms
# 🏔️ Landformtifier: AI-Powered Landform Identification

**Landformtifier** is a sophisticated mobile application built with Flutter that leverages Machine Learning to identify various geological landforms from images. Whether you're a student, a geologist, or a nature enthusiast, Landformtifier helps you explore and categorize the world around you with ease.

---

## 🚀 Features

### 🔍 Precision Identification
- **AI-Powered Analysis**: Uses a custom-trained TensorFlow Lite (TFLite) model to classify landforms with high confidence.
- **Dual Mode Input**: Snapshot a photo directly using the **Camera** or pick an existing image from your **Gallery**.
- **Real-time Feedback**: Get instant predictions with confidence percentages.

### 📊 Advanced Analytics
- **Historical Tracking**: Automatically logs every identification to the cloud.
- **Visual Insights**: Interactive bar charts and graphs powered by `fl_chart` to view distribution of identified landforms.
- **Metric Summaries**: Statistics on accuracy, frequency, and discovery progress.

### 🛠️ Human-in-the-Loop Training
- **Correction System**: Users can submit "corrections" if the AI identifies a landform incorrectly, helping build a dataset for future model fine-tuning.
- **Cloud Sync**: All corrections and logs are stored securely in **Firebase Realtime Database**.

### 👤 Profile & Gamification
- **Progress Tracking**: Monitor your discovery stats and total photos taken.
- **Achievements**: Unlock badges as you identify different types of landforms.
- **Personalized UI**: Sleek, modern design with Google Fonts (Roboto Slab) and glassmorphism elements.

---

## 🧠 Supported Landforms
The current model (v1.0) supports the identification of:
- 🌋 **Volcano**
- 🌄 **Hills**
- 🏝️ **Island**
- 🏜️ **Canyon**
- 🏜️ **Desert**
- 🏔️ **Mountains**
- 🗺️ **Plain**
- 🏖️ **Peninsula**
- 🕳️ **Cave**
- ⛰️ **Plateau**

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform)
- **Language**: Dart
- **Machine Learning**: [TensorFlow Lite](https://www.tensorflow.org/lite) (`tflite_flutter_plus`)
- **Backend/Database**: [Firebase Realtime Database](https://firebase.google.com/products/realtime-database)
- **Image Processing**: `image` & `camera` packages
- **UI/UX**: `google_fonts`, `fl_chart`, `convex_bottom_bar`

---

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (v3.0.0 or higher)
- Android Studio / VS Code
- A Firebase project (with `google-services.json` setup)

### Steps
1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/landform-identifier.git
   cd landform-identifier
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure Firebase**:
   - Place your `google-services.json` in `android/app/`.
4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```text
lib/
├── main.dart                 # Application entry point
├── home_page.dart            # Main navigation hub
├── identify_landform_page.dart # AI inference logic & camera/gallery UI
├── graph_page.dart           # Analytics and data visualization
├── profile_page.dart         # User stats and achievements
└── firebase_options.dart    # Firebase configuration
assets/
├── tflite/                   # TFLite Model & Labels
└── fonts/                    # Custom Typography
```

---

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---
*Developed with ❤️ for Landform Explorers.*
