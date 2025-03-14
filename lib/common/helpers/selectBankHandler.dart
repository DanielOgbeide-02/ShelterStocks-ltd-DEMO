
String getInitials(String accountName) {
  if (accountName.isEmpty) {
    return '';
  }
  print('account name: ${accountName}');

  List<String> names = accountName.split(' ').where((name) => name.isNotEmpty).toList();
  String initials = '';

  for (int i = 0; i < 2 && i < names.length; i++) {
    if (names[i].isNotEmpty) {
      initials += names[i][0].toUpperCase();
    }
  }

  return initials;
}

String? amountValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an amount';
  }

  // Parse the input value to double
  double? amount;
  try {
    amount = double.parse(value);
  } catch (e) {
    return 'Invalid amount';
  }

  // Check if the amount is within the specified range
  if (amount < 5000 || amount > 300000) {
    return 'Amount must be between ₦5000 and ₦300,000';
  }

  // Return null if validation succeeds
  return null;
}