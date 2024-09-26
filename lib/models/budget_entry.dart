import 'package:hive/hive.dart';

part 'budget_entry.g.dart';

@HiveType(typeId: 0)
class BudgetEntry extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String recurrence; // e.g., 'daily', 'weekly', 'monthly'

  @HiveField(4)
  final DateTime nextDueDate;

  BudgetEntry({
    required this.category,
    required this.amount,
    required this.date,
    required this.recurrence,
    required this.nextDueDate,
  });
}
