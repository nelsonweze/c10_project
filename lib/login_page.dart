import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginKey = GlobalKey<FormState>();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = TextFormField(
      key: Key('email_login_field'),
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _email,
      decoration: emailDecoration(showKid: true),
    );

    final password = PasswordField(
      controller: _password,
      onFieldSubmitted: () {},
    );

    return Container(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Material(
          child: Form(
            key: _loginKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 35.0, right: 15.0, left: 15.0),
                          child: Text('Sign In',
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline5),
                        ),
                        SizedBox(height: 48.0),
                        email,
                        SizedBox(height: 24.0),
                        password,
                        SizedBox(height: 12.0),
                        Container(
                            margin: EdgeInsets.only(top: 30),
                            height: 48,
                            child: ElevatedButton(
                                child: Text('Sign in'),
                                onPressed: () async {
                                  var user;
                                  try {
                                    user = await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                            email: _email.text,
                                            password: _password.text);
                                    print(user);
                                    return Navigator.pop(context);
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      try {
                                        user = await FirebaseAuth.instance
                                            .createUserWithEmailAndPassword(
                                                email: _email.text,
                                                password: _password.text);
                                        print(user);
                                        return Navigator.pop(context);
                                      } on FirebaseAuthException catch (e) {
                                        print(e.message);
                                        return SnackBar(
                                            content: Text(e.message));
                                      }
                                    }
                                    print(e.message);
                                    return SnackBar(content: Text(e.message));
                                  }
                                })),
                      ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration emailDecoration({bool showKid = false}) {
  return InputDecoration(
    prefixIcon: Padding(
      padding: EdgeInsets.only(left: 5.0),
      child: Icon(
        Icons.email,
        color: Colors.grey,
      ), // icon is 48px widget.
    ), // icon is 48px widget.
    hintText: showKid ? 'Email or Konekt ID' : 'Email',
    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
  );
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function onFieldSubmitted;
  PasswordField(
      {Key key, this.controller, this.onChanged, this.onFieldSubmitted});
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key('pwd_field'),
      autofocus: false,
      obscureText: _obscureText,
      controller: widget.controller,
      onChanged: widget.onChanged,
      onFieldSubmitted: (_) => widget.onFieldSubmitted,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Password',
        suffixIcon: new GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child:
              new Icon(!_obscureText ? Icons.visibility : Icons.visibility_off),
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
