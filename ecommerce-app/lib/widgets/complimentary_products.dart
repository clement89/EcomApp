import 'package:Nesto/models/product.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/values.dart' as values;

class ComplimentaryProducts extends StatelessWidget {
  const ComplimentaryProducts({
    Key key,
    @required this.future,
    @required this.products,
  }) : super(key: key);

  final Future future;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (_, snapshot) {
          Widget _child;

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              _child = Container(
                width: double.infinity,
                height: ScreenUtil().setWidth(275),
                child: Center(
                  child: SizedBox(
                    height: ScreenUtil().setWidth(20),
                    width: ScreenUtil().setWidth(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN),
                    ),
                  ),
                ),
              );
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                _child = Container();
              } else {
                _child = Visibility(
                  visible: products.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(14),
                            vertical: ScreenUtil().setHeight(20.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Frequently Bought Together",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ),
                            Visibility(
                                visible: false, child: SeeMore(onPress: () {})),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil().setWidth(275),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (BuildContext context, int index) {
                            var product = products[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(10.0)),
                              child: ProductWidget(
                                product: product,
                                type2: false,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
              break;
            default:
              _child = Container();
              break;
          }
          return AnimatedSwitcher(
            switchInCurve: Curves.fastOutSlowIn,
            duration: Duration(milliseconds: 500),
            child: _child,
          );
        });
  }
}
