import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_reckon/models/sales/item.dart';
import 'package:invoice_reckon/screens/sales/widgets/shopName.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

import 'editPaid.dart';

class CreatedVoucherWidget extends StatefulWidget {
  final String uid;
  final String voucherId;
  final String custId;
  final int totalAmt;
  final int payAmt;
  final int leftAmt;
  final String name;

  final Timestamp timestamp;
  final Timestamp createdDate;
  final String creator;

  CreatedVoucherWidget({
    this.uid,
    this.voucherId,
    this.custId,
    this.totalAmt,
    this.payAmt,
    this.leftAmt,
    this.timestamp,
    this.createdDate,
    this.creator,
    this.name,
  });

  factory CreatedVoucherWidget.fromDocument(doc) {
    return CreatedVoucherWidget(
      voucherId: doc['voucherId'],
      custId: doc['custId'],
      name: doc['name'],
      totalAmt: doc['totalAmt'],
      payAmt: doc['payAmt'],
      leftAmt: doc['leftAmt'],
      timestamp: doc['timestamp'],
      createdDate: doc['createdDate'],
      creator: doc['creator'],
    );
  }

  @override
  _CreatedVoucherWidgetState createState() => _CreatedVoucherWidgetState(
      voucherId: this.voucherId,
      custId: this.custId,
      totalAmt: this.totalAmt,
      payAmt: this.payAmt,
      leftAmt: this.leftAmt,
      timestamp: this.timestamp,
      createdDate: this.createdDate,
      creator: this.creator,
      name: this.name,
  );
}

class _CreatedVoucherWidgetState extends State<CreatedVoucherWidget> {
  final String voucherId;
  final String custId;
  int totalAmt;
  int payAmt;
  int leftAmt;
  String name;
  Timestamp timestamp;
  final Timestamp createdDate;
  final String creator;

  String lastPaidDate;
  String itemName;
  int price;
  int quantity;
  int total;
  String itemId = Uuid().v4();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  int payInput;
  int paidAmt;

  _CreatedVoucherWidgetState(
      {this.voucherId,
        this.custId,
        this.totalAmt,
        this.payAmt,
        this.leftAmt,
        this.timestamp,
        this.createdDate,
        this.creator,
        this.name});


  @override
  void initState() {
    super.initState();
    lastPaidDate = DateFormat('dd-MM-yyyy').format(timestamp.toDate());
    paidAmt = payAmt;

    payInput = 0;
  }

  Future<void> _showMyDialog(String itemId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
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
                    .doc(itemName)
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
    return StreamBuilder<QuerySnapshot> (
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('vouchers')
            .doc(widget.name)
            .collection('customerVouchers')
            .doc(widget.voucherId)
            .collection('items')
            .orderBy('timestamp',descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()));
          }
          List<DataRow> newList = [];
          List<int> itemsTotal = [];
          snapshot.data.docs.forEach((doc) {
            Item item = Item.fromDocument(doc);
            itemsTotal.add(item.total);
            newList.add(DataRow(
              ///cashier prevent
              cells: [
                DataCell(Center(child: Text(item.itemName))),
                DataCell(Center(child: Text(item.price.toString()))),
                DataCell(Center(child: Text(item.quantity.toString()))),
                DataCell(Center(child: Text(item.total.toString()))),
              ]));
          });
          return Container(
              margin: EdgeInsets.only(top: 40.0,bottom: 10.0,left: 10.0,right: 10.0),
              child: Scaffold(
                key: _scaffoldKey,
                // appBar: AppBar(
                //   title: Text('Detail : ' + widget.name),
                //   actions: [
                //     IconButton(icon: Icon(Icons.edit), onPressed: (){
                //       Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EditPaid(
                //         name: widget.name,voucherId: widget.voucherId, uid: widget.uid))
                //       );
                //     })
                //   ],
                //   centerTitle: false,
                // ),
                body: ListView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 80.0,
                                height: 80.0,
                                color: Colors.green,
                              ),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text( ShopName.shopName,style: TextStyle(fontSize: 12.0)),
                                    Text( ShopName.shopLocation,style: TextStyle(fontSize: 12.0)),
                                    Text( ShopName.shopPhoneNo,style: TextStyle(fontSize: 12.0)),
                                    Text( ShopName.shopMail,style: TextStyle(fontSize: 12.0)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            child: Column(
                              children: [
                                SizedBox(height: 30.0,),
                                Text('INVOICE',style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(height: 30.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('InvoiceId: '+'${widget.voucherId}',style: TextStyle(fontSize: 10.0),),
                                    Text(DateFormat('dd/MM/yyyy').format(createdDate.toDate()),style: TextStyle(fontSize: 10.0),),
          
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Created For: '+'${widget.name}',style: TextStyle(fontSize: 10.0),),
                                    Text('Phone Number',style: TextStyle(fontSize: 10.0),),
          
                                  ],
                                ),
                                SizedBox(height: 10.0,),
          
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Center(
                          child: FittedBox(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                  showCheckboxColumn: false,
                                  columns: [
                                    DataColumn(label: Text('Name'), numeric: false),
                                    DataColumn(label: Text('Price'), numeric: true),
                                    DataColumn(label: Text('Qty'), numeric: true),
                                    DataColumn(label: Text('Total'), numeric: true),
                                  ],
                                  rows: newList),
                            ),
                          ),
                        ),
          
                        ///cashier prevent
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('')),
                                DataColumn(label: Text('')),
                                DataColumn(label: Text('')),
                              ],
                              rows: [
                                DataRow(cells: [
                                  DataCell(Text('Total Amount')),
                                  DataCell(Text(':')),
                                  DataCell(Text(totalAmt.toString())),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Paid Money')),
                                  DataCell(Text(':')),
                                  DataCell(Text(payAmt.toString()))
        
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Last Paid Date')),
                                  DataCell(Text(':')),
                                  DataCell(
                                    Text(lastPaidDate),
                                  ),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text(
                                    'Left Money',
                                    style: TextStyle(
                                        color: leftAmt == 0 ? Colors.green : Colors.red),
                                  )),
                                  DataCell(Text(':')),
                                  DataCell(Text(
                                    leftAmt.toString(),
                                    style: TextStyle(
                                        color: leftAmt == 0 ? Colors.green : Colors.red),
                                  )),
                                ]),
        
                              ],
                            ),
                          )
                        ),
                      ],
                    ),
                  
                  ],
                ),
                // floatingActionButton: FloatingActionButton(
                //   onPressed: () {
                //     _imageFile = null;
                //     screenshotController
                //       .capture(delay: Duration(milliseconds: 10))
                //       .then((image) async {
                //         setState(() {
                //           _imageFile = image;
                //         }); 
                //       });
                //   },
                //   tooltip: 'Capture',
                //   child: Icon(Icons.share),
                // ), //
              ),
            
          );
        });
  }
}
