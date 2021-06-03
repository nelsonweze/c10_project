import 'package:c10_project/backend.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile page')),
      body: SingleChildScrollView(
        child: StreamBuilder<Map<String, dynamic>>(
            stream: getUser(),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              return Container(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      data['email'],
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                          'Faculty: ${data['faculty'] == null ? '-' : data['faculty']}'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'List of Suggested Courses',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 17),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (data['courses'] == null)
                      Center(
                        child: Text('No suggested courses yet.'),
                      )
                    else ...[
                      ...List.generate(data['courses'].length, (index) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          child: Text(data['courses'][index]),
                        );
                      })
                    ]
                  ],
                ),
              );
            }),
      ),
    );
  }
}
