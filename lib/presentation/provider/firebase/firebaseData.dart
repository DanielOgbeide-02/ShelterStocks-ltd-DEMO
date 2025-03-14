import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelterstocks_prototype2/presentation/provider/transactions/transactionData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/notification/notificationData.dart';
import '../../../common/widgets/flush_bar/Flushbar.dart';
import '../../../data/sources/firebase_operations/firebase_service.dart';

String extractFirebaseErrorMessage(String errorMessage) {
  // Split the error message using the closing bracket ']'
  int startIndex = errorMessage.indexOf(']') + 1;

  // If the bracket was found, return the part after it, otherwise return the original message
  if (startIndex > 0 && startIndex < errorMessage.length) {
    return errorMessage.substring(startIndex).trim();
  } else {
    return errorMessage; // Return the full message if the pattern doesn't match
  }
}

class FirebaseProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseService get firebaseService => _firebaseService;

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Successfully signed up
      final User? user = userCredential.user;

      if (user != null) {
        await _firebaseService.addData('UserInformation', user.uid, {'uid': user.uid});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedin', true);
        notifyListeners(); // Notify listeners if necessary
        return {'user': user, 'error': null}; // Return user and no error
      } else {
        // If no user is returned, something went wrong
        return {'user': null, 'error': 'Sign Up failed. Please try again.'};
      }
    } catch (e) {
      // Catch any exception during sign-up and return the error message
      String errorMessage = extractFirebaseErrorMessage(e.toString());
      return {'user': null, 'error': errorMessage}; // Return null user and the error message
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if(user!=null){
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdmin', false);
      await prefs.setBool('isLoggedin', true);
      notifyListeners();
      return {'user': user, 'error': null};
      }
      else{
        return {'user': null, 'error': 'Sign In failed. Please try again.'};
        // Return user and no error
      }
    } catch (e) {
      String errorMessage = extractFirebaseErrorMessage(e.toString());
      return {'user': null, 'error': errorMessage}; // Return null user and the error message
    }
  }

  //sign in admin
  Future<Map<String, dynamic>> signInAdmin(String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if(user!=null){
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedin', true);
        await prefs.setBool('isAdmin', true);
        notifyListeners();
        return {'user': user, 'error': null};
      }
      else{
        return {'user': null, 'error': 'Sign In failed. Please try again.'};
        // Return user and no error
      }
    } catch (e) {
      String errorMessage = extractFirebaseErrorMessage(e.toString());
      return {'user': null, 'error': errorMessage}; // Return null user and the error message
    }
  }







  Future<void> signOut(transactionData transactionsProvider, notificationData notificationProvider) async {
    await transactionsProvider.clearTransactionsOnLogout();
    await notificationProvider.clearNotificationsOnLogout();
    await _firebaseService.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedin', false);
    var loggedOut = await prefs.getBool('isLoggedin')??false;
    print('logging out: ${loggedOut}');
    notifyListeners();
  }

  Future<void> signOutAdmin(String role) async {
    await _firebaseService.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedin', false);
    prefs.setBool('isAdmin', false);
    var loggedOut = await prefs.getBool('isLoggedin')??false;
    var isAdmin = await prefs.getBool('isAdmin')??false;
    print('logging out: ${loggedOut}');
    print('is admin? : ${isAdmin}');
    notifyListeners();
  }



  // Get current user
  User? getCurrentUser() {
    return _firebaseService.getCurrentUser();
  }

  // Add data to Firestore
  Future<void> addData(String collection, String uid,Map<String, dynamic> data) async {
    await _firebaseService.addData(collection, uid,data);
    notifyListeners();
  }

  Future<void> addTransaction(String uid, Map<String, dynamic> transactionData) async {
    try {
      // Access the user's document by uid, then add a new document to the 'transactions' subcollection
      await _firebaseService.addTransaction(uid, transactionData)       ;   // Add a new transaction document
    } catch (e) {
      print(e.toString());  // Handle errors
    }
  }


  // Fetch data from Firestore
  Future<DocumentSnapshot<Object?>> fetchData(String collection, String userId) async {
    DocumentSnapshot data = await _firebaseService.fetchData(collection, userId);
    notifyListeners();
    return data;
  }

  // Update data in Firestore
  Future<Map<String, String>> updateData(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firebaseService.updateData(collection, docId, data);
      notifyListeners();
      return {'status': 'success','message':'Successfully Updated'};
    }
    catch(ex){
      String errorMessage = extractFirebaseErrorMessage(ex.toString());
      print(ex.toString());
      return {'status': 'error','message':'${errorMessage}'};

    }
  }

  // Delete data from Firestore
  Future<void> deleteData(String collection, String docId) async {
    await _firebaseService.deleteData(collection, docId);
    notifyListeners();
  }



  Future<Map<String, String>> updatePassword(String email) async {
    try {
      await _firebaseService.updatePassword(email);
      notifyListeners();
      return {'status': 'success', 'message': 'Password updated successfully'};
    } catch (e) {
      String errorMessage = extractFirebaseErrorMessage(e.toString());
      return {'status': 'error', 'message': errorMessage};
    }
  }

  Future<String> reauthenticateUser(String email, String password) async {
    try{
      String message = await _firebaseService.reauthenticateUser(email, password);
      print('Firebase data message: ${message}');
      notifyListeners();
      return message;
    }
    catch(e){
      String errorMessage = extractFirebaseErrorMessage(e.toString());
      return errorMessage;
    }
  }

  Future<Map<String, String>> updateEmail(String newEmail) async {
    try {
      Map<String, dynamic> result = await _firebaseService.verifyBeforeUpdateEmail(newEmail);
      if (result['status']) {
        notifyListeners();
        return {'status': 'success', 'message': result['message']};
      } else {
        return {'status': 'error', 'message': result['message']};
      }
    } catch (e) {
      String errorMessage = extractFirebaseErrorMessage(e.toString());
      return {'status': 'error', 'message': errorMessage};
    }
  }
}
