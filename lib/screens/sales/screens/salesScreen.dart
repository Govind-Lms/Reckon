import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoice_reckon/models/sales/customer.dart';
import 'package:invoice_reckon/models/sales/user.dart';
import 'package:invoice_reckon/firebase/auth.dart';
import 'package:invoice_reckon/screens/sales/screens/salesClientDetail.dart';
import 'package:invoice_reckon/screens/sales/screens/salesVoucherCreate.dart';
import 'package:invoice_reckon/screens/sales/screens/salesVoucherHistory.dart';
import 'package:invoice_reckon/screens/sales/widgets/salesDb.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:invoice_reckon/screens/sales/screens/salesVoucherCreate.dart';
// import 'package:invoice_reckon/screens/sales/screens/salesVoucherHistory.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';


class SalesScreen extends StatefulWidget {
  final String uid;
  const SalesScreen({ this.uid});
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Customer customer;

  String name;
  Timestamp timestamp;
  String imageUrl;
  String kpayNumber;
  String waveNumber;
  String phoneNo;
  String email;
  String custId= Uuid().v4();

  ///pick image
  bool _load = false;
  File _selectedimage;
  UserModel userModel;

 
  Future getImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _selectedimage = File(pickedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Clients',style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          SizedBox(height: 10.0,),
          GestureDetector(
            onTap: (){
              showMaterialModalBottomSheet(
                expand: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
                context: context,
                builder:(context){
                  return SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.left
                      ),
                      child: Container(
                        margin: EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 10.0,),
                              Container(alignment: Alignment.topLeft,child: Text('Brief Data',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),)),
                              SizedBox(height: 10.0,),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      getImage();
                                    },
                                    child: Container(
                                      height: 60.0,
                                      width: 60.0,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.0),
                                          color: Colors.blue[100]
                                      ),
                                      child: _selectedimage != null ?
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child: Image.file(_selectedimage, fit: BoxFit.cover,),
                                      )
                                          :
                                      Center(
                                          child: IconButton(
                                            icon: Icon(Icons.camera),
                                            onPressed: (){
                                              getImage();
                                            },
                                          )
                  
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width-100,
                                    child: TextFormField(
                                      validator: (val) => val.isEmpty ? "Enter Client Name" : null,
                                      decoration: InputDecoration(
                                        hintText: "Client Name",
                                        prefixIcon: Icon(Icons.account_circle,size: 25.0,),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val){
                                        name = val;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                  
                              TextFormField(
                                keyboardType: TextInputType.number,
                                validator: (val) => val.isEmpty ? "Enter Phone No" : null,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.phone,size: 25.0,),
                                  hintText: "Client Phone Number",
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val){
                                  phoneNo= val;
                                },
                              ),
                              SizedBox(height: 10,),
                  
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) => val.isEmpty ? "Enter Phone No" : null,
                                decoration: InputDecoration(
                                  hintText: "Client Email Address",
                                  prefixIcon: Icon(Icons.email,size: 25.0,),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val){
                                  email= val;
                                },
                              ),
                              SizedBox(height: 10.0,),
                  
                  
                  
                              ///payments
                              SizedBox(height: 10.0,),
                              Container(alignment: Alignment.topLeft,child: Text('Payment Data',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),)),
                              SizedBox(height: 10.0,),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                validator: (val) => val.isEmpty ? "Enter KPay Phone No" : null,
                                decoration: InputDecoration(
                                  hintText: "KBZ Pay Acc Number",
                                  prefixIcon: Icon(Icons.payment,size: 25.0,),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val){
                                  kpayNumber= val;
                                },
                              ),
                              SizedBox(height: 10.0,),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                validator: (val) => val.isEmpty ? "Enter WavePay Phone No" : null,
                                decoration: InputDecoration(
                                  hintText: "WavePay Acc Number",
                                  prefixIcon: Icon(Icons.payment,size: 25.0,),
                  
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val){
                                  waveNumber= val;
                                },
                              ),
                              SizedBox(height: 20.0,),
                              ///Button
                              Container(
                                child: !_load ? 
                                FlatButton(
                                  onPressed: () async{
                                    setState(() {
                                      _load= false;
                                    });
                                    Reference storageReference = FirebaseStorage.instance
                                        .ref()
                                        .child("clientImages")
                                        .child("${randomAlphaNumeric(9)}.jpg");
                                    Task task = storageReference.putFile(_selectedimage);
                                    var downloadUrl = await(await task).ref.getDownloadURL();
                                    FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('customers').doc(custId).set({
                                      'name': name,
                                      'phoneNo': phoneNo,
                                      'email': email,
                                      'waveNumber': waveNumber,
                                      'kpayNumber': kpayNumber,
                                      'imageUrl': downloadUrl,
                                      'custId': custId,
                                      'timestamp': DateTime.now(),
                                    });
                                    var doc= await FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('customers').doc(custId).get();
                                    setState(() {
                                      custId= Uuid().v4();
                                    });
                                    Navigator.pop(context);
                                    return doc;
                                  },
                                  child: Container(
                                    height: 50.0,
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width+40,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(5.0)
                                    ),
                                    child: Text(
                                      "Add Clients",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ): Center(child: CircularProgressIndicator(),),
                              ),
                              SizedBox(height: 20.0,)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(left: 10.0,right: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(width: 1.0,color: Colors.redAccent)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        //color: Colors.white
                    ),
                    child: Icon(
                      Icons.add,
                      size: 25.0,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Container(
                    child: Text('Add Clients',style: TextStyle(fontSize: 14.0),),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: SalesDB().customerStream(widget.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(),);
                }
                List<CustomerTile> customerTiles = [];
                snapshot.data.docs.forEach((doc){
                  Customer customer = Customer.fromDocument(doc);
                  customerTiles.add(CustomerTile(customer,widget.uid));
                });
                if(customerTiles.length==0){
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 10.0,),
                        Icon(
                          Icons.people,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text('No Customers')
                      ],
                    ),
                  );
                }
                return ListView(
                  children: customerTiles,
                );
              }
            ),
          ),
          // IconButton(icon: Icon(Icons.add),onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=> CreatePDFInvoice()));},)
        ],
      ),
    );
  }
}




