import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({Key? key}) : super(key: key);

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndOpenCamera();
    });
  }

  // ✅ CAMERA + STORAGE (PHOTOS) PERMISSION
  Future<bool> checkCameraAndStoragePermission() async {
    PermissionStatus cameraStatus = await Permission.camera.status;
    PermissionStatus photoStatus = await Permission.photos.status;

    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }

    if (!photoStatus.isGranted) {
      photoStatus = await Permission.photos.request();
    }

    if (cameraStatus.isGranted && photoStatus.isGranted) {
      return true;
    }

    if (cameraStatus.isPermanentlyDenied ||
        photoStatus.isPermanentlyDenied) {
      openAppSettings();
    }

    return false;
  }

  Future<void> checkAndOpenCamera() async {
    bool hasPermission = await checkCameraAndStoragePermission();

    if (hasPermission) {
      handleScan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera & storage permission required"),
        ),
      );
    }
  }

  // ✅ CAMERA SCAN + OCR
  Future<void> handleScan() async {
    try {
      setState(() => loading = true);

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 50,
      );

      if (pickedFile == null) {
        setState(() => loading = false);
        return;
      }

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText =
          await textRecognizer.processImage(inputImage);

      final lines = recognizedText.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();

      final rawText = lines.join('\n');

      String name = '', email = '', phone = '', company = '', address = '';

      final emailRegex =
          RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,20}\b');
      final phoneRegex =
          RegExp(r'(\+?\d{1,3}[-.\s]?)?(\(?\d{3,5}\)?[-.\s]?){2,3}\d{3,4}');
      final websiteRegex =
          RegExp(r'(www\.[^\s]+|https?:\/\/[^\s]+)', caseSensitive: false);

      final companyKeywords = [
        'solutions',
        'technologies',
        'pvt',
        'ltd',
        'inc',
        'corp',
        'systems'
      ];

      final addressKeywords = [
        'street',
        'road',
        'lane',
        'avenue',
        'building',
        'city',
        'state',
        'area',
        'zip'
      ];

      for (var line in lines) {
        final cleaned = line.replaceAll(' ', '').toLowerCase();

        if (email.isEmpty && emailRegex.hasMatch(line)) {
          email = emailRegex.firstMatch(line)!.group(0)!;
        }

        if (phone.isEmpty && phoneRegex.hasMatch(line)) {
          phone = phoneRegex.firstMatch(line)!.group(0)!;
        }

        if (company.isEmpty &&
            (companyKeywords.any((k) => cleaned.contains(k)) ||
                websiteRegex.hasMatch(line))) {
          company = line;
        }

        if (name.isEmpty &&
            RegExp(r'^[A-Z][a-zA-Z\s.]{2,40}$').hasMatch(line)) {
          name = line;
        }

        if (addressKeywords.any((k) => cleaned.contains(k))) {
          address = address.isEmpty ? line : '$address, $line';
        }
      }

      setState(() => loading = false);

      Navigator.pushNamed(context, '/enterCard', arguments: {
        'name': name,
        'designation': '',
        'email': email,
        'phone': phone,
        'company': company,
        'address': address,
        'scannedText': rawText,
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OCR Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 50),
                  backgroundColor: const Color(0xFFFFD84D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: checkAndOpenCamera,
                child: const Text(
                  "Scan Again",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
