import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_reckon/models/sales/voucher.dart';

import 'historyVoucherScreen.dart';

class SalesVoucherHistory extends StatefulWidget {
  final String custId,name,uid;

  const SalesVoucherHistory({ this.custId, this.name,this.uid});

  @override
  _SalesVoucherHistoryState createState() => _SalesVoucherHistoryState();
}

class _SalesVoucherHistoryState extends State<SalesVoucherHistory> {
  @override
  void initState() {
    super.initState();
  }

  int _val = DateTime.now().month;
  //double a = 0.5;

  bool voucherCheck;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Voucher List : ' + widget.name),
          centerTitle: false,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('vouchers')
            .doc(widget.name)
            .collection('customerVouchers')
                .orderBy('createdDate', descending: true)
                .snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              List<VoucherTile> voucherTiles = [];

              snapshot.data.docs.forEach((doc) {
                Voucher voucher = Voucher.fromDocument(doc);
                DateTime date = voucher.createdDate.toDate();
                if (date.month == _val) {
                  voucherTiles.add(VoucherTile(
                    uid: widget.uid,
                    voucher: voucher,
                    custId: widget.custId,
                    name: widget.name,
                  ));
                }
              });

              if (voucherTiles.length == 0) {
                voucherCheck = false;
              } else {
                voucherCheck = true;
              }
              return ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border:
                        Border.all(color: Theme.of(context).primaryColor)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        // dropdownColor: Theme.of(context).primaryColor,
                          elevation: 1,
                          isDense: false,
                          value: _val,
                          items: [
                            DropdownMenuItem(
                              child: Text("January"),
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child: Text("February"),
                              value: 2,
                            ),
                            DropdownMenuItem(child: Text("March"), value: 3),
                            DropdownMenuItem(child: Text("April"), value: 4),
                            DropdownMenuItem(
                              child: Text("May"),
                              value: 5,
                            ),
                            DropdownMenuItem(
                              child: Text("June"),
                              value: 6,
                            ),
                            DropdownMenuItem(child: Text("July"), value: 7),
                            DropdownMenuItem(child: Text("August"), value: 8),
                            DropdownMenuItem(
                              child: Text("September"),
                              value: 9,
                            ),
                            DropdownMenuItem(
                              child: Text("October"),
                              value: 10,
                            ),
                            DropdownMenuItem(
                                child: Text("November"), value: 11),
                            DropdownMenuItem(child: Text("December"), value: 12)
                          ],
                          onChanged: (val) {
                            setState(() {
                              _val = val;
                              print(_val);
                            });
                          }),
                    ),
                  ),
                  Column(
                    children: voucherCheck
                        ? voucherTiles
                        : [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text('No Vouchers')
                          ],
                        ),
                      )
                    ],
                  )
                ],
              );
            }));
  }
}

class VoucherTile extends StatefulWidget {
  final Voucher voucher;
  final String custId;
  final String name;
  final String uid;

  VoucherTile({this.uid, this.voucher, this.custId, this.name});

  @override
  _VoucherTileState createState() => _VoucherTileState();
}

class _VoucherTileState extends State<VoucherTile> {
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This voucher will be deleted.'),
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
                    .doc(widget.voucher.voucherId)
                    .collection('items')
                    .get()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.docs) {
                    ds.reference.delete();
                  }
                });
                FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('vouchers')
            .doc(widget.name)
            .collection('customerVouchers')
                    .doc(widget.voucher.voucherId)
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: FlatButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return VoucherScreen(
              uid: widget.uid,
              custId: widget.custId,
              voucherId: widget.voucher.voucherId,
              name: widget.name,
            );
          }));
          // print(widget.vocher.id);
        },
        onLongPress: () {
           _showMyDialog();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(width: 0.5, color: Colors.blueGrey)),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: widget.voucher.leftAmt != 0
                      ? 'https://images.unsplash.com/photo-1568561300108-e0c35b5f7c1c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=900&q=60'
                      : 'https://images.unsplash.com/photo-1561016444-14f747499547?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=900&q=60',
                  width: 60.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        DateFormat('dd-MM-yyyy')
                            .format(widget.voucher.createdDate.toDate()),
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                          DateFormat('h:mm a')
                              .format(widget.voucher.createdDate.toDate()),
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.0),
                      widget.voucher.leftAmt != 0 
                          ? Text(
                        'Left Money : ${widget.voucher.leftAmt}',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600),
                      )
                          : Text(
                        'Paid',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Creator        : ${widget.voucher.creator}',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}