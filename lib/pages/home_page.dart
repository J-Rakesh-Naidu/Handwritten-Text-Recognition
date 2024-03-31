import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? selectedMedia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Text Recognition",
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFADD8E6), // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFADD8E6), Color(0xFFFFC0CB)], // Gradient colors
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: _buildUI(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickMedia,
            backgroundColor: Color(0xFFADD8E6),
            tooltip: 'Pick Image',
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _captureImage,
            backgroundColor: Color(0xFFADD8E6),
            tooltip: 'Capture Image',
            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  void _pickMedia() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      var data = File(pickedImage.path);
      setState(() {
        selectedMedia = data;
      });
    }
  }

  void _captureImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      var data = File(pickedImage.path);
      setState(() {
        selectedMedia = data;
      });
    }
  }

  Widget _buildUI() {
    return Center(
      child: selectedMedia == null
          ? Text(
              "Pick an image for text recognition.",
              style: TextStyle(fontSize: 18),
            )
          : FutureBuilder<String?>(
              future: _extractText(selectedMedia!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.file(selectedMedia!, width: 200),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SelectableText(
                            snapshot.data ?? "No text detected.",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
    );
  }

  Future<String?> _extractText(File file) async {
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    final InputImage inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    textRecognizer.close();
    return text;
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
