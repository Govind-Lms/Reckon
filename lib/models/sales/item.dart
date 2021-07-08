import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String itemId;
  final String itemName;
  final int price;
  final int quantity;
  final int total;
  final Timestamp timestamp;

  Item({
    this.itemId,
    this.itemName,
    this.price,
    this.quantity,
    this.total,
    this.timestamp
  });

  factory Item.fromDocument(doc) {
    return Item(
        itemId: doc['itemId'],
        itemName: doc['itemName'],
        price: doc['price'],
        quantity: doc['quantity'],
        total: doc['total'],
        timestamp: doc['timestamp']);
  }
}
