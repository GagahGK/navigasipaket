import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Screen/loginScreen.dart';
import 'package:rider_app/Screen/mainscreen.dart';
import 'package:rider_app/Screen/registerScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

var crrntuser = FirebaseAuth.instance.currentUser;

DatabaseReference uidcrrnt =
    FirebaseDatabase.instance.reference().child("Users").child(crrntuser.uid);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Rider App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute:
            crrntuser == null ? LoginScreen.idScreen : MainScreen.idScreen,
        routes: {
          RegisterScreen.idScreen: (context) => RegisterScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(
                uid: uidcrrnt.key,
              ),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
