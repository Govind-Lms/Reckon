import 'package:cloud_firestore/cloud_firestore.dart';

class SalesDB{
  
  Stream customerStream(String uid) {
    Stream customersStreams = FirebaseFirestore.instance.collection('users').doc(uid).collection('customers').orderBy('timestamp',descending: true).snapshots();
    return customersStreams;  
  }

  Future<void> getItemData(String uid, String name, String voucherId) async {
    await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('vouchers')
            .doc(name)
            .collection('customerVouchers')
            .doc(voucherId)
            .collection('items')
            .orderBy('timestamp',descending: false)
            .snapshots();
  }
}