import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:invoice_reckon/screens/auth/google_sign_in/utils/authentication.dart';
import 'package:invoice_reckon/screens/bottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  var _visible = true;

  AnimationController animationController;
  Animation<double> animation;

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }
  navigationPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('uid');
    Authentication.initializeFirebase(context: context).then((user) {
      final uid = user.uid;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> BottomNav(user: user,uid: uid,)));
    });
    if (userId != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> BottomNav(uid: userId,)));
    }else{
      Navigator.of(context).pushReplacementNamed('login');
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(vsync: this, duration: new Duration(seconds: 3));
    animation = new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
           Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Image.asset(
                'assets/logo.png',
                width: animation.value * 300,
                height: animation.value * 300,
              ),
            ],
          ),
        ],
      ),
    );
  }

}