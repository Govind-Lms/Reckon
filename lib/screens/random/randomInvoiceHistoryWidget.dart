import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_reckon/models/sales/item.dart';
import 'package:invoice_reckon/screens/sales/screens/editPaid.dart';
import 'package:invoice_reckon/screens/sales/widgets/helpers_invoice/invoice_api.dart';
import 'package:invoice_reckon/screens/sales/widgets/helpers_invoice/pdfapi.dart';
import 'package:uuid/uuid.dart';
class RandomInvoiceHistoryWidget extends StatefulWidget {
  final String uid;
  final String invoiceId;
  final String custName;
  final int totalAmt;
  final int payAmt;
  final int leftAmt;
  final Timestamp timestamp;
  final Timestamp createdDate;

  RandomInvoiceHistoryWidget(
      {this.invoiceId,
        this.uid,
        this.custName,
        this.totalAmt,
        this.payAmt,
        this.leftAmt,
        this.timestamp,
        this.createdDate,
      });

  factory RandomInvoiceHistoryWidget.fromDocument(doc) {
    return RandomInvoiceHistoryWidget(
      invoiceId: doc['invoiceId'],
      custName: doc['custName'],
      totalAmt: doc['totalAmt'],
      payAmt: doc['payAmt'],
      leftAmt: doc['leftAmt'],
      timestamp: doc['timestamp'],
      createdDate: doc['createdDate'],
    );
  }

  @override
  _RandomInvoiceHistoryWidgetState createState() => _RandomInvoiceHistoryWidgetState(  );
}

class _RandomInvoiceHistoryWidgetState extends State<RandomInvoiceHistoryWidget> {


  String lastPaidDate;
  String itemId = Uuid().v4();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  int payInput;
  int paidAmt;

  @override
  void initState() {
    super.initState();
    lastPaidDate = DateFormat('dd/MM/yyyy').format(widget.timestamp.toDate());
    paidAmt = widget.payAmt;
    payInput = 0;
  }
  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<QuerySnapshot> (
        stream:  FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .collection('RandomInvoices')
            .doc(widget.custName)
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
          List<List<String>> listOfLists= [];
          snapshot.data.docs.forEach((doc) {
            Item item = Item.fromDocument(doc);
            itemsTotal.add(item.total);
            newList.add(DataRow(
              cells: [
                DataCell(Center(child: Text(item.itemName))),
                DataCell(Center(child: Text(item.price.toString()))),
                DataCell(Center(child: Text(item.quantity.toString()))),
                DataCell(Center(child: Text(item.total.toString()))),
            ]));

            listOfLists.add([item.itemName,item.price.toString(),item.quantity.toString(),item.total.toString()]);


           
          });
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Detail : ' + widget.custName),
              actions: [
                IconButton(icon: Icon(Icons.edit), onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EditPaid(uid: widget.uid,name: widget.custName,voucherId: widget.invoiceId)));
                })
              ],
              centerTitle: false,
            ),
            body: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25.0,
                    top: 25.0,
                  ),
                  child: Text(
                    'Created Date : ' +
                        DateFormat('dd-MM-yyyy').format(widget.createdDate.toDate()),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, top: 10.0, bottom: 10.0),
                  child: Text(
                    'Created for : ' + widget.custName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, bottom: 10.0),
                  child: Text(
                    'Invoice Id : ' +widget.invoiceId,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  )
                ),
                Column(
                  children: [
                    Center(
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
                                DataCell(Text(widget.totalAmt.toString())),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Paid Money')),
                                DataCell(Text(':')),
                                DataCell(Text(widget.payAmt.toString()))

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
                                      color: widget.leftAmt == 0 ? Colors.green : Colors.red),
                                )),
                                DataCell(Text(':')),
                                DataCell(Text(
                                  widget.leftAmt.toString(),
                                  style: TextStyle(
                                      color: widget.leftAmt == 0 ? Colors.green : Colors.red),
                                )),
                              ]),

                            ],
                          ),
                        )),
                  ],
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.share),
              onPressed: () async{                
                final pdfFile = await PdfInvoiceApi.generate(
                  listOfLists: listOfLists,
                  createdDate: widget.createdDate,
                  creator: widget.custName,
                  custId: widget.custName,
                  leftAmt: widget.leftAmt,
                  name: widget.custName,
                  payAmt: widget.payAmt,
                  timestamp: widget.timestamp,
                  totalAmt: widget.totalAmt,
                  uid: widget.uid,
                  voucherId: widget.invoiceId,
                );
                PDFApi.openFile(pdfFile);
              },
            ),
          );
        });
  }
}
