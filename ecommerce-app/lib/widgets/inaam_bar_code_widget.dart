import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/utils/util.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/extensions/number_extension.dart';

class InaamBarCodeWidget extends StatefulWidget {
  final Function onTap;
  InaamBarCodeWidget({this.onTap});

  @override
  _InaamBarCodeWidgetState createState() => _InaamBarCodeWidgetState();
}

class _InaamBarCodeWidgetState extends State<InaamBarCodeWidget> {
  bool showBarCode = false;
  double inaamInAed = 0;
  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context, listen: true);
    if ((authProvider.inaamCode != null) &&
        (authProvider.inaamPointsLifeTime != null)) {
      setState(() {
        showBarCode = true;
        inaamInAed = getInaamInAed(authProvider.inaamPoints);
      });
    } else {
      setState(() {
        showBarCode = false;
      });
    }
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    authProvider.showInaamRetryButton
                        ? strings.INAAM_POINTS
                        : (authProvider.inaamPoints.twoDecimal() +
                            strings.INAAM_POINTS),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  !authProvider.getShowInaamRetryLoading &&
                          !authProvider.showInaamRetryButton
                      ? Text(
                          strings.AED + ' ' + inaamInAed.twoDecimal(),
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : (!authProvider.showInaamRetryButton &&
                              authProvider.getShowInaamRetryLoading
                          ? Center(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: RawMaterialButton(
                                  onPressed: onPressRetryInaamCallOnly,
                                  elevation: 0.0,
                                  fillColor: Color(0xffFAFAFA),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.2),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            values.NESTO_GREEN),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(5.0),
                                  shape: CircleBorder(side: BorderSide.none),
                                ),
                              ),
                            )
                          : authProvider.showInaamRetryButton &&
                                  !authProvider.getShowInaamRetryLoading
                              ? Center(
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: RawMaterialButton(
                                      onPressed: onPressRetryInaamCallOnly,
                                      elevation: 0.0,
                                      fillColor: Color(0xffFAFAFA),
                                      child: Center(
                                        child: Icon(
                                          Icons.refresh_rounded,
                                          color: values.NESTO_GREEN,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(5.0),
                                      shape:
                                          CircleBorder(side: BorderSide.none),
                                    ),
                                  ),
                                )
                              : Container()),
                ],
              ),
              SizedBox(
                height: ScreenUtil().setHeight(2),
              ),
              Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: ScreenUtil().setHeight(5),
              ),
              showBarCode == true
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: ScreenUtil().setWidth(50),
                            ),
                            Stack(children: [
                              BarcodeWidget(
                                barcode: Barcode.code39(),
                                // Barcode type and settings
                                data: authProvider.inaamCode,
                                // Content
                                width: ScreenUtil().setWidth(200.0),
                                height: ScreenUtil().setHeight(100.0),
                              ),
                            ]),
                          ],
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(70.0),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black26,
                          size: 15,
                        ),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.grey.withOpacity(0.5)),
                      ),
                    ),
              SizedBox(
                height: ScreenUtil().setHeight(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressRetryInaamCallOnly() async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setShowInaamRetryLoading = true;
    print("retry getInaamPointsCall");
    await authProvider.getInaamPointsCall().then((value) {
      authProvider.setShowInaamRetryLoading = false;
      if (authProvider.showInaamRetryButton) {
        showError(context, "Could not fetch inaam details, please try again.");
      }
    });
  }
}
