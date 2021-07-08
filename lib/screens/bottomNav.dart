import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:invoice_reckon/screens/auth/google_sign_in/screens/user_info_screen.dart';
import 'package:invoice_reckon/screens/random/randomCustomerHistory.dart';

import 'random/randomCustomer.dart';
import 'sales/screens/salesScreen.dart';


class BottomNav extends StatefulWidget {
  final User user;
  final String uid;

  const BottomNav({this.uid,this.user});


  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;
  PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _onItemTapped(int index) {
    setState(() {
      // ignore: unnecessary_statements
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: screens.elementAt(_currentIndex),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            SalesScreen(uid: widget.uid),
            RandomCustomer(uid: widget.uid),
            RandomVoucherHistory(uid:widget.uid,),
            UserInfoScreen(user: widget.user),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true, // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          _onItemTapped(index);
          _currentIndex = index;
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        }),
        itemCornerRadius: 24,
        curve: Curves.easeOut,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(FontAwesome5.shopify,color: Colors.black,),
            title: Text('Sales',style: TextStyle(color: Colors.black)),
            activeColor: Colors.redAccent,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.add_business,color: Colors.black,),
            title: Text('Random',style: TextStyle(color: Colors.black),),
            activeColor: Colors.redAccent,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(FontAwesome5.history,color: Colors.black,),
            title: Text('History',style: TextStyle(color: Colors.black)),
            activeColor: Colors.redAccent,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(FontAwesome5.user,color: Colors.black,),
            title: Text('Account',style: TextStyle(color: Colors.black)),
            activeColor: Colors.redAccent,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}