class CustomerTile extends StatefulWidget {
  final Customer customer;
  final String uid;

  const CustomerTile(this.customer,this.uid);
  @override
  _CustomerTileState createState() => _CustomerTileState();
}

class _CustomerTileState extends State<CustomerTile> {

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This customer will be deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                FirebaseFirestore.instance.collection('users').doc(widget.uid)
                    .collection('customers')
                    .doc(widget.customer.custId)
                    .delete();

                FirebaseFirestore.instance.collection('users').doc(widget.uid)
                    .collection('vouchers')
                    .doc(widget.customer.name)
                    .collection('customerVouchers')
                    .get()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.docs) {
                    ds.reference.delete();
                  }
                });

                FirebaseFirestore.instance.collection('users').doc(widget.uid)
                    .collection('vouchers')
                    .doc(widget.customer.name)
                    .collection('customerVouchers')
                    .get()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.docs) {
                    ds.reference
                        .collection('items')
                        .get()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.docs) {
                        ds.reference.delete();
                      }
                    });
                    ds.reference.delete();
                  }
                });

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
    return GestureDetector(
      onTap: (){
        showDialog(
            context: context,
            builder: (context){
              return SimpleDialog(
                children: [
                  ///view info
                  SimpleDialogOption(
                    child: Row(children: [
                      Icon(Icons.info, color: Colors.black,size: 20.0,),
                      SizedBox(width: 20.0,),
                      Text('View Info'),
                    ],),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SalesClientDetail(
                        custId: widget.customer.custId,
                        name: widget.customer.name,
                        imageUrl: widget.customer.imageUrl,
                        email: widget.customer.email,
                        phoneNo: widget.customer.phoneNo,
                        waveNumber: widget.customer.waveNumber,
                        kpayNumber: widget.customer.kpayNumber,
                      )));
                    },
                  ),
                  ///create voucher
                  SimpleDialogOption(
                    child: Row(children: [
                      Icon(Icons.create, color: Colors.black,size: 20.0,),
                      SizedBox(width: 20.0,),
                      Text('Create New Voucher'),
                    ],),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SalesVoucherCreate(
                        uid: widget.uid,
                        phoneNo: widget.customer.phoneNo,
                        email: widget.customer.email,
                        custId: widget.customer.custId,
                        name: widget.customer.name
                      )));
                    },
                  ),
                  ///view History
                  SimpleDialogOption(
                    child: Row(children: [
                      Icon(Icons.history, color: Colors.black,size: 20.0,),
                      SizedBox(width: 20.0,),
                      Text('View History'),
                    ],),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SalesVoucherHistory(
                        custId: widget.customer.custId,
                        uid: widget.uid,
                        name: widget.customer.name,
                      )));
                    },
                  ),
                  ///delete
                  SimpleDialogOption(
                      child: Row(children: [
                        Icon(Icons.delete, color: Colors.black,size: 20.0,),
                        SizedBox(width: 20.0,),
                        Text('Delete'),
                      ],),
                    onPressed: (){
                      _showDeleteDialog();
                    }
                  ),
                ],
              );
            }
        );

      },
      child: Container(
        height: 80.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                offset: Offset(0,0),
                color: Colors.redAccent.withOpacity(0.3),
              )
            ]
        ),
        margin: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0,top: 5.0),
              width: 70.0,
              height: 70.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0,color: Colors.white),
                  borderRadius: BorderRadius.circular(50.0),
                  color: Colors.white
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CachedNetworkImage(
                  imageUrl: widget.customer.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 20.0),
              child: Text(
                widget.customer.name,
                style: TextStyle(
                    color: Colors.black,fontSize: 16.0,
                    fontWeight: FontWeight.w600
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
