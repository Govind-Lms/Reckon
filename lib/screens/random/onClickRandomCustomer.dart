import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:invoice_reckon/screens/random/randomCustomerHistory.dart';
import 'package:invoice_reckon/screens/random/randomInvoiceHistory.dart';
import 'package:invoice_reckon/screens/sales/screens/historyVoucherScreen.dart';
class OnClickRandomCustomer extends StatefulWidget {
  final int leftAmt;
  final int payAmt;
  final int totalAmt;
  final Timestamp createdDate;
  final String custName;
  final String invoiceId;
  final String uid;

  const OnClickRandomCustomer({Key key,this.uid, this.leftAmt, this.payAmt, this.createdDate, this.custName, this.invoiceId, this.totalAmt}) : super(key: key);


  @override
  _OnClickRandomCustomerState createState() => _OnClickRandomCustomerState();
}

class _OnClickRandomCustomerState extends State<OnClickRandomCustomer> {

  void initState() {
    FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('RandomInvoices').get().then((result) {
      voucherSnapshot = result;
      setState(() {

      });
    });
    super.initState();
  }
  QuerySnapshot voucherSnapshot;
  Widget voucherList(){
    return ListView.builder(
        padding: EdgeInsets.only(bottom: 10.0,top: 5.0),
        itemCount: voucherSnapshot.docs.length-voucherSnapshot.docs.length +1,
        itemBuilder: (context,index){
          return VoucherTile(
            custName: widget.custName,
            createdDate: widget.createdDate,
            totalAmt: widget.totalAmt,
            leftAmt: widget.leftAmt,
            payAmt: widget.payAmt,
            invoiceId: widget.invoiceId,
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Details:\t' + widget.custName),
          centerTitle: false,
        ),
        body: voucherSnapshot != null
            ?
        voucherList()
            :
        Container(
          child: Center(
            child: CircularProgressIndicator(),
          )
        ),
    );
  }
}

class VoucherTile extends StatefulWidget {
  final String uid;
  final int leftAmt;
  final int payAmt;
  final int totalAmt;
  final Timestamp createdDate;
  final String custName;
  final String invoiceId;

  VoucherTile({this.uid,this.custName, this.leftAmt, this.payAmt, this.createdDate, this.invoiceId, this.totalAmt});

  @override
  _VoucherTileState createState() => _VoucherTileState();
}

class _VoucherTileState extends State<VoucherTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      // ignore: deprecated_member_use
      child: FlatButton(
        onPressed: (){
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return RandomInvoiceScreen(
          //     uid: widget.uid,
          //     invoiceId: widget.invoiceId,
          //     name: widget.custName,
          //   );
          // }));
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
                  // ignore: unrelated_type_equality_checks
                  imageUrl: widget.leftAmt != 0
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
                            .format(widget.createdDate.toDate()),
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                          DateFormat('h:mm a')
                              .format(widget.createdDate.toDate()),
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.0),
                      // ignore: unrelated_type_equality_checks
                      widget.leftAmt != 0
                          ? Text(
                        'Left Money : ${widget.leftAmt}',
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
                        'Total Amount: ${widget.totalAmt}',
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