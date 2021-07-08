import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RegisterScreen(),
    );
  }
}


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  double _height, _width;
  String _email, _password;
  GlobalKey<FormState> _key = GlobalKey();
  bool _showPassword = true, _load = false;
  String uid= Uuid().v4();

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
    appBar: AppBar(title: Text('Register'),),
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
            SizedBox(height: _height / 12),
            button(),
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
            "Create An Account",
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
            "Sign up for free!",
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
      child:TextFormField(
        onSaved: (input) => _email = input,
        keyboardType: TextInputType.emailAddress,
        cursorColor: Colors.redAccent,
        obscureText: false,
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
        onSaved: (input) => _password = input,
        keyboardType: TextInputType.visiblePassword,
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
              Navigator.of(context).pushNamed('forgotpassword');
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

  Widget button() {

      // ignore: deprecated_member_use
    return !_load ? RaisedButton(
      elevation: 0,
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
          setState((){_load = true;});
          signUp();
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
        child: Text('SIGN UP',style: TextStyle(fontSize: 15,color: Colors.white)),
      ),
    ): Center(
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
            "Already Registered?",
            style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              print("Routing");
              Navigator.of(context).pushReplacementNamed('login');
            },
            child: Text(
              "Login",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.redAccent),
            ),
          )
        ],
      ),
    );
  }

  Future<void> signUp() async {
    try{

      setState((){_load = true;});
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password).then((_) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', _email);
        prefs.setString('uid', uid);

        setState((){_load = false;});
        Navigator.of(context).pushReplacementNamed('login');
      });

    }
    catch(e){
      setState((){_load = false;});
      print(e.message);

      // ignore: deprecated_member_use
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

}