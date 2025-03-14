

//new tran history
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/presentation/provider/user/userData.dart';
import '../../../../../common/helpers/functions/getScale.dart';
import '../../../../../common/widgets/buttons/goBackBtn.dart';
import '../../../../../domain/models/transactions/transaction.dart';
import '../../../../provider/transactions/transactionData.dart';


class TransactionHistoryScreen extends StatefulWidget {
  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final _userData = Provider.of<UserData>(context,listen: false);
    final _transactionData = Provider.of<transactionData>(context, listen: false);
    _transactionData.loadTransactions(_userData.currentUser!.userId!);
  }

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
  );

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    return Consumer<transactionData>(
      builder: (context, transactionData, child) {
        final groupedTransactions = transactionData.groupTransactionsByMonth();
        final monthlyTotals = transactionData.calculateMonthlyTotals();
        final transactionsCount = transactionData.transactionCount;
        final reversedMonths = groupedTransactions.entries.toList().reversed.toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: transactionsCount >= 1
              ?
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  itemCount: reversedMonths.length,
                  itemBuilder: (context, index) {
                    final monthEntry = reversedMonths[index];
                    final monthKey = monthEntry.key;
                    final transactionsForMonth = groupedTransactions[monthKey]!;
                    return _buildMonthSection(context, monthKey, transactionsForMonth, monthlyTotals[monthKey]!);
                  },
                ),
              ),
            ],
          )
              : _buildEmptyState(context),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: isTablet?20*getScale(context):(isSmallPhone?25.0*getScale(context) :(50.0 * getScale(context))), left: 20 * getScale(context), right: 20 * getScale(context)),
      child: Row(
        children: [
          goBackBtn(size: 25),
          SizedBox(width: isTablet?100*getScale(context):(40 * getScale(context))),
          Text(
            'Transaction History',
            style: TextStyle(
              color: Colors.black,
              fontSize: isTablet?15*getScale(context):(24 * getScale(context)),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(BuildContext context, String monthKey, List<Transactions> transactions, Map<String, double> totals) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    return ExpansionTile(
      initiallyExpanded: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(monthKey, style: TextStyle(fontSize: isTablet?12*getScale(context):(16 * getScale(context)), fontFamily: 'Roboto',
            fontWeight: FontWeight.w900,)),
          Row(
            children: [
              _buildTotalRow('In: ', totals['incoming'] ?? 0, context),
              SizedBox(width: 10),
              _buildTotalRow('Out: ', totals['outgoing'] ?? 0, context),
            ],
          ),
        ],
      ),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) => _buildTransactionItem(context, transactions[index]),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: isTablet?12*getScale(context):(15 * getScale(context)), color: Colors.grey, fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,)),
        Text(currencyFormatter.format(amount), style: TextStyle(fontSize: isTablet?12*getScale(context):(15 * getScale(context)), fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,)),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transactions transaction) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<800;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1.0,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          transaction.transactionType == "Buy" ? Icons.arrow_upward : Icons.arrow_downward,
          color: transaction.transactionType == "Buy" ? Colors.green : Colors.red,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction.transactionType!}', style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),),
            Text('${transaction.transactionDate}', style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              color: Colors.grey
            ),),
          ],
        ),
        subtitle: Text('Units: ${transaction.stockUnits}', style: TextStyle(color: Colors.black, fontSize: isTablet?10 * getScale(context):12 * getScale(context), fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Amount: ${currencyFormatter.format(transaction.transactionAmount)}', style: TextStyle(color: Colors.black,fontSize: isTablet?8 * getScale(context):12 * getScale(context), fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,), ),
            SizedBox(
              width:  isTablet?75 * getScale(context):100 * getScale(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: Text(transaction.transactionTime, style: TextStyle(color: Colors.grey, fontSize: isTablet?8 * getScale(context):11 * getScale(context)))),
                  Expanded(child: Text('${transaction.transactionStatus}', style: TextStyle(color: Colors.green, fontSize: isTablet?8 * getScale(context):12 * getScale(context)))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 40, left: 20),
            alignment: Alignment.topLeft,
            child: goBackBtn(),
          ),
        ),
        Expanded(child: Text('You don\'t have any transactions', style: TextStyle(color: Colors.red))),
      ],
    );
  }
}
