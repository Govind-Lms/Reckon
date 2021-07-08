import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Container customerCard(String phoneNo, IconData iconData, String type){
  return Container(
    width: 180.0,
    height: 180.0,
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(199.0),
            color: Colors.white,
          ),
          child: Icon(iconData,size: 20.0,color: Colors.grey[800],),
        ),
        SizedBox(height: 5.0,),
        Text(type,style: TextStyle(color: Colors.grey[800],fontSize: 16.0),),
        SizedBox(height: 5.0,),
        Text('$phoneNo',textAlign: TextAlign.center,style: TextStyle(color: Colors.grey[800],fontSize: 12.0),)
      ],
    ),
  );
}