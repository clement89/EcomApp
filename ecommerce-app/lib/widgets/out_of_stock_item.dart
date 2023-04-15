import 'package:Nesto/extensions/number_extension.dart';
import 'package:Nesto/models/substitute_model.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/strings.dart' as strings;
import 'optimized_cache_image_widget.dart';

class OutOfStockItemWidget extends StatelessWidget {
  final ItemSub item;

  OutOfStockItemWidget(this.item);

  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      height: ScreenUtil().setWidth(88),
      /*margin: EdgeInsets.only(
          right: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD)),*/
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xFFF5F5F8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(18),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(53),
                width: ScreenUtil().setWidth(57),
                child: ImageWidget(
                  fadeInDuration: Duration(milliseconds: 1),
                  maxWidthDiskCache: 900,
                  maxHeightDiskCache: 900,
                  imageUrl: item.imageUrl,
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(110),
                    child: Text(
                      item?.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w300,
                          fontSize: 16),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        strings.AED + ' ' + item?.price?.twoDecimal(),
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      SizedBox(
                        width:
                            ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
                      ),
                      /*Text(
                        ((item.discount) * 100)
                                .toInt()
                                .toString() +
                            "% Off",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: values.NESTO_GREEN),
                      ),*/
                    ],
                  )
                ],
              )
            ],
          ),
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(115),
                height: ScreenUtil().setWidth(53),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Center(
                  child: Text(
                    item.quantityOutOfStock.toString(),
                    style: TextStyle(
                        color: Color(0xFFC71712),
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(18),
              ),
            ],
          )
        ],
      ),
    );
  }
}
