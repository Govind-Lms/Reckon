import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_reckon/models/sales/item.dart';
import 'package:invoice_reckon/screens/sales/widgets/helpers_invoice/invoice_api.dart';
import 'package:invoice_reckon/screens/sales/widgets/helpers_invoice/pdfapi.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:invoice_reckon/screens/sales/createdInvoiceScreen.dart';
// import 'package:invoice_reckon/screens/sales/editItem.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'createdInvoiceScreen.dart';
import 'editItem.dart';
import 'historyVoucherScreen.dart';

class SalesVoucherCreate extends StatefulWidget {
  final String custId;
  final String uid;
  final String name;
  final String email;
  final String phoneNo;


  SalesVoucherCreate({this.custId,this.name, this.email, this.phoneNo,this.uid});
  _SalesVoucherCreateState createState() =>new  _SalesVoucherCreateState();
}

class _SalesVoucherCreateState extends State<SalesVoucherCreate> {

  void initState() {
    super.initState();
    createdDate = DateTime.now();
  }

  TextEditingController payController= TextEditingController();

  ///item
  String itemName;
  int price;
  int quantity;
  int itemTotal;
  List<int>voucherList=[];
  String voucherId= Random().nextInt(1000000).toString();
  String itemId= Uuid().v4();
  int totalAmt=0;
  int payAmt= 0;
  int leftAmt= 0 ;
  String payDate= 'Day-MM-yyy';
  DateTime createdDate;
  final _scaffoldKey= GlobalKey<ScaffoldState>();
  final SnackBar snackBar= SnackBar(content: Text('Saved...'));

