class UdhariTransaction {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final bool isCredit; // true = udhari add, false = payment

  UdhariTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });
}