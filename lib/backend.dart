import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

tfl.Interpreter _interpreter;

Future<void> loadTFLiteModel() async {
  try {
    _interpreter = await tfl.Interpreter.fromAsset('model.tflite');
    print('Model is loaded');
  } catch (exception) {
    print('Failed on loading your model to the TFLite interpreter: $exception');
    print('The program will not be resumed');
    rethrow;
  }
}

Map<String, String> courses = {
  'Faculty of Computer Sciences':
      'Applied Mathematics and Informatics, Computer Systems Engineering and Informatics, Information Systems and Technologies, Software Engineering',
  'Faculty of Radio and Telecommunication':
      'Radio Engineering, Communication Technologies and Communication Systems and Designing and Technology of Electronic Facilities',
  'Faculty of Electrical & Automation':
      'Electroenergetics and Electrical Engineering, Control in Technical Systems',
  'Faculty of Biotechnical Systems':
      'Instrumentation Technology,  Bioengineering Systems and Technologies, Technosphere safety',
  'Faculty of Electronics':
      'Electronics and Nanoelectronics,  Nanotechnologies and Microelectronics',
  'Faculty of Humanities':
      'Public Relations,  Linguistics and Intercultural Communication'
};

MapEntry<String, String> suggest(List<double> values) {
  var output = List<double>.filled(1 * 1, 0).reshape([1, 1]);
  _interpreter.run(values.reshape([1, 5]), output);
  var first = (output.first as List).first;
  if (first <= 0.5)
    return courses.entries.elementAt(0);
  else if (first > 0.5 && first < 1)
    return courses.entries.elementAt(1);
  else if (first > 1 && first < 1.5)
    return courses.entries.elementAt(2);
  else if (first > 1.5 && first < 2)
    return courses.entries.elementAt(3);
  else if (first > 2 && first < 2.5)
    return courses.entries.elementAt(4);
  else
    return courses.entries.elementAt(5);
}

saveUser({String key, String value, String uid, String email}) {
  return FirebaseFirestore.instance
      .doc('users/${uid ?? FirebaseAuth.instance.currentUser.uid}')
      .set({
    'email': email ?? FirebaseAuth.instance.currentUser.email,
    'faculty': key,
    'courses': value?.split(',')
  }, SetOptions(merge: true));
}

Stream<Map<String, dynamic>> getUser() {
  return FirebaseFirestore.instance
      .doc('users/${FirebaseAuth.instance.currentUser.uid}')
      .snapshots()
      .map((event) => event.data());
}
