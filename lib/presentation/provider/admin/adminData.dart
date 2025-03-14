import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelterstocks_prototype2/domain/models/admin/admin.dart';

import '../../../data/sources/firebase_operations/firebase_service.dart';

class Admindata with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService(); // Reference to FirebaseService
  Admin? _currentAdmin;

  List<Map<String, dynamic>> allUsersData = [];
  List<String> allUserNames = [];
  Admin? get currentAdmin => _currentAdmin;
  List<Map<String, dynamic>> totalShelterStocks = [];

  int get allUsersCount => allUsersData.length;

  Future<void> fetchTotalShelterStocks()async{
    try{
      totalShelterStocks = await _firebaseService.fetchAllShelterStocks();
      notifyListeners();
    }
    catch(e){
      print("Error fetching shelterStocks: ${e.toString()}");
    }
  }

  // Function to fetch all user' data and store it in allUsersData list
  Future<void> fetchAndStoreAllUsersData() async {
    try {
      // Call the fetchAllUsersData function from the external service file
      allUsersData = await _firebaseService.fetchAllUsersData();
      // Call function to generate full names after fetching the data
      extractAndStoreFullUserNames();
      notifyListeners();  // Notify listeners that data has changed
    } catch (e) {
      print("Error fetching user' data: ${e.toString()}");
    }
  }

  // Function to extract and store full names (first name + last name)
  void extractAndStoreFullUserNames() {
    allUserNames.clear();  // Clear any previous data

    for (var userData in allUsersData) {
      String fullName = '${userData['firstName']} ${userData['lastName']}';
      allUserNames.add(fullName.trim());
    }
    notifyListeners();  // Notify listeners that the list of names has been updated
  }

  // Update user information
  void updateAdmin(String email, String role, String adminId) async {
    _currentAdmin = Admin(email:email, role: role, adminId: adminId);
    await saveAdminData(email, role, adminId);
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> saveAdminData(String email, String role,String adminId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adminEmail', email);
    await prefs.setString('role', role);
    await prefs.setString('Admin Id', adminId);
  }

  // Load user data from SharedPreferences
  Future<void> loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    String? adminEmail = prefs.getString('adminEmail');
    String? role = prefs.getString('role');
    String? adminId = prefs.getString('Admin Id');


    if (adminEmail != null && role != null && adminId != null) {
      _currentAdmin = Admin(email: adminEmail, role: role, adminId: adminId);
      notifyListeners();
    }
    else{
      print('null values');
    }
  }

  void updateStocks(int newStockUnits,bool isBuy) async {
    // if (isBuy) {
    //   _currentUser!.buyStocks(newStockUnits);
    // } else {
    //   _currentUser!.sellStocks(newStockUnits);
    // }
    // await saveUserData(_currentUser!.firstName??'', _currentUser!.lastName??'', _currentUser!.email??'', _currentUser!.password??'',_currentUser!.userId??'',_currentUser!.stockUnits??0, _currentUser!.stockValue??0.0 );
    notifyListeners();
  }

}
