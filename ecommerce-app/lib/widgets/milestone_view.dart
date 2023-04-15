import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MilestoneView extends StatefulWidget {
  final showCartButton;
  MilestoneView({this.showCartButton});

  @override
  _MilestoneViewState createState() => _MilestoneViewState();
}

class _MilestoneViewState extends State<MilestoneView> {
  double needMoreShipping = 0;
  double needMoreOrder = 0;

  @override
  Widget build(BuildContext context) {
    double total = context.read<StoreProvider>().grandTotal;
    needMoreOrder = 0;
    needMoreShipping = 0;

    if (total < minSubTotal) {
      needMoreOrder = minSubTotal - total;
    }

    if (total < freeShippingMinTotal) {
      needMoreShipping = freeShippingMinTotal - total;
    }
    if (needMoreOrder > 0) {
      needMoreShipping = 0;
    }

    if (needMoreOrder > 0) {
      return _needMoreOrder();
    } else if (needMoreShipping > 0) {
      return _needMoreShipping();
    } else {
      return Container();
    }

    // return Padding(
    //   padding: const EdgeInsets.all(20.0),
    //   child: Container(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         (needMoreShipping > 0 || needMoreOrder > 0)
    //             ? Text(
    //                 needMoreShipping > 0
    //                     ? 'Add ${needMoreShipping.toStringAsFixed(2)} AED More'
    //                     : 'Add ${needMoreOrder.toStringAsFixed(2)} AED More',
    //                 textAlign: TextAlign.end,
    //                 style: TextStyle(
    //                   color: Colors.black54,
    //                   fontSize: 14,
    //                   fontWeight: FontWeight.w400,
    //                 ),
    //               )
    //             : Container(),
    //         SizedBox(height: 10),
    //         (needMoreShipping > 0 || needMoreOrder > 0)
    //             ? Text(
    //                 needMoreShipping > 0
    //                     ? 'Shop for minimum $freeShippingMinTotal to get FREE delivery.'
    //                     : 'Shop for minimum $minSubTotal AED to place an order.',
    //                 textAlign: TextAlign.end,
    //                 style: TextStyle(
    //                   color: Colors.black,
    //                   fontSize: 14,
    //                   fontWeight: FontWeight.w600,
    //                 ),
    //               )
    //             : Container(),
    //         SizedBox(height: 15),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Stack(
    //                   children: [
    //                     Container(
    //                       height: 8,
    //                       width: needMoreOrder > 0
    //                           ? size.width *
    //                               (0.4 *
    //                                   ((minSubTotal - needMoreOrder) /
    //                                       minSubTotal))
    //                           : size.width * 0.4,
    //                       decoration: BoxDecoration(
    //                         color: values.NESTO_GREEN.withOpacity(0.7),
    //                         borderRadius: BorderRadius.circular(10),
    //                       ),
    //                     ),
    //                     Container(
    //                       height: 8,
    //                       width: size.width * 0.4,
    //                       decoration: BoxDecoration(
    //                         color: values.NESTO_GREEN.withOpacity(0.3),
    //                         borderRadius: BorderRadius.circular(10),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 15),
    //                 Row(
    //                   children: [
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         color: Colors.black12,
    //                         borderRadius: BorderRadius.circular(20),
    //                       ),
    //                       child: Padding(
    //                         padding: const EdgeInsets.all(5.0),
    //                         child: Icon(
    //                           Icons.shopping_cart,
    //                           size: 14,
    //                           color: Colors.black87,
    //                         ),
    //                       ),
    //                     ),
    //                     SizedBox(width: 5),
    //                     Text(
    //                       'Eligible to place order',
    //                       textAlign: TextAlign.end,
    //                       style: TextStyle(
    //                         color: Colors.black54,
    //                         fontSize: 14,
    //                         fontWeight: FontWeight.w400,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Stack(
    //                   children: [
    //                     Container(
    //                       height: 8,
    //                       width: needMoreShipping > 0
    //                           ? size.width *
    //                               (0.4 *
    //                                   ((freeShippingMinTotal -
    //                                           needMoreShipping) /
    //                                       freeShippingMinTotal))
    //                           : needMoreShipping < 0
    //                               ? size.width * 0.0
    //                               : size.width * 0.4,
    //                       decoration: BoxDecoration(
    //                         color: values.NESTO_GREEN.withOpacity(0.7),
    //                         borderRadius: BorderRadius.circular(10),
    //                       ),
    //                     ),
    //                     Container(
    //                       height: 8,
    //                       width: size.width * 0.4,
    //                       decoration: BoxDecoration(
    //                         color: values.NESTO_GREEN.withOpacity(0.3),
    //                         borderRadius: BorderRadius.circular(10),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(height: 15),
    //                 Row(
    //                   children: [
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         color: Colors.black12,
    //                         borderRadius: BorderRadius.circular(20),
    //                       ),
    //                       child: Padding(
    //                         padding: const EdgeInsets.all(5.0),
    //                         child: Icon(
    //                           Icons.delivery_dining,
    //                           size: 14,
    //                           color: Colors.black87,
    //                         ),
    //                       ),
    //                     ),
    //                     SizedBox(width: 5),
    //                     Text(
    //                       'Free delivery',
    //                       textAlign: TextAlign.end,
    //                       style: TextStyle(
    //                         color: Colors.black54,
    //                         fontSize: 14,
    //                         fontWeight: FontWeight.w400,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             )
    //           ],
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _needMoreOrder() {
    return Container(
      color: Colors.green.withOpacity(0.13),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Container(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Text(
                'Add',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ' ${needMoreOrder.toStringAsFixed(2)} AED',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' more to place an order',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              widget.showCartButton ? _viewCartButton() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _needMoreShipping() {
    return Container(
      color: Colors.green.withOpacity(0.13),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Container(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.delivery_dining,
                    size: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Text(
                'Add',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ' ${needMoreShipping.toStringAsFixed(2)} AED',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' more for free delivery',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              widget.showCartButton ? _viewCartButton() : Container(),
            ],
          ),
        ),
      ),
    );
  }

//   // Widget _needMoreShipping() {
//   //   return Padding(
//   //     padding: const EdgeInsets.all(20.0),
//   //     child: Container(
//   //       child: Row(
//   //         children: [
//   //           Container(
//   //             decoration: BoxDecoration(
//   //               color: Colors.white,
//   //               borderRadius: BorderRadius.circular(20),
//   //             ),
//   //             child: Padding(
//   //               padding: const EdgeInsets.all(5.0),
//   //               child: Icon(
//   //                 Icons.delivery_dining,
//   //                 size: 14,
//   //                 color: Colors.black87,
//   //               ),
//   //             ),
//   //           ),
//   //           SizedBox(width: 5),
//   //           Text(
//   //             'Add',
//   //             textAlign: TextAlign.end,
//   //             style: TextStyle(
//   //               color: Colors.black,
//   //               fontSize: 14,
//   //               fontWeight: FontWeight.w500,
//   //             ),
//   //           ),
//   //           Text(
//   //             ' ${needMoreShipping.toStringAsFixed(2)} AED',
//   //             textAlign: TextAlign.end,
//   //             style: TextStyle(
//   //               color: Colors.green,
//   //               fontSize: 14,
//   //               fontWeight: FontWeight.w700,
//   //             ),
//   //           ),
//   //           Text(
//   //             ' more for free delivery',
//   //             textAlign: TextAlign.end,
//   //             style: TextStyle(
//   //               color: Colors.black,
//   //               fontSize: 14,
//   //               fontWeight: FontWeight.w500,
//   //             ),
//   //           ),
//   //           Spacer(),
//   //           widget.showCartButton ? _viewCartButton() : Container(),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

  Widget _viewCartButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacementNamed(BaseScreen.routeName,
            arguments: {"index": 3});
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View Cart',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeMilestoneView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double total = context.read<StoreProvider>().grandTotal;
    int cartLength = context.watch<StoreProvider>().cartCount ?? 0;

    return cartLength == 0
        ? SizedBox(height: 0, width: 0)
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: values.NESTO_GREEN,
                borderRadius: BorderRadius.all(Radius.circular(4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            '$cartLength ITEMS',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 10),
                        //   child: Container(
                        //     height: 4,
                        //     width: 4,
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(2),
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            height: 15,
                            width: 1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            'AED $total',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(
                            BaseScreen.routeName,
                            arguments: {"index": 3});
                      },
                      child: Container(
                        height: 40,
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View Cart',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
