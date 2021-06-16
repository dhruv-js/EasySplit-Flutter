import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_my_bill/providers/google_sign_in_provider.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
            provider.login();
          },
          child: Text('Sign in with google'),
        ),
      ),
    );
  }
}
