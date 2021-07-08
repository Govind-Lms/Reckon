import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:invoice_reckon/screens/random/randomInvoiceCreate.dart';
import 'package:uuid/uuid.dart';

class RandomCustomer extends StatefulWidget {
  final String uid;

  const RandomCustomer({ this.uid});
  @override
  _RandomCustomerState createState() => _RandomCustomerState();
}

class _RandomCustomerState extends State<RandomCustomer> {
  String custName,custPhone;
  String invoiceId= Random().nextInt(1000000).toString();
  final key= GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create An Invoice'),
      ),
      body: Form(
        key: key,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                // validator: (val) => val.isEmpty ? "Enter Client Name" : null,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter Client Name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Client Name",
                  prefixIcon: Icon(Icons.account_circle,size: 25.0,),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val){
                  custName = val;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                keyboardType: TextInputType.number,
                // validator: (val) => val.isEmpty ? "Enter Phone Number" : null,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter Phone Number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Client Phone Number",
                  prefixIcon: Icon(Icons.phone_android,size: 25.0,),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val){
                  custPhone = val;
                },
              ),
            ),
            // ignore: deprecated_member_use
            FlatButton(
              onPressed: () async{
                if( key.currentState.validate()){
                  FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('RandomCustomers').doc(custName).set
                     ({
                    'custName': custName,
                    'custPhone': custPhone,
                    'invoiceId': invoiceId,
                    'timestamp': DateTime.now(),
                    'uid': widget.uid
                  });
                  var doc= await FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('RandomInvoices').doc(custName).get();
                  setState(() {
                    invoiceId= Random().nextInt(1000000).toString();
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> RandomInvoiceCreate(
                    uid: widget.uid,
                    custPhone: custPhone,
                    custName: custName,
                    invoiceId: invoiceId,
                  )));
                  return doc;
                }
              },
              child: Container(
                height: 50.0,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(5.0)
                ),
                child: Text(
                  "NEXT STEP",
                  style: TextStyle(
                    fontFamily: 'Charter',
                      fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
