import 'package:Nesto/extensions/number_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Nesto/strings.dart' as strings;

class ProductListContainer extends StatelessWidget {
  final String title, time, orderid, numberofitems, price;
  final String asetimage;
  final Color clr;

  ProductListContainer(this.title, this.time, this.orderid, this.numberofitems,
      this.price, this.asetimage, this.clr);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setHeight(140),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width * 0.20,
            height: ScreenUtil().setHeight(150),
            decoration: BoxDecoration(
              color: Color(0xffF6F7FA),
              border: Border.all(
                width: 2,
                color: clr,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
                padding: EdgeInsets.all(10),
                child: SvgPicture.asset(asetimage)),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(5),
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                  Text('#' + orderid,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 14)),
                  numberofitems == '1'
                      ? Text(
                          numberofitems +
                              strings.ITEM +
                              ' | ' +
                              strings.AED +
                              ' ' +
                              price.roundToTwoDecimal(),
                          style: TextStyle(
                              color: Color(0xff7E7F80),
                              fontWeight: FontWeight.w400,
                              fontSize: 14),
                        )
                      : Text(
                          numberofitems +
                              strings.ITEMS +
                              ' | ' +
                              strings.AED +
                              ' ' +
                              price.roundToTwoDecimal(),
                          style: TextStyle(
                              color: Color(0xff7E7F80),
                              fontWeight: FontWeight.w400,
                              fontSize: 14),
                        )
                ],
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Container(
            child: Icon(
              Icons.arrow_forward_ios_outlined,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }
}

extension totalPrecision on String {
  String roundToTwoDecimal() => double.parse(this).twoDecimal();
}
