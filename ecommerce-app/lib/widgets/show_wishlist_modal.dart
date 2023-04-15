import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/optimized_cache_image_widget.dart';
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

Future showWishListModal(BuildContext context, Product product) {
  var provider = Provider.of<StoreProvider>(context, listen: false);

  return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      )),
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, stateSet) {
            return new Container(
              height: ScreenUtil().setWidth(380),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height:
                          ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(127),
                      height: ScreenUtil().setWidth(3),
                      color: Color(0xFFC4C4C4),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(69),
                    ),
                    Text(
                      strings.REMOVE_THIS_ITEM_FROM_FAVORITES,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height:
                          ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
                    ),
                    ImageWidget(
                      imageUrl: product.imageURL,
                      width: ScreenUtil().setWidth(116),
                      height: ScreenUtil().setWidth(101),
                      maxHeightDiskCache: 900,
                      maxWidthDiskCache: 900,
                      fadeInDuration: Duration(milliseconds: 1),
                      errorWidget: (context, error, stackTrace) => Image.asset(
                        "assets/images/placeholder.webp",
                        width: ScreenUtil().setWidth(116),
                        height: ScreenUtil().setWidth(101),
                      ),
                    ),
                    SizedBox(
                      height:
                          ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: SizedBox(
                                width: ScreenUtil().setWidth(140),
                                child: Center(
                                    child: Text(
                                  strings.CANCEL,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                )))),
                        SizedBox(
                          width: ScreenUtil()
                              .setWidth(values.SPACING_MARGIN_SMALL),
                        ),
                        Container(
                          height: ScreenUtil().setWidth(39),
                          width: ScreenUtil().setWidth(160),
                          child: FlatButton(
                              onPressed: () {
                                stateSet(() {
                                  provider.removeFromWishList(product);
                                  Navigator.of(context).pop();
                                });
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: provider.showWishlistSpinner
                                      ? ProductWidgetSpinner(Colors.white)
                                      : Text(strings.YES_REMOVE,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16)))),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
        );
      });
}
