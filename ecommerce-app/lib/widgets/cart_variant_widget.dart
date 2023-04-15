import 'package:Nesto/models/cartItem.dart';
import 'package:Nesto/models/product.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/product_details.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/product_widget_spinner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;
import 'optimized_cache_image_widget.dart';
import 'package:Nesto/extensions/number_extension.dart';

class CartVariantWidget extends StatefulWidget {
  const CartVariantWidget({
    Key key,
    @required this.product,
  }) : super(key: key);

  final Product product;

  @override
  _CartVariantWidgetState createState() => _CartVariantWidgetState();
}

class _CartVariantWidgetState extends State<CartVariantWidget> {
  bool hideOutOfStockText;

  @override
  void initState() {
    hideOutOfStockText = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    var provider = Provider.of<StoreProvider>(context);
    return Container(
      width: ScreenUtil().setHeight(250.00),
      height: ScreenUtil().setHeight(88.37),
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: Color(0XFFF5F5F8),
        borderRadius: BorderRadius.circular(8.84),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ProductDetail(
                  sku: widget.product.sku ?? "",
                );
              },
            ),
          );
        },
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(17.67)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //image
              Container(
                height: ScreenUtil().setHeight(53.02),
                width: ScreenUtil().setWidth(57.44),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    // child: Image.asset(cartItem.product.imageURL),
                    child: ImageWidget(
                        fadeInDuration: Duration(milliseconds: 1),
                        maxWidthDiskCache: 900,
                        maxHeightDiskCache: 900,
                        imageUrl: widget.product.imageURL),
                  ),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(17.68),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ScreenUtil().setWidth(130),
                    child: Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15.47,
                          height: 1.19,
                          color: Color(0XFF111A2C)),
                    ),
                  ),
                  Text(
                    strings.AED +
                            ' ${widget.product?.crossPrice != 0 ? widget.product.crossPrice?.twoDecimal() : widget.product?.taxIncludedPrice?.twoDecimal()}' ??
                        '--',
                    style: TextStyle(
                        color: Color(0XFF00983D),
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
