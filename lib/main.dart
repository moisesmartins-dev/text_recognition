import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool visibleImage = false;
  bool visibleText = false;
  List<RecognizedText> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    getFromGallery();
                  },
                  child: const Text('From gallery'),
                ),
                ElevatedButton(
                  onPressed: () {
                    getFromCamera();
                  },
                  child: const Text('From camera'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (visibleImage) Image.file(_image!, height: 300),
            const SizedBox(height: 30),
            if (visibleImage)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    visibleImage = false;
                    visibleText = false;
                  });
                },
                child: const Text('delete photo'),
              ),
            const SizedBox(height: 50),
            if (visibleText)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.builder(
                  itemBuilder: (context, index) => SelectableText(list[index].text),
                  shrinkWrap: true,
                  itemCount: list.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> getFromGallery() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    list = await getText(pickedImage!.path);
    // var teste = list.where((element) => element.text.toLowerCase().contains('cpf'));
    // log('alooooo $teste');
    if (pickedImage != null) {
      setState(() {
        visibleImage = true;
        visibleText = true;
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> getFromCamera() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);
    list = await getText(pickedImage!.path);
    if (pickedImage != null) {
      setState(() {
        visibleImage = true;
        visibleText = true;
        _image = File(pickedImage.path);
      });
    }
  }

  Future<List<RecognizedText>> getText(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textDetector.processImage(inputImage);

    List<RecognizedText> recognizedList = [];

    for (TextBlock block in recognizedText.blocks) {
      // recognizedList.add(RecognizedText(lines: block.lines, block: block.text.toLowerCase()));
      recognizedList.add(RecognizedText(block.text, recognizedText.blocks));
    }

    for (RecognizedText recognizedText in recognizedList) {
      log('texto ====  ${recognizedText.text}');
    }
    return recognizedList;
  }
}
