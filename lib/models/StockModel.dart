class StockModel {
  final String name;
  final String quantity;
  final String price;
  final String date;

  StockModel({this.name, this.quantity, this.price, this.date});

  StockModel.fromFirestore(Map<String, dynamic> firestore)
      : name = firestore['Name'],
        quantity = firestore['Quantity'],
        price = firestore['Price'],
        date = firestore['Date added'];
}
