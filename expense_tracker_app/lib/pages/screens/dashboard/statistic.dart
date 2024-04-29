class Statistic {
  final String id;
  final double income;
  final double rest;
  final double spent;

  Statistic({
    required this.id,
    required this.income,
    required this.rest,
    required this.spent,
  });

  Map<String, dynamic> toMap() {
    return {
      'income': income,
      'rest': rest,
      'spent': spent,
    };
  }

  factory Statistic.fromMap(String id, Map<String, dynamic> map) {
    return Statistic(
      id: id,
      income: map['income'],
      rest: map['rest'],
      spent: map['spent'],
    );
  }
}
