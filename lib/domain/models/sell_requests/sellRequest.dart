import 'package:intl/intl.dart';

class SellRequest{
  final String? userId;
  final String? firstName;
  final String? lastName;
  final double? stockUnits;
  final double? stockValue;
  late final bool? qualified;
  bool? soldStatus;
  final DateTime sellRequestDateTime;
  final String? requestId;

  SellRequest({required this.userId,required this.firstName,required this.lastName, this.stockUnits, this.stockValue, this.qualified, required this.sellRequestDateTime,required this.soldStatus, this.requestId}){}
  String get sellRequestDate => DateFormat('MMM dd, yyyy').format(sellRequestDateTime);
  String get sellRequestTime => DateFormat('HH:mm:ss').format(sellRequestDateTime);
}