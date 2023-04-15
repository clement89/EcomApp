import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/orders_provider.dart';
import 'package:Nesto/widgets/total_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/strings.dart' as strings;

class TotalContainer extends StatelessWidget {
  const TotalContainer({
    Key key,
    @required this.provider,
  }) : super(key: key);

  final OrderProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22)),
      child: Column(
        children: [
          totalRow(
            leftText: strings.AMOUNT_EXCL_VAT,
            rightText: strings.AED +
                ' ' +
                (double.parse(provider.currentOrder.baseSubtotal).twoDecimal()),
          ),
          totalRow(
            leftText: strings.SHIPPING_EXCL_VAT,
            rightText: strings.AED +
                ' ' +
                (double.parse(provider.currentOrder.shippingAmount)
                    .twoDecimal()),
          ),
          totalRow(
            leftText: strings.COUPON_DISCOUNT,
            rightText: strings.AED + ' ' + provider.discountCoupon.twoDecimal(),
          ),
          totalRow(
            leftText: strings.VAT,
            rightText: strings.AED +
                ' ' +
                (double.parse(provider.currentOrder.taxAmount).twoDecimal()),
          ),
        ],
      ),
    );
  }
}
