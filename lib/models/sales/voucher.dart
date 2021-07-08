import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher{
  final String voucherId;
  final String custId;
  final int totalAmt;
  final int payAmt;
  final int leftAmt;
  final Timestamp timestamp;
  final Timestamp createdDate;
  final String creator;

  Voucher({this.voucherId, this.custId, this.totalAmt, this.payAmt, this.leftAmt, this.timestamp, this.createdDate, this.creator});

  factory Voucher.fromDocument(doc){
    return Voucher(
      voucherId: doc['voucherId'],
      custId: doc['custId'],
      totalAmt: doc['totalAmt'],
      payAmt: doc['payAmt'],
      leftAmt: doc['leftAmt'],
      timestamp: doc['timestamp'],
      createdDate: doc['createdDate'],
      creator: doc['creator']
    );
  }


}