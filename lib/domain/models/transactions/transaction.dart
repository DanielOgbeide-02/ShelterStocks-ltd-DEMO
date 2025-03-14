import 'package:intl/intl.dart';  // For formatting date and time


class Transactions {
  final String? transactionType;
  final DateTime transactionDateTime;
  final int? stockUnits;
  final double? stockValue;
  final double? transactionAmount;
  final String? transactionStatus;

  Transactions({
    required this.transactionDateTime,
    this.stockUnits,
    this.stockValue,
    this.transactionAmount,
    this.transactionStatus,
    this.transactionType,
  });

  String get transactionDate => DateFormat('MMM dd, yyyy').format(transactionDateTime);
  String get transactionTime => DateFormat('HH:mm:ss').format(transactionDateTime);
}



