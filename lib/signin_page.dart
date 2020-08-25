import 'package:chat_app/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //controller
  final _emailC = TextEditingController(text: 'snf@gmail.com');
  final _passwdC = TextEditingController(text: '123456');

  //focus node
  final _emailNode = FocusNode();
  final _passwdNode = FocusNode();

  // state
  bool _isLoading = false;

  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final User user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) {
            return ChatPage();
          }),
          (route) => false,
        );
      }
    });

    super.initState();
  }

  void dispose() {
    _emailC.dispose();
    _passwdC.dispose();

    _emailNode.dispose();
    _passwdNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff4258f3),
        title: Text('Sign In'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailC,
              decoration: InputDecoration(
                hintText: 'Input email',
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwdC,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Input password', labelText: 'Password'),
            ),
            SizedBox(height: 20),
            RaisedButton(
              hoverColor: Colors.white,
              highlightColor: Color(0xffb7cdf5).withOpacity(0.3),
              color: Color(0xff4258f3),
              textColor: Colors.white,
              onPressed: _isLoading ? null : _onSignIn,
              child: Text('Login'),
            )
          ],
        ),
      )),
    );
  }

  Future<void> _onSignIn() async {
    String email = _emailC.text;
    String passwd = _passwdC.text;

    try {
      setState(() {
        _isLoading = true;
      });

      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: passwd);

      setState(() {
        _isLoading = false;
      });

      if (credential != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) {
            return ChatPage();
          }),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
