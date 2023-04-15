import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/substitution_provider.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/widgets/substitute_bottom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/strings.dart' as strings;
import 'package:provider/provider.dart';

class TotalContainer extends StatelessWidget {
  const TotalContainer({Key key}) : super(key: key);

  showDialog({String message, String title}) {
    notificationServices.showCustomDialog(
        title: title,
        description: message,
        negativeText: '',
        positiveText: strings.OK,
        positiveTextColor: values.NESTO_GREEN);
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SubstitutionProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
          ),
          Text(
            strings.ITEMS_WITH_BRACKET +
                provider?.substituteOrder?.itemCount.toString() +
                ')',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.PREVIOUS_ORDER_TOTAL,
                style: leftTextStyle,
              ),
              Text(
                strings.AED +
                    ' ' +
                    (provider.substituteOrder.paymentAmount).twoDecimal(),
                style: rightTextStyle,
              )
            ],
          ),
          SizedBox(
            height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
          ),
          Divider(),
          SizedBox(
            height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.Items_out_of_stock,
                style: leftTextStyle,
              ),
              Text(
                strings.AED +
                    ' ' +
                    Provider.of<SubstitutionProvider>(context)
                        .calculateOutOfStockTotal
                        .twoDecimal(),
                style: rightTextStyle,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.SUBSTITUTION_ADDED,
                style: leftTextStyle,
              ),
              Text(
                strings.AED + ' ' + provider.substitutesAdded.twoDecimal(),
                style: rightTextStyle,
              )
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.AMOUNT_EXCL_VAT,
                style: leftTextStyle,
              ),
              Text(
                strings.AED + ' ' + provider.cartSubTotal.twoDecimal(),
                style: rightTextStyle,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                strings.SHIPPING_EXCL_VAT,
                style: leftTextStyle,
              ),
              SizedBox(width: ScreenUtil().setWidth(10.0)),
              GestureDetector(
                  onTap: () {
                    showDialog(
                        title: strings.SHIPPING_ALERT,
                        message: strings
                                .SHIPPING_FEE_WILL_BE_ADDED_IF_SUBTOTAL_IS_BELOW_AED +
                            "${provider.shippingLimit ?? 0.00}");
                  },
                  child: Icon(
                    Icons.info,
                    color: Colors.blueGrey.withOpacity(0.3),
                    size: 20,
                  )),
              Spacer(),
              Text(
                strings.AED +
                    ' ' +
                    double.parse(provider?.currentOrder?.shippingAmount ?? '0')
                        .twoDecimal(),
                style: rightTextStyle,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                strings.COUPON_DISCOUNT,
                style: leftTextStyle,
              ),
              SizedBox(width: ScreenUtil().setWidth(10.0)),
              Visibility(
                visible: (false),
                child: GestureDetector(
                    onTap: () {
                      showDialog(
                          title: strings.COUPON_APPLIED,
                          message: strings
                                  .COUPON_WILL_BE_REMOVED_PERMENENTLY_IF_SUBTOTAL_IS_BELOW_AED +
                              "${provider.couponDiscountLimit ?? 0.00}");
                    },
                    child: Icon(
                      Icons.info,
                      color: Colors.blueGrey.withOpacity(0.3),
                      size: 20,
                    )),
              ),
              Spacer(),
              Text(
                strings.AED +
                        ' ' +
                        double.parse(provider.currentOrder.discount_amount)
                            .twoDecimal() ??
                    0.00,
                style: rightTextStyle,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.VAT,
                style: leftTextStyle,
              ),
              Text(
                strings.AED + ' ' + provider.vat.twoDecimal(),
                style: rightTextStyle,
              )
            ],
          ),
          Visibility(
            visible: (provider.currentOrder.couponCode != null &&
                (double.parse(provider.currentOrder.discount_amount) > 0) &&
                provider.currentOrder.couponCode.toString().isNotEmpty),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.Coupon_applied,
                  style: leftTextStyle,
                ),
                Text(
                  provider?.appliedCouponCode,
                  style: rightTextStyle,
                )
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
          ),
          Divider(),
          SizedBox(
            height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
          ),
          BottomText(),
          SizedBox(
            height: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
          ),
          Divider()
        ],
      ),
    );
  }
}

//styles
var leftTextStyle =
    TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500);
var rightTextStyle =
    TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w700);
