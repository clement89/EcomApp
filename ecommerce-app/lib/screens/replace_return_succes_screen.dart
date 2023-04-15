import 'package:Nesto/screens/order_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:Nesto/strings.dart' as strings;
class ReturnReplaceScreen extends StatefulWidget {
  static const String routeName = "/replace_return_success_screen";
  final int screencheck;

  const ReturnReplaceScreen({Key key, this.screencheck}) : super(key: key);

  @override
  _ReturnReplaceScreenState createState() => _ReturnReplaceScreenState();
}

class _ReturnReplaceScreenState extends State<ReturnReplaceScreen>
    with TickerProviderStateMixin {
  AnimationController _controller;
  String title = "";
  String subtitle = "";

  updateText() {
    if (widget.screencheck == 1) {
      title = strings.ORDER_EDITED;
      subtitle =
          strings.ORDER_EDITED_SUCCESS_DESCRIPTION;
    } else if (widget.screencheck == 2) {
      title = strings.RETURN_CONFIRMED;
      subtitle =
          strings.ORDER_RETURNED_SUCCESS_DESCRIPTION;
    } else if (widget.screencheck == 3) {
      title = strings.REPLACEMENT_CONFIRMED;
      subtitle =
          strings.ORDER_REPLACEMENT_SUCCESS_DESCRIPTION;
    } else if (widget.screencheck == 4) {
      title = strings.ORDER_CANCELLED;
      subtitle =
          strings.ORDER_CANCELLED_SUCCESS_DESCRPTION;
    }
  }

  Future<bool> _backpressed() {
    //Provider.of<OrderProvider>(context,listen: false).modifysuccesscreenvalues();
    Navigator.pushNamed(context, OrderScreen.routeName);
    // Navigator.of(context)
    //     .pushReplacementNamed(BaseScreen.routeName, arguments: {"index": 0});
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Replace Return Success Screen");
    super.initState();
    updateText();
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    logNesto('wc' + widget.screencheck.toString());
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return WillPopScope(
      onWillPop: _backpressed,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: true,
          // leading: GestureDetector(
          //   onTap: () {
          //     _backpressed();
          //     // Navigator.of(context).pop();
          //   },
          //   child: Container(
          //     padding: EdgeInsets.all(10),
          //     child: Container(
          //         height: ScreenUtil().setHeight(8),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           border: Border.all(
          //             width: 1,
          //           ),
          //           borderRadius: BorderRadius.all(
          //             Radius.circular(10),
          //           ),
          //         ),
          //         child: Row(
          //           children: [
          //             SizedBox(
          //               width: 5,
          //             ),
          //             Expanded(
          //               child: Icon(
          //                 Icons.arrow_back_ios,
          //                 color: Colors.black,
          //                 size: 15,
          //               ),
          //             ),
          //           ],
          //         )),
          //   ),
          // ),
          title: Text(
            title,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 1),
          ),
          elevation: 0,
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Text("Payment Success",style: TextStyle(color: Colors.black87,fontSize: 17,fontWeight: FontWeight.w700),),
                SizedBox(
                  height: ScreenUtil().setHeight(24),
                ),
                /*Image.asset(
                  "assets/images/checked.webp",
                ),*/
                Lottie.asset(
                  'assets/animations/payment_confirm.json',
                  repeat: false,
                  animate: true,
                  height: ScreenUtil().setWidth(220),
                  width: ScreenUtil().setWidth(220),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(64),
                ),
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 28),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(24),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black26,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(132),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: ScreenUtil().setWidth(380),
                    height: ScreenUtil().setHeight(70),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        Navigator.pushNamed(context, OrderScreen.routeName);
                        // Navigator.of(context).pushReplacementNamed(
                        //     BaseScreen.routeName,
                        //     arguments: {"index": 0});
                      },
                      color: values.NESTO_GREEN,
                      child: Center(
                        child: Text(
                          strings.DONE,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
