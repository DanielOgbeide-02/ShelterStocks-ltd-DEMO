import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../common/helpers/functions/getAccessToken.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  //notification start
  Future<void> initNotifications() async{
    //request permission from user
    await _firebaseMessaging.requestPermission();
    //fetch FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    //print the token
    print('user token: ${fCMToken}');
  }
  //notification end

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle error
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle error
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Add data to Firestore
  Future<void> addData(String collection, String uid,Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(uid).set(data);
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }
  Future<Map<String, dynamic>> addTransaction(String uid, Map<String, dynamic> transactionData) async {
    try {
      // Access the user's document by uid, then add a new document to the 'transactions' subcollection
      await _firestore
          .collection('UserInformation')  // Main collection for user data
          .doc(uid)                       // Navigate to the specific user by uid
          .collection('transactions')      // Access 'transactions' subcollection
          .add(transactionData);

      return {'status': 'Success'};// Add a new transaction document
    } catch (e) {
      print(e.toString());
      return {'status': 'Failed'};// Handle errors
    }
  }

  Future<Map<String, dynamic>> addToSubCollection(String uid,String subCollection,Map<String, dynamic> Data) async {
    try {
      // Access the user's document by uid, then add a new document to the 'transactions' subcollection
      await _firestore
          .collection('UserInformation')  // Main collection for user data
          .doc(uid)                       // Navigate to the specific user by uid
          .collection(subCollection)      // Access 'transactions' subcollection
          .add(Data);

      return {'status': 'Success'};// Add a new transaction document
    } catch (e) {
      print(e.toString());
      return {'status': 'Failed'};// Handle errors
    }
  }
  Future<List<Map<String, dynamic>>> fetchFromSubCollection(String uid, String subCollection) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('UserInformation')
          .doc(uid)
          .collection(subCollection)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to fetch sub collection data: $e');
    }
  }

  // Fetch transactions for a user
  Future<List<Map<String, dynamic>>> fetchNotifFromSubCollection(String uid, String subCollection) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('UserInformation')
          .doc(uid)
          .collection(subCollection)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add the document ID to the map
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch sub collection data: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchTransactions(String uid) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('UserInformation')
          .doc(uid)
          .collection('transactions')
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<void> addSellRequest(String uid, Map<String, dynamic> sellRequestData) async {
    try {
      await _firestore
          .collection('AdminInformation')
          .doc(uid)
          .collection('Sell Requests')
          .add(sellRequestData);
    } catch (e) {
      print(e.toString());  // Handle errors
    }
  }


  Future<List<Map<String, dynamic>>> fetchSellRequest(String adminId) async {
    try {
      // Fetch all documents from the 'Sell Requests' sub-collection for the specified admin
      QuerySnapshot snapshot = await _firestore
          .collection('AdminInformation')
          .doc(adminId)
          .collection('Sell Requests')
          .get();

      // Map each document to include its document ID and return as a list of maps
      return snapshot.docs.map((doc) {
        // Add the document ID to the returned map
        return {
          'docId': doc.id,  // Document ID
          ...doc.data() as Map<String, dynamic>  // Document data
        };
      }).toList();
    } catch (e) {
      // If something goes wrong, throw an exception with an error message
      throw Exception('Failed to fetch sell requests: $e');
    }
  }

  Future<DocumentSnapshot> fetchData(String collection, String userId) async {
    try {
      return await _firestore.collection(collection).doc(userId).get();
    } catch (e) {
      // Handle error
      print(e.toString());
      rethrow;
    }
  }

  Future<void> sendNotificationToUser(String userId, String title, String body) async {
    // Fetch the user's FCM token from Firestore
    DocumentSnapshot userDoc = await fetchData('UserInformation', userId);
    String? userToken = userDoc['fCMToken'];

    if (userToken == null) {
      print("User does not have an FCM token");
      return;
    }

    // Get the access token
    String accessToken = await getAccessToken();

    // Construct the notification payload for FCM HTTP v1 API
    final notificationPayload = {
      "message": {
        "token": userToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
        },
      }
    };

    // Send the POST request to FCM
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/shelterstocksdemo/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(notificationPayload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllUsersData() async {
    try {
      // Fetch all documents from the 'userinfo' collection
      QuerySnapshot snapshot = await _firestore.collection('UserInformation').get();

      // List to store user data
      List<Map<String, dynamic>> userDataList = [];

      // Loop through each document in the snapshot
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> userData = {
          'firstName': doc['firstName'] ?? '',
          'lastName': doc['lastName'] ?? '',
          'stockUnits': doc['stockUnits'] ?? 0,
          'stockValue': doc['stockValue'] ?? 0.0,
        };
        userDataList.add(userData);
      }

      return userDataList;
    } catch (e) {
      // Handle error
      print("Error fetching user' data: ${e.toString()}");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllShelterStocks() async {
    try {
      double totalStockUnits = 0.0;
      double totalStockValues = 0.0;
      // Fetch all documents from the 'userinfo' collection
      QuerySnapshot snapshot = await _firestore.collection('UserInformation').get();

      // Loop through each document in the snapshot
      for (DocumentSnapshot doc in snapshot.docs) {
        double stockUnits = doc['stockUnits'] is double ? doc['stockUnits'] : double.parse(doc['stockUnits']);
        double stockValues = doc['stockValue'] is double ? doc['stockValue'] : double.parse(doc['stockValue'].toString());

        // Update totals
        totalStockUnits += stockUnits;
        totalStockValues += stockValues;

      }
      List<Map<String, dynamic>> allShelterStocks = [{
        'Stock Units': totalStockUnits,
        'Stock Value': totalStockValues,
      }];

      return allShelterStocks;
    } catch (e) {
      // Handle error
      print("Error fetching user' data: ${e.toString()}");
      rethrow;
    }
  }




  // Update data in Firestore
  Future<void> updateData(String collection, String userID, Map<String, dynamic> data) async {
    try {
      final userDoc =  await _firestore.collection(collection).doc(userID).get();
      if(userDoc.exists){
        await userDoc.reference.update(data);
      }
      else{
        print('are you user document doesnt exist');
      }
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  Future<void> updateRequestsInAdmin(String adminDocId,String subCollection, String sellRequestId, Map<String, dynamic> data) async {
    try {
      final docRef = _firestore
          .collection('AdminInformation') // Parent collection
          .doc(adminDocId) // Document ID in AdminInformation
          .collection(subCollection) // Sub-collection (Sell Requests)
          .doc(sellRequestId); // Document ID in Sell Requests

      final userDoc = await docRef.get();
      if (userDoc.exists) {
        await docRef.update(data);
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  Future<void> updateNotificationField({
    required String userId,
    required String notificationId,
    required String fieldName,
    required dynamic newValue,
  }) async {
    try {
      // Get a reference to the Firestore instance

      // Reference to the specific notification document
      final DocumentReference notificationRef = _firestore
          .collection('UserInformation')
          .doc(userId)
          .collection('Notifications')
          .doc(notificationId);

      // Update the specified field
      await notificationRef.update({
        fieldName: newValue,
      });

      print('Updated $fieldName for notification $notificationId of user $userId');
    } catch (e) {
      print('Error updating notification: $e');
      // You might want to rethrow the error or handle it in a way that fits your app's error handling strategy
      rethrow;
    }
  }

  // Delete data from Firestore
  Future<void> deleteData(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  Future<void> deleteFromSubCollection(String userId, String subCollection, String documentId) async {
    print('Deleting document $documentId from $subCollection for user $userId');
    try {
      await FirebaseFirestore.instance
          .collection('UserInformation')
          .doc(userId)
          .collection(subCollection)
          .doc(documentId)
          .delete();
      print('Document deleted successfully');
    } catch (e) {
      print('Error in deleteFromSubCollection: $e');
      throw e; // Rethrow the error so it can be caught in the calling function
    }
  }

  // Update password
  Future<void> updatePassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    }on FirebaseAuthException catch (e) {
      print('unable to send email, reason: ${e.toString()}');
    }
  }

  Future<String> reauthenticateUser(String email, String password) async {
    // Get the currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null){
      try{
        UserCredential result = (await signInWithEmailPassword(email, password)) as UserCredential;
        if (result.user == null) {
          print('Incorrect password');
          return 'Incorrect Password';
        } else {
          print('User signed in successfully.');
          return 'User signed in successfully.';
        }
      } catch (e) {
        print('Error during sign in: $e');
        return 'Error during sign in: $e';
      }
    } else {
      // Create an AuthCredential using the provided email and password
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      try {
        // Reauthenticate the user
        await user.reauthenticateWithCredential(credential);
        // Success: Reauthentication completed
        print('Reauthentication successful!');
        return 'Reauthentication successful!';
      } on FirebaseAuthException catch (e) {
        // Handle errors such as invalid credentials or reauthentication failure
        print('Error during reauthentication: ${e.message}');
        return 'Error during reauthentication: ${e.message}';
      } catch (e) {
        // Handle any other errors
        print('Unknown error: $e');
        return 'Unknown error: $e';
      }
    }
  }


  Future<Map<String, dynamic>> verifyBeforeUpdateEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.verifyBeforeUpdateEmail(newEmail);
        print("Verification email sent to $newEmail");
        return {'status': true, 'message': 'Verification email sent successfully'};
      } on FirebaseAuthException catch (e) {
        // Handle errors, such as invalid email or requires recent login
        print("Error: ${e.message}");
        return {'status': false, 'message': e.message};
      }
    } else {
      print("No user is signed in.");
      return {'status': false, 'message': 'No user is signed in'};
    }
  }

  // Add stock purchases to Firestore
  Future<Map<String, dynamic>> addStockPurchases(String userId, List<Map<String, dynamic>> stockPurchases) async {
    try {
      // Reference to the user's document
      DocumentReference userDocRef = _firestore.collection('UserInformation').doc(userId);

      // Update the stockPurchases array field
      await userDocRef.update({
        'stockPurchases': FieldValue.arrayUnion(stockPurchases),
      });
      print('stock purchase added successfully');
      return {'status': true, 'message': 'Stock purchase added successfully'};
    } catch (e) {
      print('Error adding stock purchases: $e');
      return {'status': false, 'message': 'Unable to add stock purchase'};
    }
  }
}

