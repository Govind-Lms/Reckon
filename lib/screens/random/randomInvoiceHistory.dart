import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:invoice_reckon/screens/random/randomInvoiceHistoryWidget.dart';
///Add items Delete Items Part Screen

class RandomInvoiceScreen extends StatefulWidget {
  final String invoiceId;
  final String name;
  final String uid;

  const RandomInvoiceScreen({this.uid, this.invoiceId,this.name});

  @override
  _RandomInvoiceScreenState createState() => _RandomInvoiceScreenState();
}

class _RandomInvoiceScreenState extends State<RandomInvoiceScreen> {
  final SnackBar snackBar = SnackBar(content: Text("Saved!"));
  int left = 0;
  int pay = 0;
  int total = 0;
  int paid = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('RandomInvoices')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          RandomInvoiceHistoryWidget voucherWidget = RandomInvoiceHistoryWidget(
            uid: widget.uid,
            invoiceId: snapshot.data['invoiceId'],
            totalAmt: snapshot.data['totalAmt'],
            payAmt: snapshot.data['payAmt'],
            leftAmt: snapshot.data['leftAmt'],
            timestamp: snapshot.data['timestamp'],
            createdDate: snapshot.data['createdDate'],
            custName: widget.name,
          );
          return voucherWidget;
        });
  }
}
