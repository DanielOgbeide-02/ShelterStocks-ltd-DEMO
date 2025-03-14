import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shelterstocks_prototype2/domain/models/sell_requests/sellRequest.dart';

import '../../../common/helpers/constants/api_keys.dart';
import '../../../common/helpers/constants/base_urls.dart';
import '../../../data/sources/firebase_operations/firebase_service.dart';
import '../../../data/services/paystack/paystackService.dart';

class Sellrequestdata extends ChangeNotifier{
  final FirebaseService _firebaseService = FirebaseService(); // Reference to FirebaseService
  List<SellRequest> _sellRequest = [];


  int get sellRequestCount => _sellRequest.length;

  List<SellRequest> get sellRequests {
    return List<SellRequest>.from(_sellRequest);
  }

  Future<Map<String, dynamic>> addSellRequest(String userId,String firstName,String lastName,double stockUnits, double stockValue, bool qualified, DateTime sellRequestDateTime) async {
    try {
      final newSellRequest = SellRequest(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        stockUnits: stockUnits,
        stockValue: stockValue,
        qualified: qualified,
        sellRequestDateTime: sellRequestDateTime,
        soldStatus: false,
      );

      // Add request to local list
      _sellRequest.insert(0, newSellRequest);
      notifyListeners();

      // Add request to Firebase (replace hardcoded ID with dynamic)
      await _firebaseService.addSellRequest('M6W8NgJghbfKkoV1LxByyDwwVGD2', {
        'user ID': userId,
        'first Name': firstName,
        'last Name':lastName,
        'stock Units': stockUnits,
        'stock Value': stockValue,
        'qualified': qualified,
        'Sell Request Date': sellRequestDateTime,
        'sold Status': false,
      });

      // Return success result
      return {'success': true, 'message': 'Sell request added successfully.'};
    } catch (e) {
      // Return error result
      return {'success': false, 'message': 'Failed to add sell request: $e'};
    }
  }



  Future<bool> fetchUnapprovedSellRequest(String adminId) async {
    try {
      // Clear the current list before fetching new data
      _sellRequest.clear();
      List<Map<String, dynamic>> sellRequestList = await _firebaseService.fetchSellRequest(adminId);

      // Filter out unapproved requests
      List<SellRequest> unapprovedRequests = sellRequestList
          .where((data) => data['sold Status'] == false)  // Filter unapproved requests
          .map((data) => SellRequest(
        requestId: data['docId'],  // Store the document ID in SellRequest
        userId: data['user ID'],
        firstName: data['first Name'],
        lastName: data['last Name'],
        stockUnits: data['stock Units'],
        stockValue: data['stock Value'],
        qualified: data['qualified'],
        sellRequestDateTime: (data['Sell Request Date'] as Timestamp).toDate(),
        soldStatus: data['sold Status'],
      ))
          .toList();

      for(var request in unapprovedRequests){
        print('each user request: ${request.requestId}');
      }

      if (unapprovedRequests.isNotEmpty) {
        // Sort unapproved requests by date in descending order
        unapprovedRequests.sort((a, b) => b.sellRequestDateTime.compareTo(a.sellRequestDateTime));

        _sellRequest = unapprovedRequests;
        notifyListeners();

        print('Unapproved sell requests fetched successfully.');
        print('count of requests: ${_sellRequest.length}');
        return true;
      } else {
        print('No unapproved sell requests found.');
        return false;
      }
    } catch (e) {
      print('Error fetching sell requests: $e');
      return false;
    }
  }


