import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:invoice_reckon/models/sales/item.dart';
import 'package:invoice_reckon/screens/sales/widgets/voucherWidget.dart';
///Add items Delete Items Part Screen

class VoucherScreen extends StatefulWidget {
  final String voucherId;
  final String custId;
  final String name;
  final String uid;

  const VoucherScreen({this.uid, this.voucherId, this.custId, this.name});

  @override
  _VoucherScreenState createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
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
            .collection('vouchers')
            .doc(widget.name)
            .collection('customerVouchers')
            .doc(widget.voucherId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          VoucherWidget voucherWidget = VoucherWidget(
            uid: widget.uid,
            voucherId: snapshot.data['voucherId'],
            custId: snapshot.data['custId'],
            totalAmt: snapshot.data['totalAmt'],
            payAmt: snapshot.data['payAmt'],
            leftAmt: snapshot.data['leftAmt'],
            timestamp: snapshot.data['timestamp'],
            createdDate: snapshot.data['createdDate'],
            name: widget.name,
            creator: snapshot.data['creator'],
          );
          return voucherWidget;
        });
  }
}
