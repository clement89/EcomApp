import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class BottomContainer extends StatelessWidget {
  const BottomContainer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<OrderProvider>(context);

    return Container(
      height: ScreenUtil().setWidth(120),
      width: double.infinity,
      decoration: bottomContainerDecoration,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(18.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.GRAND_TOTAL,
                    style: TextStyle(
                      fontSize: 17.67,
                      height: 1.19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    strings.VAT_INCLUSIVE,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.19,
                        color: Color(0XFF898B9A),
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
              Text(
                strings.AED +
                    ' ' +
                    double.parse(provider?.currentOrder?.baseGrandTotal ?? 0)
                        .twoDecimal(),
                style: TextStyle(fontSize: 22.09, fontWeight: FontWeight.w800),
              )
            ],
          ),
        ],
      ),
    );
  }
}

//styles.
BoxDecoration bottomContainerDecoration = BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
          color: Color(0XFF000000).withOpacity(0.05),
          blurRadius: 10.0,
          offset: Offset(0.0, 0.75))
    ],
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)));
