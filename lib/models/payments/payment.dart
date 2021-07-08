class PaymentModel{
  final String name;
  final int lastPayment;

  PaymentModel({this.name, this.lastPayment});

  factory PaymentModel.fromDocument(doc){
    return PaymentModel(
      lastPayment: doc['lastPayment'],
      name: doc['name'],
    );
  }
}