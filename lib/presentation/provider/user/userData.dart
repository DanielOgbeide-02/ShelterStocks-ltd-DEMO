import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/sources/firebase_operations/firebase_service.dart';
import '../../../domain/models/user/User.dart';

class UserData with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService(); // Reference to FirebaseService
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Update user information
  void updateUser(String firstName, String lastName, String email, String password,String userId,double stockUnits, double stockValue, String fCMToken) async {
    //NEWLY ADDED (stock units and stock value arguments)
    _currentUser = User(firstName: firstName, lastName: lastName, email: email, password: password, stockUnits: stockUnits, stockValue: stockValue, userId: userId, fCMToken: fCMToken);
    await saveUserData(firstName, lastName, email, password, userId, stockUnits, stockValue, fCMToken);
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> saveUserData(String firstName, String lastName, String email, String password, String userId,double stockUnits, double stockValue, String fCMToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setDouble('stockUnits', stockUnits);
    await prefs.setDouble('stockValue', stockValue);
    await prefs.setString('userId', userId);
    await prefs.setString('fCMToken', fCMToken);



  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString('firstName');
    String? lastName = prefs.getString('lastName');
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    double? stockUnits = prefs.getDouble('stockUnits');
    double? stockValue = prefs.getDouble('stockValue');
    String? userId = prefs.getString('userId');
    String? fCMToken = prefs.getString('fCMToken');


    if (firstName != null && lastName != null && email != null && password != null && stockUnits != null && stockValue != null && fCMToken!=null) {
      _currentUser = User(firstName: firstName, lastName: lastName, email: email, password: password,stockUnits: stockUnits, stockValue: stockValue, userId: userId, fCMToken: fCMToken);
      notifyListeners();
    }
    else{
      print('null values');
    }
  }


  void updateStocks(int newStockUnits,bool isBuy) async {
    if (isBuy) {
      _currentUser!.buyStocks(newStockUnits);
    } else {
      _currentUser!.sellStocks(newStockUnits);
    }
    await saveUserData(_currentUser!.firstName??'', _currentUser!.lastName??'', _currentUser!.email??'', _currentUser!.password??'',_currentUser!.userId??'',_currentUser!.stockUnits??0, _currentUser!.stockValue??0.0,_currentUser!.fCMToken??'');
    notifyListeners();
  }

  // Update just the stock information
  Future<void> updateStockInfo(double stockUnits, double stockValue) async {
    if (_currentUser != null) {
      _currentUser = User(
        firstName: _currentUser!.firstName,
        lastName: _currentUser!.lastName,
        email: _currentUser!.email,
        password: _currentUser!.password,
        userId: _currentUser!.userId,
        fCMToken: _currentUser!.fCMToken,
        stockUnits: stockUnits,
        stockValue: stockValue,
      );

      // Update only stock-related data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('stockUnits', stockUnits);
      await prefs.setDouble('stockValue', stockValue);

      notifyListeners();
    }
  }

  Future<void> fetchAndUpdateUserStocks()async{
    if(_currentUser != null){
      // print('current user id: ${_currentUser!.userId}');
      try{
        // Fetch stock data from Firestore for the current user
        DocumentSnapshot userDoc = await _firebaseService.fetchData('UserInformation', _currentUser!.userId!);
        if (userDoc.exists) {
          //         // Get the stock units and stock value from the fetched document
          double stockUnits = userDoc['stockUnits']?.toDouble() ?? 0.0;
          double stockValue = userDoc['stockValue']?.toDouble() ?? 0.0;
          await updateStockInfo(stockUnits, stockValue);
          // print('user stock value: ${stockValue}');
        }
      }
      catch(e){

      }
    }
  }

  // Get stored password (if needed for specific logic)
  Future<String?> getPassword() async {
    return await SharedPreferences.getInstance().then((prefs) => prefs.getString('password'));
  }

  // Save password to SharedPreferences (not recommended for production)
  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }
}
