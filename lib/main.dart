import 'dart:math';
import 'package:c10_project/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'backend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class Subject {
  final String title;
  final String score;

  Subject({this.score, this.title});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C10 Project',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List<Subject> list = [
    Subject(title: 'English', score: ''),
    Subject(title: 'Mathematics', score: ''),
    Subject(title: 'French', score: ''),
    Subject(title: 'Russian Language', score: ''),
    Subject(title: 'History', score: ''),
  ];

  void _incrementCounter() async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 200,
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0, bottom: 12),
                        child: Text(
                          'Enter the subject title',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter your score',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onFieldSubmitted: (val) {
                            Navigator.pop(context, val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
    if (result != null)
      setState(() {
        list.add(Subject(title: result));
      });
  }

  submitAnswers() async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 200,
                child: Card(
                  child: FutureBuilder<bool>(
                      future: Future.delayed(Duration(seconds: 4), () {
                        var val = suggest(
                            list.map((e) => int.parse(e.score)).toList());
                        return Future.value(true);
                      }),
                      builder: (context, snapshot) {
                        var val = suggest(
                            list.map((e) => int.parse(e.score)).toList());
                        if (!snapshot.hasData)
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18.0, bottom: 12),
                                  child: Text(
                                    'Please wait while we process your answers and recommend some subjects you need to retake',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          );
                        else
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'You need to retake ${list[Random().nextInt(list.length - 1)].title}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(fontSize: 14),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      child: Text('Close'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                      }),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          var user = FirebaseAuth.instance.currentUser;
          var loggedIn = user != null;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'C10 Project',
              ),
              centerTitle: true,
              actions: [
                loggedIn
                    ? Center(
                        child: Text(user.email,
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      )
                    : TextButton(
                        child: Text('Log in',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                        onPressed: () => Navigator.push(
                            context,
                            DialogRoute(
                                context: context,
                                builder: (context) => LoginPage()))),
                SizedBox(
                  width: 60,
                )
              ],
            ),
            body: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 30),
                      child: Text(
                        'Fill in the fields with your scores. When you are done, Submit your answers to get a recommendation.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ...List.generate(
                      list.length,
                      (index) => Container(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(list[index].title),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Enter your score',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (val) {
                                list[index] = Subject(
                                    title: list[index].title, score: val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: EdgeInsets.only(top: 12),
                      child: ElevatedButton(
                        child: Text('Subit Answers'),
                        onPressed: submitAnswers,
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)))),
                      ),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Add extra subject',
              child: Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        });
  }
}
