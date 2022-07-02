class TransactionModel {
  final String name;
  final int quantity;
  final double price;
  final String date;
  final int remaining;
  final String time;
  final String teller;

  TransactionModel(this.remaining, this.time, this.teller,
      {this.name, this.quantity, this.price, this.date});

  TransactionModel.fromFirestore(Map<String, dynamic> firestore)
      : name = firestore['Name'],
        quantity = firestore['Quantity'],
        price = firestore['Price'],
        date = firestore['Date'],
        time = firestore['Time'],
        teller = firestore['Teller'],
        remaining = firestore['Remaining'];
}
