import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'createdVoucherWidget.dart';
///Add items Delete Items Part Screen

class CreatedInvoiceScreen extends StatefulWidget {
  final String voucherId;
  final String custId;
  final String name;
  final String uid;

  const CreatedInvoiceScreen({ this.voucherId, this.custId, this.name,this.uid});

  @override
  _CreatedInvoiceScreenState createState() => _CreatedInvoiceScreenState();
}

class _CreatedInvoiceScreenState extends State<CreatedInvoiceScreen> {
  final SnackBar snackBar = SnackBar(content: Text("Saved!"));

  Future<void> _showDeleteDialog(String itemId, String custId, String voucherId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        ///client voucher add items delete part alert box (delete)
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This item will be deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .collection('vouchers')
                  .doc(widget.name)
                  .collection('customerVouchers')
                  .doc(widget.voucherId)
                  .collection('items')
                  .doc(itemId)
                  .delete();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
          final voucherWidget = CreatedVoucherWidget(
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
