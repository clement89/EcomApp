import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/order.dart';
import 'package:Nesto/screens/order_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:Nesto/strings.dart' as strings;

class OrderWidget extends StatefulWidget {
  OrderWidget({this.order});
  final SingleOrder order;

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  String imageURL;
  String orderstatus;
  void setOrderStatus(String status) {
    switch (status) {
      case 'intransit':
        orderstatus = strings.ON_THE_WAY;
        imageURL = 'assets/svg/transit_sabarish.svg';
        break;
      case 'picking':
        orderstatus = strings.ORDER_GETTING_PICKED;
        imageURL = 'assets/svg/pending_sabarish.svg';
        break;
      case 'packing':
        orderstatus = strings.ORDER_IS_GETTING_PACKED;
        imageURL = 'assets/svg/pending_sabarish.svg';
        break;
      case 'pending':
        orderstatus = strings.ORDER_IS_PENDING;
        imageURL = 'assets/svg/pending_sabarish.svg';
        break;
      case 'delivered':
        orderstatus = strings.ORDER_DELIVERED;
        imageURL = 'assets/svg/completed_sabarish.svg';
        break;
      case 'vehicle_breakdown':
        orderstatus = strings.VEHICLE_BREAKDOWN;
        imageURL = 'assets/svg/pending_sabarish.svg';
        break;
      case 'return_initiated':
        orderstatus = strings.RETURN_INITIATED;
        imageURL = 'assets/svg/completed_sabarish.svg';
        break;
      case 'returned':
        orderstatus = strings.ORDER_RETURNED;
        imageURL = 'assets/svg/completed_sabarish.svg';
        break;
      default:
        orderstatus = strings.ORDER_IS_PENDING;
        imageURL = 'assets/svg/pending_sabarish.svg';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    setOrderStatus(widget.order.status);
    var parsedDate = DateTime.parse(widget.order.createdAt.toString());
    var formatter = DateFormat('EEEE dd-MMM-yyyy');
    var formatted = formatter.format(parsedDate);
    var incrementId = widget.order.increment_id;
    var itemCount = widget.order.totalItemCount;
    var price = double.parse(widget.order.baseGrandTotal);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OrderListingScreen(
                orderid: widget.order.entityId,
              );
            },
          ),
        );
      },
      child: Container(
        height: ScreenUtil().setWidth(98),
        width: double.infinity,
        child: Row(
          children: [
            //image
            Padding(
              padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(20.0),
              ),
              child: SizedBox(
                height: ScreenUtil().setWidth(98),
                width: ScreenUtil().setWidth(98),
                child: SvgPicture.asset(imageURL),
              ),
            ),
            //column of details
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderstatus,
                  style: mainTextStyle,
                ),
                Text(
                  formatted,
                  style: subtext1Style,
                ),
                Text(
                  '#' + incrementId,
                  style: subtext2Style,
                ),
                Row(
                  children: [
                    Text(
                      itemCount + strings.ITEMS,
                      style: subtext2Style.copyWith(color: Color(0XFF7E7F80)),
                    ),
                    Text(' | ', style: TextStyle(color: Color(0XFF7E7F80))),
                    Text(price.twoDecimal() + ' ' + strings.AED,
                        style:
                            subtext2Style.copyWith(color: Color(0XFF7E7F80))),
                  ],
                )
              ],
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: ScreenUtil().setWidth(29.0)),
              child: Icon(Icons.chevron_right),
            )
          ],
        ),
      ),
    );
  }
}

//styles
var mainTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: Colors.black,
);
var subtext1Style =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black);
var subtext2Style =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black);
