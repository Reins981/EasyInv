// OCRUtils.dart

import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRUtils {

  Future<List<String>> processImage() async {
    final XFile? imageFile = await openCameraAndUpload();

    if (imageFile == null) return [];

    final inputImage = InputImage.fromFilePath(imageFile.path);

    final TextRecognizer textRecognizer =
    GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognisedText = await textRecognizer.processImage(inputImage);

    // Process the recognized text
    List<String> extractedText = [];
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        extractedText.add(line.text);
      }
    }

    textRecognizer.close();
    return extractedText;
  }

  // Function to open the camera and upload the photo to Firebase
  Future<XFile?> openCameraAndUpload() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return pickedFile;
    }
    return null;
  }
}
