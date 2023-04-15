import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/extensions/number_extension.dart';

class TotalContainer extends StatelessWidget {
  const TotalContainer({
    Key key,
    @required this.provider,
  }) : super(key: key);

  final StoreProvider provider;

  @override
  Widget build(BuildContext context) {
    return provider.showShippingAddressSpinner
        ? Center(
            child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN)),
          )
        : Column(
            children: [
              totalRow(
                  leftText: strings.AMOUNT_EXCL_VAT,
                  rightText:
                      strings.AED + ' ' + provider.subTotal.twoDecimal()),
              totalRow(
                  leftText: strings.SHIPPING_EXCL_VAT,
                  rightText: strings.AED +
                      ' ' +
                      provider.magentoShippingFee.twoDecimal()),
              totalRow(
                  leftText: strings.COUPON_DISCOUNT,
                  rightText: strings.AED +
                      ' ' +
                      provider.magentoDiscount.twoDecimal()),
              totalRow(
                  leftText: strings.VAT,
                  rightText:
                      strings.AED + ' ' + provider.magentoTax.twoDecimal()),
              SizedBox(height: 10.0)
            ],
          );
  }
}

Widget totalRow({String rightText, String leftText}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leftText,
          style: leftTotalTextStyle,
        ),
        Text(
          rightText,
          style: rightTotalTextStyle,
        )
      ],
    ),
  );
}

//styles
const leftTotalTextStyle =
    TextStyle(fontSize: 15.47, fontWeight: FontWeight.w500);

const rightTotalTextStyle = TextStyle(
  fontSize: 17.67,
  fontWeight: FontWeight.w700,
);
