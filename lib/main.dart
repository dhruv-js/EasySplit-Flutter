import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_my_bill/providers/google_sign_in_provider.dart';
import 'package:split_my_bill/providers/groups.dart';
import 'package:split_my_bill/screens/auth_screen.dart';
import 'package:split_my_bill/screens/group_detail_screen.dart';
import 'package:split_my_bill/screens/group_list_screen.dart';
import 'package:split_my_bill/screens/new_transaction_screen.dart';
import 'package:split_my_bill/screens/record_payment_screen.dart';
import 'package:split_my_bill/screens/record_screen.dart';
import 'package:split_my_bill/screens/settle_screen.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Map<int, Color> color =
  {
    50:Color.fromRGBO(5, 55, 127, .1),
    100:Color.fromRGBO(5, 55, 127, .2),
    200:Color.fromRGBO(5, 55, 127, .3),
    300:Color.fromRGBO(5, 55, 127, .4),
    400:Color.fromRGBO(5, 55, 127, .5),
    500:Color.fromRGBO(5, 55, 127, .6),
    600:Color.fromRGBO(5, 55, 127, .7),
    700:Color.fromRGBO(5, 55, 127, .8),
    800:Color.fromRGBO(5, 55, 127, .9),
    900:Color.fromRGBO(5, 55, 127, 1),
  };
  // MaterialColor colorCustom = MaterialColor(0xFF880E4F, color);
  // MaterialColor color = Color.fromRGBO(5, 55, 127, 1);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoogleSignInProvider(), // Groups() in place of this
      child: MaterialApp(
        title: 'Split bill',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: MaterialColor(0xff2a5c99, color),
          accentColor: Color(0xFFEAC43D),
          backgroundColor: Color.fromRGBO(247, 247, 250, 1),
          // canvasColor: Colors.transparent
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            final provider = Provider.of<GoogleSignInProvider>(context);
            if (provider.isSigningIn){
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }else if(snapshot.hasData){
              // log(snapshot.data.toString());
              final currentUser = FirebaseAuth.instance.currentUser;
              provider.uid = currentUser.uid;
              provider.email = currentUser.email;
              provider.displayName = currentUser.displayName;
              return GroupListScreen();
            }else{
              return AuthScreen();
            }
          },
        ),
        // GroupListScreen(),
        routes: {
          GroupListScreen.routeName: (ctx) => GroupListScreen(),
          GroupDetailScreen.routeName: (ctx) => GroupDetailScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          SettleScreen.routeName: (ctx) => SettleScreen(),
          RecordPaymentScreen.routeName: (ctx) => RecordPaymentScreen(),
          RecordScreen.routeName: (ctx) => RecordScreen(),
          // NewTransactionScreen.routeName: (ctx) => NewTransactionScreen(),
        },
      ),
    );
  }
}
