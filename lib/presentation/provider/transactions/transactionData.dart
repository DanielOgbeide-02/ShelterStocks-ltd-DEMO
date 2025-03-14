import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shelterstocks_prototype2/domain/models/transactions/transaction.dart';
import '../../../data/sources/firebase_operations/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class transactionData extends ChangeNotifier{
  final FirebaseService _firebaseService = FirebaseService(); // Reference to FirebaseService
  List<Transactions> _transactions = [];

  UnmodifiableListView<Transactions> get transactions{
    return UnmodifiableListView(_transactions);
  }

  int get transactionCount => _transactions.length;

  String getMonth(int month) {
    return DateFormat('MMM').format(DateTime(2023, month));
  }

  Future<void> addNewTransaction(String uid, String type, DateTime date, int units, double value, double amount, String status) async {
    final newTransaction = Transactions(
      transactionDateTime: date,
      stockUnits: units,
      stockValue: value,
      transactionAmount: amount,
      transactionStatus: status,
      transactionType: type,
    );
    _transactions.insert(0, newTransaction);  // Add to the beginning of the list
    notifyListeners();

    await _firebaseService.addTransaction(uid, {
      'transactionType': type,
      'transactionDate': date,
      'stockUnits': units,
      'stockValue': value,
      'transactionAmount': amount,
      'transactionStatus': status,
    });
  }

  Future<bool> fetchTransaction(String uid) async {
    try {
      List<Map<String, dynamic>> transactionList = await _firebaseService.fetchTransactions(uid);
      _transactions = transactionList.map((data) => Transactions(
        transactionType: data['transactionType'],
        transactionDateTime: (data['transactionDate'] as Timestamp).toDate(),
        stockUnits: data['stockUnits'],
        stockValue: data['stockValue'],
        transactionAmount: data['transactionAmount'],
        transactionStatus: data['transactionStatus'],
      )).toList();

      _transactions.sort((a, b) => b.transactionDateTime.compareTo(a.transactionDateTime));
      notifyListeners();
      return true;
    } catch (ex) {
      print('Error fetching transactions: $ex');
      return false;
    }
  }


  SplayTreeMap<String, List<Transactions>> groupTransactionsByMonth() {
    SplayTreeMap<String, List<Transactions>> groupedTransactions = SplayTreeMap<String, List<Transactions>>((a, b) => b.compareTo(a));
    for (var transaction in _transactions) {
      String monthKey = "${getMonth(transaction.transactionDateTime.month)} ${transaction.transactionDateTime.year}";
      groupedTransactions.putIfAbsent(monthKey, () => []).add(transaction);
    }
    return groupedTransactions;
  }


  Map<String, Map<String, double>> calculateMonthlyTotals() {
    Map<String, Map<String, double>> monthlyTotals = {};
    for (var transaction in _transactions) {
      String monthKey = "${getMonth(transaction.transactionDateTime.month)} ${transaction.transactionDateTime.year}";
      monthlyTotals.putIfAbsent(monthKey, () => {'incoming': 0.0, 'outgoing': 0.0});
      if (transaction.transactionType == "Buy") {
        monthlyTotals[monthKey]!['incoming'] = (monthlyTotals[monthKey]!['incoming'] ?? 0.0) + (transaction.transactionAmount ?? 0.0);
      } else if (transaction.transactionType == "Sell") {
        monthlyTotals[monthKey]!['outgoing'] = (monthlyTotals[monthKey]!['outgoing'] ?? 0.0) + (transaction.transactionAmount ?? 0.0);
      }
    }
    return monthlyTotals;
  }

  Future<void> clearTransactionsOnLogout() async {
    _transactions.clear();
    notifyListeners();
  }

  Future<void> loadTransactions(String uid) async {
    bool success = await fetchTransaction(uid);
    if (success) {
      notifyListeners();  // Notify listeners after successfully fetching transactions
    } else {
      print('Failed to load transactions.');
    }
  }

}





