import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_reckon/models/sales/item.dart';
import 'package:invoice_reckon/screens/sales/screens/editPaid.dart';
import 'package:uuid/uuid.dart';
import 'helpers_invoice/invoice_api.dart';
import 'helpers_invoice/pdfapi.dart';

class VoucherWidget extends StatefulWidget {
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

  VoucherWidget(
      {this.voucherId,
        this.uid,
        this.custId,
        this.totalAmt,
        this.payAmt,
        this.leftAmt,
        this.timestamp,
        this.createdDate,
        this.creator,
        this.name,
      });

  factory VoucherWidget.fromDocument(doc) {
    return VoucherWidget(
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
  _VoucherWidgetState createState() => _VoucherWidgetState(  );
}

class _VoucherWidgetState extends State<VoucherWidget> {


  String lastPaidDate;
  String itemName;
  int quantity;
  int price;
  int total;

  String itemId = Uuid().v4();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  int payInput;
  int paidAmt;

  @override
  void initState() {
    super.initState();
    lastPaidDate = DateFormat('dd-MM-yyyy').format(widget.timestamp.toDate());
    paidAmt = widget.payAmt;
    payInput = 0;
  }
  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<QuerySnapshot> (
        stream:  FirebaseFirestore.instance
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
          List<TableRow> tableList = [];
          List<int> itemsTotal = [];
          List<List<String>> listOfLists=List();
            
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
              title: Text('Detail : ' + widget.name),
              actions: [
                IconButton(icon: Icon(Icons.edit), onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EditPaid(uid: widget.uid,name: widget.name,voucherId: widget.voucherId)));
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
                    'Created for : ' + widget.creator,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, bottom: 10.0),
                  child: Text(
                    'Invoice Id : ' +widget.voucherId,
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
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     _imageFile = null;
            //     screenshotController
            //         .capture(delay: Duration(milliseconds: 10))
            //         .then((image) async {
            //           setState(() {
            //             _imageFile = image;
            //           });
            //       showDialog(
            //         context: context,
            //         builder: (context) => Screenshot(
            //         controller: screenshotController2,
            //           child: Container(
            //             margin: EdgeInsets.all(20.0),
            //             child: Scaffold(
            //               body: Container(
            //                 margin: EdgeInsets.all(20.0),
            //                 child: Center(
            //                     child: Column(
            //                       children: [
            //                         Row(
            //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                           children: [
            //                             Container(
            //                               width: 80.0,
            //                               height: 80.0,
            //                               color: Colors.green,
            //                             ),
            //                             Container(
            //                               padding: EdgeInsets.all(10.0),
            //                               child: Column(
            //                                 crossAxisAlignment: CrossAxisAlignment.end,
            //                                 children: [
            //                                   Text( 'SMP COMPANY',style: TextStyle(fontSize: 12.0)),
            //                                   Text( 'Tamu, Mandalay',style: TextStyle(fontSize: 12.0)),
            //                                   Text( '09123456789',style: TextStyle(fontSize: 12.0)),
            //                                   Text( 'smpcompany.shop.com',style: TextStyle(fontSize: 12.0)),
            //                                 ],
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                         Container(
            //                           child: Column(
            //                             children: [
            //                               SizedBox(height: 30.0,),
            //                               Text('INVOICE',style: TextStyle(fontWeight: FontWeight.bold),),
            //                               SizedBox(height: 30.0,),
            //                               Row(
            //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                                 children: [
            //                                   Text('InvoiceId: '+'${widget.voucherId}',style: TextStyle(fontSize: 10.0),),
            //                                   Text(DateFormat('dd/MM/yyyy').format(widget.createdDate.toDate()),style: TextStyle(fontSize: 10.0),),
            //                                 ],
            //                               ),
            //                               Row(
            //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                                 children: [
            //                                   Text('Created For: '+'${widget.name}',style: TextStyle(fontSize: 10.0),),
            //                                   Text('Phone Number',style: TextStyle(fontSize: 10.0),),
            //                                 ],
            //                               ),
            //                               SizedBox(height: 10.0,),
            //                             ],
            //                           ),
            //                         ),
            //                         _imageFile != null ? Image.memory(_imageFile) : Text('hi'),
            //                         Spacer(),
            //                         RaisedButton(
            //                           child: Text('Share'),
            //                           onPressed: (){
            //                             // CaptureAndShare.shareIt(
            //                             //   sizeWidth: MediaQuery.of(context).size.width,
            //                             //   sizeHeight: 600,
            //                             //   xMode: 'center',
            //                             //   yMode: 'center',
            //                             // );
            //                           }
            //                         )
            //                       ],
            //                 )
            //               ),
            //             ),
            //           ),
            //         ),
            //       ));
            //     }).catchError((onError) {
            //       print(onError);
            //     });
            //   },
            //   tooltip: 'Capture',
            //   child: Icon(Icons.share),
            // ), //
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.share),
              onPressed: () async{
                // StreamBuilder<QuerySnapshot>(
                //   stream:  FirebaseFirestore.instance
                //     .collection('users')
                //     .doc(widget.uid)
                //     .collection('vouchers')
                //     .doc(widget.name)
                //     .collection('customerVouchers')
                //     .doc(widget.voucherId)
                //     .collection('items')
                //     .orderBy('timestamp',descending: false)
                //     .snapshots(),
                //   builder: (context, snapshot) {
                //     if (!snapshot.hasData) {
                //       return Scaffold(
                //         appBar: AppBar(),
                //         body: Center(child: CircularProgressIndicator()));
                //     }
                //     List<TableRow> tableList = [];
                //     List<int> itemsTotal = [];
                //     snapshot.data.docs.forEach((doc) {
                //       Item item = Item.fromDocument(doc);
                //       itemsTotal.add(item.total);
                //       // newList.add(DataRow(
                //       //   cells: [
                //       //     DataCell(Center(child: Text(item.itemName))),
                //       //     DataCell(Center(child: Text(item.price.toString()))),
                //       //     DataCell(Center(child: Text(item.quantity.toString()))),
                //       //     DataCell(Center(child: Text(item.total.toString()))),
                //       //   ])
                //       // );
                //       tableList.add(TableRow(
                //         children: [
                //           TableCell(child: Text(item.itemName),),
                //           TableCell(child: Text(item.price.toString())),
                //           TableCell(child: Text(item.price.toString())),
                //           TableCell(child: Text(item.total.toString()))
                //         ]
                //       ));
                //     });
                //     return Table(
                //       children: tableList,
                //       defaultColumnWidth: FixedColumnWidth(120.0),  
                //       border: TableBorder.all(  
                //         color: Colors.black,  
                //         style: BorderStyle.solid,  
                //         width: 2
                //       ),  
                //     );
                //   },
                // );

                
                final pdfFile = await PdfInvoiceApi.generate(
                  
                  listOfLists: listOfLists,
                  createdDate: widget.createdDate,
                  creator: widget.creator,
                  custId: widget.custId,
                  leftAmt: widget.leftAmt,
                  name: widget.name,
                  payAmt: widget.payAmt,
                  timestamp: widget.timestamp,
                  totalAmt: widget.totalAmt,
                  uid: widget.uid,
                  voucherId: widget.voucherId,
                );
                PDFApi.openFile(pdfFile);
              },
            ),
          );
        });
  }
}
