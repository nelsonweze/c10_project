import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:firebase_ml_custom/firebase_ml_custom.dart';

Future<File> loadModelFromFirebase() async {
  try {
    FirebaseCustomRemoteModel model =
        FirebaseCustomRemoteModel('Low-Score-Detector');
    FirebaseModelDownloadConditions conditions =
        FirebaseModelDownloadConditions(
            androidRequireWifi: true,
            androidRequireDeviceIdle: true,
            androidRequireCharging: true,
            iosAllowCellularAccess: false,
            iosAllowBackgroundDownloading: true);
    FirebaseModelManager modelManager = FirebaseModelManager.instance;
    await modelManager.download(model, conditions);
    assert(await modelManager.isModelDownloaded(model) == true);

    var modelFile = await modelManager.getLatestModelFile(model);
    assert(modelFile != null);
    return modelFile;
  } catch (exception) {
    print('Failed on loading your model from Firebase: $exception');
    print('The program will not be resumed');
    rethrow;
  }
}

Future<String> loadModel() async {
  final modelFile = await loadModelFromFirebase();
  return loadTFLiteModel(modelFile);
}

tfl.Interpreter _interpreter;


Future<String> loadTFLiteModel(File modelFile) async {
  try {
    _interpreter = tfl.Interpreter.fromFile(modelFile);
    return 'Model is loaded';
  } catch (exception) {
    print('Failed on loading your model to the TFLite interpreter: $exception');
    print('The program will not be resumed');
    rethrow;
  }
}

List<int> suggest(List<int> values) {
  var output = [0];
  _interpreter.run(values, output);
  return output;
}
