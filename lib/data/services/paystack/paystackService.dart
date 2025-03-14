
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../common/helpers/constants/api_keys.dart';

class PaystackService {
  static const String _baseUrl = "https://api.paystack.co";

  Future<String?> createTransferRecipient({
    required String bankNumber,
    required String bankCode,
    required String accountName,
  }) async {
    final url = Uri.https('api.paystack.co', '/transferrecipient');
    final headers = {
      'Authorization': 'Bearer ${ApiKeys.payStackLiveKey}',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'type': 'nuban',
      'name': accountName,
      'account_number': bankNumber,
      'bank_code': bankCode,
      'currency': 'NGN',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Create recipient response: ${response.body}');
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['recipient_code'];
      } else {
        print('Error creating transfer recipient: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in createTransferRecipient: $e');
      return null;
    }
  }

  Future<String?> initiateTransfer({
    required double amount,
    required String recipientCode,
    required String reference,
    String? selectedBankName,
    String? selectedAccountName,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/transfer');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${ApiKeys.payStackLiveKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "source": "balance",
          "amount": 100 * amount,
          "reference": reference,
          "recipient": recipientCode,
          "reason": "Wallet Withdrawal"
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final transferCode = responseBody['data']['transfer_code'];
        print(selectedBankName);
        return transferCode;
      } else {
        print('Error initiating transfer: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } on FormatException catch (e) {
      print('Error decoding JSON: $e');
      return null;
    } catch (error) {
      print('Error initiating transfer: $error');
      return null;
    }
  }
}