  Future<Map<String, String>> approveRequest(SellRequest sellRequest, String userId) async {
    try{
      // Check if the request is already approved
      if (sellRequest.qualified!) {
        //make payment
        final result = await MakePayment(sellRequest, userId);
        if(result['status'] == 'success'){
          //update user database
          final updateUserResult =  await updateUserStockDetails(sellRequest, userId);
          if(updateUserResult['status']== 'success'){
            if (sellRequest.soldStatus == null || sellRequest.soldStatus == false) {
              sellRequest.soldStatus = true;
            }
            // Remove from list after approval
            _sellRequest.removeWhere((request) => request.requestId == sellRequest.requestId);
            notifyListeners();
            // Update Firebase
            print('start of error:');
            print('userID: ${sellRequest.requestId!}');
            await _firebaseService.updateRequestsInAdmin(
                'M6W8NgJghbfKkoV1LxByyDwwVGD2',
                'Sell Requests',
                sellRequest.requestId!,// Assuming 'sellRequests' is the collection name
                //manually for now
                {
                  'user ID': sellRequest.userId,
                  'first Name':sellRequest.firstName,
                  'last Name':sellRequest.lastName,
                  'stock Units': sellRequest.stockUnits,
                  'stock Value': sellRequest.stockValue,
                  'qualified': sellRequest.qualified,  // Update status to approved
                  'Sell Request Date': sellRequest.sellRequestDateTime,
                  'sold Status': true
                }
            );
            print('end of error:');

            print('Request already approved');

          }
          else{
            print('unable to approve request');
          }

        }
        else{
          print('Unable to make payment');
        }
      }
      else{
        print('user does not qualify');
      }
      return {'status': 'success', 'message': 'Request approved successfully'};
    }
    catch(e){
      print('Could not approve request: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  //Update Users stock units and value in the firebase
  Future<Map<String, String>> updateUserStockDetails(SellRequest sellRequest,String userId) async{
    try{
      DocumentSnapshot currentUserDoc = await FirebaseService().fetchData('UserInformation', sellRequest.userId!);
      if (currentUserDoc.exists){
        double currentUserStockUnits = currentUserDoc['stockUnits'];
        double currentUserStockValue = currentUserDoc['stockValue'];
        double updatedStockUnits = currentUserStockUnits-sellRequest.stockUnits!;
        double updatedStockValue = currentUserStockValue-sellRequest.stockValue!;
        await FirebaseService().updateData('UserInformation', sellRequest.userId!,
            {
              'stockUnits':updatedStockUnits,//remember to update
              'stockValue':updatedStockValue,
            });
      }
      else{
        print('i exist or not: ${sellRequest.userId!}');
        print('me: User document does not exist');
      }

      return {'status': 'success', 'message': 'stock details updated successfully'};
    }
    catch(e){
      print('Could not update user stock details: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

// make payment: use this when business registered
//   Future<Map<String, String>> MakePayment(SellRequest sellRequest, String userId) async {
//     String bankName = "";
//     String accountName = "";
//     String accountNumber = "";
//
//     // Fetch the user's account information from the database
//     DocumentSnapshot currentUserDoc = await FirebaseService().fetchData('UserInformation', sellRequest.userId!);
//     if (currentUserDoc.exists) {
//       accountNumber = currentUserDoc['Account Number'];
//       accountName = currentUserDoc['Bank account name'];
//       bankName = currentUserDoc['Bank']; // Assuming you have the bank name stored in the database
//
//       // Verify the account number
//       String? bankCode = await _getBankCode(bankName);
//       print('gotten bank code: $bankCode');
//       print('gotten bank : $bankName');
//       print('gotten account name: $accountName');
//       print('gotten account number: $accountNumber');
//
//       Map<String, dynamic>? accountData = await _verifyAccountNumber(accountNumber, bankCode!);
//       if (accountData != null) {
//         print("Account verified: $accountData");
//
//         Future<void> _initiatePaystackTransfer(double amount, String bankCode ,String accountNumber, String accountName) async {
//           try {
//             if (accountName.isEmpty || accountNumber.isEmpty || bankCode.isEmpty) {
//               print("Error: Account name, number, or bank code is empty");
//               return;
//             }
//
//
//             // Create a recipient and get the recipient code
//             final recipientCode = await PaystackService().createTransferRecipient(
//               bankNumber: accountNumber,
//               bankCode: bankCode,
//               accountName: accountName,
//             );
//
//             print('my receipient code? $recipientCode');
//
//             String _generateUniqueReference() {
//               var epochTime = DateTime.now().millisecondsSinceEpoch;
//               var random = Random().nextInt(10000);
//               var combinedString = 'TXN_$epochTime-$random';
//               var bytes = utf8.encode(combinedString);
//               var md5Hash = md5.convert(bytes); // Use MD5 hash function
//               var hashedReference = md5Hash.toString();
//               return "TXN-${hashedReference}";
//             }
//
//             if (recipientCode != null) {
//               // Proceed to initiate the transfer using the recipient code
//               final reference = _generateUniqueReference();
//
//               try {
//                 final transferCode = await PaystackService().initiateTransfer(
//                   amount: amount,
//                   recipientCode: recipientCode,
//                   reference: reference,
//                   selectedBankName: bankName,
//                   selectedAccountName: accountName,
//                 );
//
//                 print(transferCode);
//
//                 if (transferCode != null) {
//                   print('Paystack transfer initiated successfully. Transfer Code: $transferCode');
//                 } else {
//                   print('Withdrawal transaction saved Failed.');
//                 }
//               } catch (error) {
//                 print("Error: $error");
//               }
//             } else {
//               print('Error: Recipient code is null');
//             }
//           } catch (error) {
//             print('Error initiating bank transfer: $error');
//           }
//         }
//
//         // Proceed with the payment logic
//         await _initiatePaystackTransfer(sellRequest.stockValue!, bankCode, accountNumber, accountName);
//
//         return {'status': 'success', 'message': 'Payment successful'};
//       } else {
//         print("Account verification failed.");
//         return {'status': 'error', 'message': 'Account verification failed'};
//       }
//     } else {
//       print("User document does not exist.");
//       return {'status': 'error', 'message': 'User document does not exist'};
//     }
//   }


  // make payment: use this before business registered
  // doesn't make payment
  Future<Map<String, String>> MakePayment(SellRequest sellRequest, String userId) async {
    String bankName = "";
    String accountName = "";
    String accountNumber = "";

    // Fetch the user's account information from the database
    DocumentSnapshot currentUserDoc = await FirebaseService().fetchData('UserInformation', sellRequest.userId!);
    if (currentUserDoc.exists) {
      accountNumber = currentUserDoc['Account Number'];
      accountName = currentUserDoc['Bank account name'];
      bankName = currentUserDoc['Bank']; // Assuming you have the bank name stored in the database

      // Verify the account number
      String? bankCode = await _getBankCode(bankName);
      print('Gotten bank code: $bankCode');
      print('Gotten bank : $bankName');
      print('Gotten account name: $accountName');
      print('Gotten account number: $accountNumber');

      Map<String, dynamic>? accountData = await _verifyAccountNumber(accountNumber, bankCode!);
      if (accountData != null) {
        print("Account verified: $accountData");

        // Simulating the creation of a recipient and checking if it's not null
        final recipientCode = await PaystackService().createTransferRecipient(
          bankNumber: accountNumber,
          bankCode: bankCode,
          accountName: accountName,
        );

        if (recipientCode != null) {
          print('Recipient code received: $recipientCode');
          print('transaction successful');
          // Transaction is successful since recipient code is not null
          return {'status': 'success', 'message': 'Payment successful'};
        } else {
          print('Error: Recipient code is null');
          return {'status': 'error', 'message': 'Recipient code is null'};
        }
      } else {
        print("Account verification failed.");
        return {'status': 'error', 'message': 'Account verification failed'};
      }
    } else {
      print("me 2: User document does not exist.");
      return {'status': 'error', 'message': 'User document does not exist'};
    }
  }



  Future<String?> _getBankCode(String bankName) async {
    final url = Uri.https('api.paystack.co', '/bank');
    final headers = {
      'Authorization': 'Bearer ${ApiKeys.payStackLiveKey}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> bankList = data['data'] as List;

        for (final bank in bankList) {
          if (bank['name'].toString().toLowerCase() == bankName.toLowerCase()) {
            return bank['code'].toString();
          }
        }
        print('No matching bank found for: $bankName');
        return null;
      } else {
        print('Failed to fetch bank codes: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching bank codes: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _verifyAccountNumber(String accountNumber, String bankCode) async {
    if (accountNumber.isEmpty || bankCode.isEmpty) {
      print('Account number or bank code is empty');
      return null;
    }

    final url = Uri.https('api.paystack.co', '/bank/resolve', {
      'account_number': accountNumber,
      'bank_code': bankCode
    });
    final headers = {
      'Authorization': 'Bearer ${ApiKeys.payStackLiveKey}',
    };
    print("Verifying account number: $accountNumber");
    print("Bank code: $bankCode");

    try {
      final response = await http.get(url, headers: headers);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to resolve bank account: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error resolving bank account: $error');
      return null;
    }
  }

  Future<void> printAllBanks() async {
    final url = Uri.https('api.paystack.co', '/bank');
    final headers = {
      'Authorization': 'Bearer ${ApiKeys.payStackLiveKey}',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> bankList = data['data'] as List;

        for (final bank in bankList) {
          print('Bank Name: ${bank['name']}, Code: ${bank['code']}');
        }
      } else {
        print('Failed to fetch banks: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching banks: $error');
    }
  }



}

