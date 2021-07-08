import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invoice_reckon/models/sales/item.dart';


class RandomEditItem extends StatefulWidget {
  final String uid;
  final String itemId;
  final String custName;
  final String invoiceId;
  final String itemName;

  RandomEditItem({
    this.uid,
    this.custName,
    this.invoiceId,
    this.itemName,
    this.itemId,
  });
  @override
  _RandomEditItemState createState() => _RandomEditItemState();
}

class _RandomEditItemState extends State<RandomEditItem> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  Item item;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool itemNameValidate = true;
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
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(widget.uid)
        .collection('RandomInvoices')
        .doc(widget.custName)
        .collection('items')
        .doc(widget.itemId)
        .get();
    item = Item.fromDocument(doc);
    itemNameController.text = item.itemName;
    priceController.text = item.price.toString();
    qtyController.text = item.quantity.toString();

    setState(() {
      isLoading = false;
    });
  }

  updateItemData() {

    if (itemNameController.text == null || itemNameController.text.trim().length == 0) {
      setState(() {
        itemNameValidate = false;
      });
    } else {
      setState(() {
        itemNameValidate = true;
      });
    }

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

    if (qtyController.text == null || qtyController.text.trim().length == 0) {
      setState(() {
        qtyValidate = false;
      });
    } else {
      setState(() {
        qtyValidate = true;
      });
    }

    if (itemNameValidate && priceValidate & qtyValidate) {
      int total = int.parse(priceController.text) * int.parse(qtyController.text);
      int result = 0;

      FirebaseFirestore.instance.collection('users').doc(widget.uid)
          .collection('RandomInvoices')
          .doc(widget.custName)
          .collection('items')
          .doc(widget.itemId)
          .update({
        'itemName': itemNameController.text,
        'price': int.parse(priceController.text),
        'quantity': int.parse(qtyController.text),
        'total': total
      }).whenComplete(() {
        _scaffoldKey.currentState
            // ignore: deprecated_member_use
            .showSnackBar(SnackBar(content: Text('Edit success!')));
        print('$isLoading');
        Navigator.of(context).pop(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edit Item'),
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
                        'Name', itemNameController ,itemNameValidate),
                    SizedBox(
                      height: 20.0,
                    ),
                    buildEditFormColumn(
                        'Price', priceController, priceValidate),
                    SizedBox(
                      height: 20.0,
                    ),
                    buildEditFormColumn('Qty', qtyController, qtyValidate)
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

  Widget buildEditItemButton( {BuildContext context, String buttonLabel, Function function}) {
    // ignore: deprecated_member_use
    return FlatButton(
      onPressed: function,
      child: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width * 0.5,
        margin: EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
        child: Text(
          buttonLabel,
          style:
          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          color: Theme.of(context).primaryColor),
      )
    );
  }

  Widget buildEditFormColumn(String label, TextEditingController controller, bool isValid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
          controller: controller,
          keyboardType: label == 'Name' ? TextInputType.text : TextInputType.number,
          decoration: InputDecoration(errorText: isValid ? null : 'Error'),
        )
      ],
    );
  }
}
