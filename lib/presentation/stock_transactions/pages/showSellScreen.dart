import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shelterstocks_prototype2/common/helpers/functions/getScale.dart';
import 'package:shelterstocks_prototype2/common/widgets/buttons/buttons.dart';
import 'package:shelterstocks_prototype2/common/widgets/input_field/inputfields.dart';
import 'package:shelterstocks_prototype2/presentation/provider/user/userData.dart';
import 'package:shelterstocks_prototype2/presentation/provider/sell_requests/sellRequestData.dart';

import '../../../common/widgets/flush_bar/Flushbar.dart';

class Showsellscreen extends StatefulWidget {
  static String id = 'showSellscreen';
  const Showsellscreen({super.key});

  @override
  State<Showsellscreen> createState() => _ShowsellscreenState();
}

class _ShowsellscreenState extends State<Showsellscreen> {
  TextEditingController stockAmountController = TextEditingController();
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
  );
  double? price = 0.0;

  bool isPressed = false;
  bool _loading = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stockAmountController.addListener(_updatePrice);
  }

  void _updatePrice() {
    setState(() {
      final stockAmount = double.tryParse(stockAmountController.text.trim());
      if (stockAmount != null && stockAmount > 0) {
        price = stockAmount * 1000; // Adjust the price calculation as needed
      } else {
        price = 0; // Display 0 if the input is empty or invalid
      }
    });
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    stockAmountController.removeListener(_updatePrice);
    stockAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    // Check if the device is a tablet (adjust threshold as needed)
    bool isTablet = screenWidth > 600;
    bool isSmallPhone = screenWidth < 413 && screenHeight<733;
    return Container(
      padding: EdgeInsets.only(top: 10*getScale(context)),
      height: isTablet?350*getScale(context):(500*getScale(context)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(50*getScale(context)), topLeft: Radius.circular(50*getScale(context)))
      ),
      child:
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 30.0*getScale(context), right: 30.0*getScale(context), bottom: 30.0*getScale(context), top: 5*getScale(context)),
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  height: 8*getScale(context),
                  width: 50*getScale(context),
                  decoration: BoxDecoration(
                      color: Color(0xFF1A1AFF),
                      borderRadius: BorderRadius.circular(5)
                  ),
                ),
                SizedBox(
                  height: 25*getScale(context),
                ),
                Row(
                  children: [
                    Text('Sell your ShelterStocks'),
                    SizedBox(width: 2*getScale(context),),
                    Icon(
                      Icons.swap_horiz_outlined,
                      color: Color(0xFF1A1AFF),
                    )
                  ],
                ),
                SizedBox(
                  height: 10*getScale(context),
                ),
                Consumer<UserData>(
                  builder: (context, userProvider, child) =>
                      Row(
                        children: [
                          Expanded(
                              child:
                              Container(
                                padding: EdgeInsets.all(5),
                                height: isTablet?40*getScale(context):(50*getScale(context)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade300,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ShelterStock Units: '),
                                    Text('${userProvider.currentUser?.stockUnits}', style: TextStyle(
                                        color: Color(0xFF1A1AFF),
                                        fontSize: 12*getScale(context)
                                    )),
                                  ],
                                ),
                              )
                          ),
                          SizedBox(
                            width: 10*getScale(context),
                          ),
                          Expanded(
                              child:
                              Container(
                                padding: EdgeInsets.all(5),
                                height: isTablet?40*getScale(context):(50*getScale(context)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade300,
                                ),
                                child: Column
                                  (
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text('ShelterStock Value: '),
                                    Text('${currencyFormatter.format(userProvider.currentUser?.stockValue)}', style: TextStyle(
                                        color: Color(0xFF1A1AFF),
                                        fontSize: 12*getScale(context)
                                    )),
                                  ],
                                ),
                              )
                          )
                        ],
                      ),
                ),
                SizedBox(
                  height: 20*getScale(context),
                ),
                Text('Please note that you are selling your ShelterStocks at a rate of ₦1,000.00 per unit.', style: TextStyle(
                    color: Colors.grey
                ),),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20*getScale(context),
                    ),
                    Text('Number of ShelterStocks'),
                    InputField(obscureText: false, hintText: 'e.g 10',controller_: stockAmountController,),
                    SizedBox(
                      height: 10*getScale(context),
                    ),
                    Text(
                      'Price:',
                      style: TextStyle(
                          fontSize: isTablet?8*getScale(context):13.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      height: 5*getScale(context),
                    ),
                    Text('${currencyFormatter.format(price)}'),
                    SizedBox(
                      height: 30*getScale(context),
                    ),

                    Consumer<UserData>(
                      builder: (context, userData, child)
                      => Buttons(isLoading: _loading,width: double.infinity,buttonText: 'Sell', buttonTextColor: Colors.white,buttonColor: Color(0xFF1A1AFF),isPressed: isPressed,onPressed: ()async{
                        setState(() {
                          isPressed = true;
                          _loading = true;
                        });
                        final sellRequestProvider = Provider.of<Sellrequestdata>(context, listen: false);
                        if(stockAmountController.text.trim().isNotEmpty){
                          if(double.tryParse(stockAmountController.text.trim()) == null){
                            setState(() {
                              isPressed = false;
                              _loading = false;
                            });
                            showTopSnackBar(
                              context: context,
                              title: 'Error:',
                              message: 'Please enter a valid amount.',
                            );
                          }
                          else{
                            if(userData.currentUser!.stockUnits! >= double.parse(stockAmountController.text.trim())){
                              if(double.parse(stockAmountController.text.trim())>=5.0){
                                var result = await sellRequestProvider.addSellRequest(userData.currentUser!.userId!,userData.currentUser!.firstName!, userData.currentUser!.lastName! ,double.parse(stockAmountController.text.trim()), price!, true, DateTime.now());
                                if(result['success']){
                                  setState(() {
                                    isPressed = false;
                                    _loading = false;
                                  });
                                  showDialog(context: context, builder: (context){
                                    return AlertDialog(
                                      title:
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Success:',
                                            style: TextStyle(
                                              // fontSize: 30,
                                                color: Colors.black
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Text(
                                            "Your request has been submitted successfully. Our team will review your submission and complete the necessary steps to process your sale. You will receive an update on the status of your transaction within 1 business day.",
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 18
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            onPressed: (){
                                              setState(() {
                                                isPressed = false;
                                              });
                                              Navigator.pop(context);
                                            }, child: Text('OK')
                                        ),
                                      ],
                                    );
                                  });
                                }
                                else{
                                  setState(() {
                                    isPressed = false;
                                    _loading = false;
                                  });
                                  showTopSnackBar(
                                    context: context,
                                    title: 'Error:',
                                    message: 'Unable to complete sell process, please try again later.',
                                  );
                                }
                              }
                              else{
                                setState(() {
                                  isPressed = false;
                                  _loading = false;
                                });
                                showTopSnackBar(
                                  context: context,
                                  title: 'Declined:',
                                  message: 'You can only sell a minimum of ${currencyFormatter.format(5*1000)}',
                                );
                              }
                            }
                            else{
                              setState(() {
                                isPressed = false;
                                _loading = false;
                              });
                              showTopSnackBar(
                                context: context,
                                title: 'Declined:',
                                message: 'You don\'t have enough stock units to continue this process.',
                              );
                            }
                          }
                        }
                        else{
                          setState(() {
                            isPressed = false;
                            _loading = false;
                          });
                          showTopSnackBar(
                            context: context,
                            title: 'Error:',
                            message: 'Please enter an amount.',
                          );
                        }
                      },),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),

    );
  }
}
