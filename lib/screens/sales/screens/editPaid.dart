import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invoice_reckon/models/sales/voucher.dart';

class EditPaid extends StatefulWidget {
  final String uid;
  final String name;
  final String voucherId;

  EditPaid({
    this.uid,
    this.name,
    this.voucherId,
  });
  @override
  _EditPaidState createState() => _EditPaidState();
}

class _EditPaidState extends State<EditPaid> {
  TextEditingController itemController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  Voucher currentVoucher;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool itemValidate = true;
  bool priceValidate = true;
  bool qtyValidate = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('vouchers')
        .doc(widget.name)
        .collection('customerVouchers')
        .doc(widget.voucherId)
        .get();
    currentVoucher = Voucher.fromDocument(doc);

    priceController.text = currentVoucher.payAmt.toString();

    setState(() {
      isLoading = false;
    });
  }

  updateItemData() {
    if (priceController.text == null ||
        priceController.text.trim().length == 0) {
      setState(() {
        priceValidate = false;
      });
    } else {
      setState(() {
        priceValidate = true;
      });
    }

    if (priceValidate) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('vouchers')
          .doc(widget.name)
          .collection('customerVouchers')
          .doc(widget.voucherId)
          .update({
        'payAmt': int.parse(priceController.text),
        'leftAmt': currentVoucher.totalAmt - int.parse(priceController.text)
      }).whenComplete(() {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text('Edit success!')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edit Paid Money'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: 30.0,
                          ),
                          buildEditFormColumn(
                              'Paid Money', priceController, priceValidate),
                          SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      buildEditItemButton(
                          context: context,
                          buttonLabel: 'Done',
                          function: () {
                            updateItemData();
                          }),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  FlatButton buildEditItemButton(
      {BuildContext context, String buttonLabel, Function function}) {
    return FlatButton(
        onPressed: () {},
        child: Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width * 0.5,
          margin: EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
          child: FlatButton(
            onPressed: function,
            child: Text(
              buttonLabel,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              color: Theme.of(context).primaryColor),
        ));
  }

  Column buildEditFormColumn(
      String label, TextEditingController controller, bool isValid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(errorText: isValid ? null : 'Error'),
        )
      ],
    );
  }
}
