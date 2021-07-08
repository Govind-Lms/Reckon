import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:invoice_reckon/screens/random/onClickRandomCustomer.dart';

class RandomVoucherHistory extends StatefulWidget {
  final String uid,custName;

  const RandomVoucherHistory({this.uid,this.custName});
  @override
  _RandomVoucherHistoryState createState() => _RandomVoucherHistoryState();
}

class _RandomVoucherHistoryState extends State<RandomVoucherHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('RandomInvoices').orderBy('createdDate',descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(!snapshot.hasData){
            return Center(child:CircularProgressIndicator());
          }
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 10.0,top: 5.0),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context,index){
              return RandomCustomerTile(
                custName: snapshot.data.docs[index].get('custName'),
                createdDate: snapshot.data.docs[index].get('createdDate'),
                invoiceId: snapshot.data.docs[index].get('invoiceId'),
                leftAmt: snapshot.data.docs[index].get('leftAmt'),
                payAmt: snapshot.data.docs[index].get('payAmt'),
                totalAmt: snapshot.data.docs[index].get('totalAmt'),
              );
            }
          );
        },
      ),
    );
  }
}

class RandomCustomerTile extends StatefulWidget {
  final int leftAmt;
  final int payAmt;
  final Timestamp createdDate;
  final String custName;
  final String invoiceId;
  final int totalAmt;

  const RandomCustomerTile({Key key, this.leftAmt, this.payAmt, this.createdDate, this.custName, this.invoiceId, this.totalAmt}) : super(key: key);

  @override
  _RandomCustomerTileState createState() => _RandomCustomerTileState();
}

class _RandomCustomerTileState extends State<RandomCustomerTile> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OnClickRandomCustomer(
          custName: widget.custName,
          leftAmt: widget.leftAmt,
          payAmt: widget.payAmt,
          createdDate: widget.createdDate,
          invoiceId: widget.invoiceId,
          totalAmt: widget.totalAmt,

        )));
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0),
        height: 50.0,
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(width: 0.5, color: Colors.blueGrey)
        ),
        child: Row(
          children: <Widget>[
            Text(widget.custName,style: TextStyle(color: Colors.black),)
          ],
        ),
      ),
    );
  }
}
