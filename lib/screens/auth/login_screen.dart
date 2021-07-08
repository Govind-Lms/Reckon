import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../bottomNav.dart';
import '../../firebase/auth.dart';
import 'google_sign_in/widgets/google_sign_in_button.dart';
class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginScreen(),
    );
  }
}


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  double _height, _width;
  String _email, _password;
  String uid= Uuid().v4();

  GlobalKey<FormState> _key = GlobalKey();
  bool _showPassword = true, _load = false;
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
    appBar: AppBar(title: Text('Login'),),
      body: Container(
        height: _height,
        width: _width,
        padding: EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              image(),
              welcomeText(),
              loginText(),
              form(),
              forgetPassText(),
              SizedBox(height: _height / 12),
              button(),
              SizedBox(height: _height / 35),
              googleSignIn(),
              dontHaveAccount(),
            ],
          ),
        ),
      ),
    );
  }

  Widget image(){
    return Container(
      margin: EdgeInsets.only(top: _height / 15.0),
      height: 80.0,
      width: 100.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
      ),
      // child: new Image.asset('assets/images/login.png'),
    );
  }

  Widget welcomeText(){
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Welcome",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget loginText() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0),
      child: Row(
        children: <Widget>[
          Text(
            "Sign in to your account",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 15.0,
          right: _width / 15.0,
          top: _height / 25.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            emailBox(),
            SizedBox(height: _height / 40.0),
            passwordBox(),
          ],
        ),
      ),
    );
  }

  Widget emailBox(){
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      elevation: 10,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        onSaved: (input) => _email = input,
        cursorColor: Colors.redAccent,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.email, color: Colors.redAccent, size: 20),
          hintText: "Email Id",
          border: OutlineInputBorder(
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget passwordBox(){
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      elevation: 10,
      child:TextFormField(
        keyboardType: TextInputType.visiblePassword,
        onSaved: (input) => _password = input,
        cursorColor: Colors.redAccent,
        obscureText: _showPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.redAccent, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.remove_red_eye,
              color: this._showPassword ? Colors.grey : Colors.redAccent,
            ),
            onPressed: () {
              setState(() => this._showPassword = !this._showPassword);
            },
          ),
          hintText: "Password",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }

  Widget forgetPassText() {
    return Container(
      margin: EdgeInsets.only(top: _height / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Forgot your password?",
            style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              print("Routing");
              Navigator.of(context).pushNamed('forgetPassword');
            },
            child: Text(
              "Recover",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.redAccent),
            ),
          )
        ],
      ),
    );
  }
  Widget googleSignIn(){
    return GestureDetector(
      onTap: () {
        AuthMethods().signInWithGoogle( context: context);
      },
      child:  GoogleSignInButton()
    );
  }
 
  Widget button() {
      // ignore: deprecated_member_use
    return !_load ? RaisedButton(
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      onPressed: () async {
        RegExp regExp = new RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$');
        final formstate = _key.currentState;
        formstate.save();
        if(_email == null || _email.isEmpty){

      // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Email Cannot be empty')));
        }else if(_password == null || _password.length < 6){

      // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Password needs to be atleast six characters')));
        }else if(!regExp.hasMatch(_email)){

      // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Enter a Valid Email')));
        }
        else{
          setState(() {
            _load = true;
          });
          signIn();
         }
      },
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width: _width/2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          gradient: LinearGradient(
            colors: <Color>[Colors.orange[200], Colors.pinkAccent],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text('SIGN IN',style: TextStyle(fontSize: 15,color: Colors.white)),
      ),
    )
        : Center(
      child: CircularProgressIndicator(),
    );
  }
  Widget dontHaveAccount() {
    return Container(
      margin: EdgeInsets.only(top: _height / 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Don't have an Account?",
            style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('register');
            },
            child: Text(
              "Register",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.redAccent),
            ),
          )
        ],
      ),
    );
  }

  Future<void>signIn()async{
    try{

      setState((){_load = true;});
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password).then((_){
        String email = FirebaseFirestore.instance.collection('users').doc(uid).id;
        print(email);
        if(_email!= email ){
          FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email' : _email,
          'uid' : uid,
          'password' : _password,
        });
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> BottomNav(uid: uid,)));

      });
      
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', _email);
      prefs.setString('uid', uid);
      setState((){_load = false;});

    }
    catch(e){
      setState((){_load = false;});
      print(e.message);
      // ignore: deprecated_member_use
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
