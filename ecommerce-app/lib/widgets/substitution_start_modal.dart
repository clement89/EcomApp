import 'dart:developer';
import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/strings.dart';
import 'package:Nesto/providers/substitution_provider.dart';
import 'package:Nesto/screens/substitution_order_screen.dart';
import 'package:Nesto/service_locator.dart';
import 'package:Nesto/services/navigation_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/product_list_container_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';

void showSubstitutionStartModal({orderID}) {
  final NavigationService _navigation = locator.get<NavigationService>();

  String formatTime(double time) {
    Duration duration = Duration(seconds: time.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future.delayed(Duration.zero, () {
    return showModalBottomSheet(
        context: _navigation.navigatorKey.currentContext,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (context) {
          bool isLoading = false;
          return StatefulBuilder(builder: (context, setState) {
            startLoading() => setState(() => isLoading = true);
            stopLoading() => setState(() => isLoading = false);
            var provider =
                Provider.of<SubstitutionProvider>(context, listen: false);

            Future _removeOutOfStock() async {
              try {
                startLoading();
                await provider.removeOutOfStock();
                stopLoading();
                log("navigate to substitution screen");
                Navigator.popAndPushNamed(
                    context, SubstitutionOrderScreen.routeName);
              } catch (e) {
                log("ERR: $e", name: "start_modal");
                stopLoading();
                Navigator.of(context).maybePop();
                showError(context,
                    e?.message ?? SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
              }
            }

            return Container(
              height: ScreenUtil().setWidth(409),
              width: double.infinity,
              color: Colors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(26)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height:
                        ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(127),
                    height: ScreenUtil().setWidth(3),
                    color: Color(0xFFC4C4C4),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(28),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(86),
                    height: ScreenUtil().setWidth(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black87),
                    ),
                    child: Center(
                      child: Countdown(
                        seconds: provider.cuttOff,
                        build: (BuildContext context, double time) => Text(
                          formatTime(time),
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        interval: Duration(seconds: 1),
                        onFinished: () {
                          Navigator.maybePop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height:
                        ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
                  ),
                  Text(
                    strings.SUBSTITUTION_REQUIRED,
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 24),
                  ),
                  SizedBox(
                    height:
                        ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
                  ),
                  Text(
                    strings.SUBSTITUTION_DESC,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(28),
                  ),
                  Expanded(
                    flex: 3,
                    child: ProductListContainer(
                        ORDER_ON_HOLD,
                        provider?.substituteOrder?.orderCreatedAt ?? '--',
                        provider?.substituteOrder?.salesIncrementalId,
                        provider?.substituteOrder?.itemCount.toString(),
                        provider?.substituteOrder?.paymentAmount?.twoDecimal(),
                        'assets/svg/place_holder_7_arun.svg',
                        Colors.transparent),
                  ),
                  //Expanded(child: SizedBox()),
                  SizedBox(
                    height: ScreenUtil().setWidth(40),
                    width: ScreenUtil().setWidth(160),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: values.NESTO_GREEN,
                      onPressed: _removeOutOfStock,
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                height: ScreenUtil().setWidth(17),
                                width: ScreenUtil().setWidth(17),
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: ScreenUtil().setWidth(3),
                                ),
                              )
                            : Text(
                                strings.RESOLVE,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(30),
                  )
                ],
              ),
            );
          });
        });
  });
}
