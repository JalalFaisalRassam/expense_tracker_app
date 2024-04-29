class Expense {
  final String id;
  final String name;
  final String description;
  final double amount;
  final String date;
  // final String? image; // Make imageUrl nullable

  Expense({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.date,
    // this.image, // Update imageUrl to be nullable
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'amount': amount.toDouble(),
      'date': date, // Store date as Timestamp
      // 'image': image,
    };
  }

  // String formattedDate() {
  //   return DateFormat('yyyy-MM-dd').format(date);
  // }

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      name: map['name'],
      description: map['description'],
      amount: map['amount'],
      date: (map['date']), // Retrieve date as DateTime
      // image: map['image'],
    );
  }
}
