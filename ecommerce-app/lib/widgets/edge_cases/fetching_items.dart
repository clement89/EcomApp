import 'package:Nesto/utils/constants.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/optimized_cache_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:Nesto/strings.dart' as strings;

class FetchingItemsWidget extends StatefulWidget {
  final bool isHomePageLoading;
  final String imageUrl;
  const FetchingItemsWidget(
      {Key key,
      this.isHomePageLoading = false,
      this.imageUrl = defaultHomepageLoaderImage})
      : super(key: key);
  @override
  _FetchingItemsWidgetState createState() => _FetchingItemsWidgetState();
}

class _FetchingItemsWidgetState extends State<FetchingItemsWidget> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: ScreenUtil().setWidth(126),
              width: ScreenUtil().setWidth(126),
              child: Lottie.asset('assets/animations/fetching.json'),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(values.SPACING_MARGIN_TEXT),
            ),
            Text(
              strings.HEY_WE_ARE_REACHING_OUT_FOR_PRODUCTS,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
