import 'package:cloud_firestore/cloud_firestore.dart';
class Customer{
  final String name;
  final String custId;
  final Timestamp timestamp;
  final String imageUrl;
  final String kpayNumber;
  final String waveNumber;
  final String phoneNo;
  final String email;

  Customer({this.name, this.custId, this.timestamp, this.imageUrl, this.kpayNumber, this.waveNumber, this.phoneNo, this.email});

  factory Customer.fromDocument(doc){
    return Customer(
      custId: doc['custId'],
      name: doc['name'],
      timestamp: doc['timestamp'],
      imageUrl: doc['imageUrl'],
      kpayNumber: doc['kpayNumber'],
      waveNumber: doc['waveNumber'],
      phoneNo: doc['phoneNo'],
      email: doc['email']
    );
  }
}