  Future<void> _showDeleteDialog(String  itemId){
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('This item will be deleted')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Ok'),
              onPressed: (){
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .collection('vouchers')
                    .doc(widget.name)
                    .collection('customerVouchers')
                    .doc(voucherId)
                    .collection('items')
                    .doc(itemId)
                    .delete();
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }
  checkAndDelete() async{
    DocumentSnapshot doc= await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('vouchers')
        .doc(widget.name)
        .collection('customerVouchers')
        .doc(voucherId)
        .get();

    if(doc.data == null){
      FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('vouchers')
        .doc(widget.name)
        .collection('customerVouchers')
        .doc(voucherId)
        .collection('items')
        .get()
        .then((snapshot)
        {
         for(DocumentSnapshot ds in snapshot.docs){
           ds.reference.delete();
         }
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    checkAndDelete();
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
        .doc(voucherId)
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
        List<List<String>> listOfLists=List();
        snapshot.data.docs.forEach((doc) {
          Item item = Item.fromDocument(doc);
          itemsTotal.add(item.total);
          newList.add(DataRow(
              onSelectChanged: (value) {
                if (value) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text(item.itemName),
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text('Edit'),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return EditItem(
                                      uid: widget.uid,
                                      itemId: item.itemId,
                                      name: widget.name,
                                      voucherId: voucherId,
                                      itemName: item.itemName,
                                    );
                                  }));
                            },
                          ),
                          SimpleDialogOption(
                            child: Text('Delete'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showDeleteDialog(item.itemId);
                            },
                          )
                        ],
                      );
                    },
                  );
                }
              },
              cells: [
                DataCell(Text(item.itemName,style: TextStyle(color: Colors.black),)),
                DataCell(Text(item.price.toString())),
                DataCell(Text(item.quantity.toString())),
                DataCell(Text(item.total.toString())),
              ]));
          listOfLists.add([item.itemName,item.price.toString(),item.quantity.toString(),item.total.toString()]);
        });

        return  WillPopScope(
          onWillPop: ()async{
            final value = await showDialog<bool>(
                context: context,
                builder: (context){
                  /// alert save button

                  return AlertDialog(
                    content: Text('Sure , Wanna Exit?'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Save'),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.uid)
                              .collection('vouchers')
                              .doc(widget.name)
                              .collection('customerVouchers')
                              .doc(voucherId)
                              .set({
                            'createdDate': createdDate,
                            'custId' : widget.custId,
                            'voucherId': voucherId,
                            'totalAmt': totalAmt,
                            'leftAmt' : leftAmt,
                            'payAmt' : payAmt,
                            'timestamp' : DateTime.now(),
                            'creator' : widget.name,
                          }).whenComplete((){
                            _scaffoldKey.currentState.showSnackBar(snackBar);
                          });
                        },
                      ),
                      FlatButton(
                        child: Text('Yes, Exit'),
                        onPressed: (){
                          Navigator.of(context).pop(true);
                        },
                      )
                    ],
                  );
                }
            );
            return value== true;
          },
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Create Voucher:'+'${widget.name}'),
              actions: [
                IconButton(
                  onPressed: (){
                    _sendMessage('${widget.phoneNo}', 'Hi sir/mam:;\n'
                        'Email:             ${widget.email}\n'
                        'Your Name:         ${widget.name}\n'
                        'Your PhoneNo:      ${widget.phoneNo}\n'
                        'Your Total Amount: $itemTotal\n'
                        'Your InvoiceId:    ${widget.name}\n'
                        'Created Date:      $createdDate\n'
                        'Invoice Id:        $voucherId\n'
                    );
                  },
                  icon: Icon(Icons.send_outlined,color: Colors.white,),
                )
              ],
            ),
            body: ListView(
              children: [

                ///created Date
                Container(
                  margin: EdgeInsets.only(left: 20.0,top: 20.0),
                  child: Text(
                    'Created Date :' + DateFormat('dd-MM-yyyy').format(DateTime.now()),
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.w300),
                  ),
                ),
                ///item table
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(label: Text('Name'),numeric: false),
                        DataColumn(label: Text('Price'),numeric: true),
                        DataColumn(label: Text('Qty'),numeric: true),
                        DataColumn(label: Text('Total'),numeric: true),
                      ],
                      rows: newList

                    ),
                  ),
                ),

                ///add item
                InkWell(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      expand: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0))),
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          bottom: false,
                          child: Container(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.top),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(alignment: Alignment.topLeft,child: Text('Brief Data',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),)),
                                  SizedBox(height: 10.0,),
                                  TextFormField(
                                    validator: (val) => val.isEmpty ? "Enter item name" : null,
                                    decoration: InputDecoration(
                                      hintText: "Item Name",
                                      prefixIcon: Icon(Icons.account_circle,size: 25.0,),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val){
                                      itemName= val;
                                    },
                                  ),
                                  SizedBox(height: 5.0,),
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: (val) => val.isEmpty ? "Enter item price" : null,
                                    decoration: InputDecoration(
                                      hintText: "Item Price",
                                      prefixIcon: Icon(Icons.money,size: 25.0,),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val){
                                      price= int.parse(val.trim());
                                    },
                                  ),
                                  SizedBox(height: 5.0,),
                                  TextFormField(
                                    validator: (val) => val.isEmpty ? "Enter item quantity" : null,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Item Quantity",
                                      prefixIcon: Icon(Icons.calculate,size: 25.0,),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val){
                                      quantity= int.parse(val.trim());
                                    },
                                  ),
                                  SizedBox(height: 5.0,),
                                  GestureDetector(
                                    onTap: (){
                                      if (itemName == null ||
                                          itemName.trim().length == 0) {
                                      } else if (price == null) {
                                      } else if (quantity == null) {
                                      } else {
                                        itemTotal = price * quantity;
                                        voucherList.add(itemTotal);
                        
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.uid)
                                            .collection('vouchers')
                                            .doc(widget.name)
                                            .collection('customerVouchers')
                                            .doc(voucherId)
                                            .collection('items')
                                            .doc(itemId)
                                            .set({
                                          'itemName': itemName,
                                          'itemId': itemId,
                                          'price': price,
                                          'quantity': quantity,
                                          'total': itemTotal,
                                          'timestamp': DateTime.now()
                                        });
                        
                                        setState(() {
                                          itemId = Uuid().v4();
                                          itemName = '';
                                          price = null;
                                          quantity = null;
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(.7),
                                          borderRadius: BorderRadius.circular(5.0)
                                      ),
                                      child: Text(
                                        "Add Items",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                        );
                    });
                  },
                  child: Center(
                    child: Text('Add Items',style: TextStyle(color: Colors.redAccent.withOpacity(.7),fontSize: 16.0,fontWeight: FontWeight.bold),),
                  ),
                ),

                ///calculate total
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40.0,
                    margin: EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () async{
                        int result= 0 ;
                        itemsTotal.forEach((val){
                          result +=val;
                        });
                        leftAmt= result-payAmt;
                        setState(() {
                          totalAmt= result;
                        });
                      },
                      child: Container(

                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(.7),
                            borderRadius: BorderRadius.circular(5.0)
                        ),
                        child: Text(
                          "Calculate Total",
                          style: TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                ///data table
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns:[
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('Total Amount')),
                          DataCell(Text(':')),
                          DataCell(Text(' '+ totalAmt.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pay Amount')),
                          DataCell(Text(':')),
                          DataCell(
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *0.30,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(),
                                        alignLabelWithHint: true,
                                        hintText: 'Enter Amount'
                                    ),
                                    onChanged: (val){
                                      if(val.isEmpty || val == null){
                                        payAmt = 0;
                                      }
                                      else{
                                        payAmt= int.parse(val.trim());
                                      }
                                      setState(() {
                                        leftAmt = totalAmt - payAmt;
                                        payDate = DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now());
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                    controller: payController,
                                    style: TextStyle(fontSize: 13.0),
                                  ),
                                ),
                              )
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pay Date')),
                          DataCell(Text(':')),
                          DataCell(Text(' '+ payDate.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Left Amount',style: TextStyle(
                              color: leftAmt==0 ? Colors.green : Colors.red
                          ),)),
                          DataCell(Text(':')),
                          DataCell(Text(' '+ leftAmt.toString(),style: TextStyle(
                              color: leftAmt==0 ? Colors.green : Colors.red
                          ),)),
                        ]),
                      ],
                    ),
                  ),
                ),

                ///save button
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                      color: Colors.redAccent.withOpacity(.7),                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 40.0,
                    margin: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        'Save',
                        style: TextStyle(
                            color: Colors.white,fontWeight: FontWeight.bold
                        ),
                      ),
                      onPressed: (){
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection('vouchers')
                            .doc(widget.name)
                            .collection('customerVouchers')
                            .doc(voucherId)
                            .set({
                          'createdDate': createdDate,
                          'custId' : widget.custId,
                          'voucherId': voucherId,
                          'totalAmt': totalAmt,
                          'leftAmt' : leftAmt,
                          'payAmt' : payAmt,
                          'timestamp' : DateTime.now(),
                          'creator' : widget.name,
                        }).whenComplete(() async {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context)=> CreatedInvoiceScreen(
                          //   voucherId: voucherId,
                          //   custId: widget.custId,
                          //   uid: widget.uid,
                          //   name: widget.name,
                          // )));
                          final pdfFile = await PdfInvoiceApi.generate(
                            createdDate: Timestamp.now(),
                            creator: widget.name,
                            custId: widget.custId,
                            leftAmt: leftAmt,
                            name: widget.custId,
                            payAmt: payAmt,
                            listOfLists: listOfLists,
                            timestamp:  Timestamp.now(),
                            totalAmt: totalAmt,
                            uid: widget.uid,
                            voucherId: voucherId,
                          );
                          PDFApi.openFile(pdfFile);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _sendMessage(String toSmsId,
      String message) async {
    var url;
    if(Platform.isAndroid){
      url ='sms:$toSmsId?body=$message';
      await launch(url);
    }
    else if(Platform.isIOS){
      throw 'Could not launch $url';
    }
  }
}
