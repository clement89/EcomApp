import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/providers/substitution_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class BottomText extends StatelessWidget {
  const BottomText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SubstitutionProvider>(context);
    var oldOrderTotal = provider?.substituteOrder?.paymentAmount;
    var newOrderTotal = provider?.total;
    var isLess = newOrderTotal < oldOrderTotal;
    return Visibility(
      visible: provider?.substituteOrder?.paymentType == 'prepaid',
      child: RichText(
        textAlign: TextAlign.center,
        text: new TextSpan(
          style: TextStyle(
              color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w700),
          children: <TextSpan>[
            new TextSpan(
                text: isLess
                    ? strings.THE_BALANCE_AMOUNT_OF
                    : strings.PLEASE_PAY),
            new TextSpan(
              text: (isLess
                          ? oldOrderTotal - newOrderTotal
                          : newOrderTotal - oldOrderTotal)
                      .twoDecimal() +
                  ' ' +
                  strings.AED +
                  ' ',
            ),
            new TextSpan(
                text: isLess
                    ? strings.WILL_BE_REFUNDED_TO_YOU
                    : strings.COD_MESSAGE),
          ],
        ),
      ),
    );
  }
}
