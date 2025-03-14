class User{
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? fCMToken;
  double? stockUnits;
  double? stockValue;
  final String? userId;
  User({this.firstName,this.lastName, this.email, this.password,this.userId,this.stockUnits,this.fCMToken,
    this.stockValue}){}

  void buyStocks(int newStocks){
    stockUnits = (stockUnits??0) + newStocks;
    stockValue = stockUnits! * 1000;
  }

  void sellStocks(int soldStocks){
    if (stockUnits! >= soldStocks) {
      stockUnits = (stockUnits??0) - soldStocks;
      stockValue = stockUnits! * 1000;
    } else {
      // Show an error message or set the stockUnits to 0
      print('Not enough stocks to sell');
      // or
      stockUnits = 0;
      stockValue = 0;
    }
  }
}