
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:invoice_reckon/models/sales/user.dart';
import 'package:invoice_reckon/screens/auth/google_sign_in/utils/authentication.dart';
import 'package:invoice_reckon/screens/bottomNav.dart';
import 'screens/auth/screens.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserModel currentUserModel;
  Widget build(BuildContext context) {
    @override
    void initState() {
      super.initState();
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        Authentication.initializeFirebase(context: context).then((user){
          setState(() {
            UserModel currentUserModel = UserModel(
              uid: user.uid,
              name: user.displayName,
              profilePhoto: user.photoURL,
              email: user.email,
              username: user.email.replaceAll("@gmail.com", ""),
            );
          });
        });
      });
    }
    // AuthMethods().signOut();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Reckon",
      theme: ThemeData(primaryColor: Colors.redAccent),
      routes: <String, WidgetBuilder>{
        'splashscreen': (BuildContext context) =>  SplashScreen(),
        'login': (BuildContext context) =>  Login(),
        'forgetPassword': (BuildContext context) => ForgotPassword(),
        'register': (BuildContext context) => Register(),
      },
      initialRoute: 'splashscreen',
      home: FutureBuilder(
          future: Authentication.initializeFirebase(context: context),
          builder: (context , snapshot){
            if(snapshot.hasData){
              return BottomNav(uid: currentUserModel.uid);
            }
            else{
              return LoginScreen();
            }
          },
        ),
    );
  }}
