import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/values.dart' as values;

class EditLoader extends StatefulWidget {
  const EditLoader({
    Key key,
  }) : super(key: key);

  @override
  _EditLoaderState createState() => _EditLoaderState();
}

class _EditLoaderState extends State<EditLoader> {
  List<String> stepsForEdit = [
    "Finding your order",
    "Preparing your changes",
    "Making necessary changes",
    "Checking for discounts",
    "Calculating taxes",
    "Checking shipping status",
    "Finalising your changes",
    "Waiting for confirmation"
  ];
  int counter = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: ScreenUtil().setWidth(260),
      height: ScreenUtil().setHeight(200),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.84), color: Colors.white),
      padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
      child: Container(
        height: ScreenUtil().setHeight(100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(values.NESTO_GREEN),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(20),
          ),
          Container(
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
              child: AnimatedTextKit(
                pause: const Duration(milliseconds: 100),
                repeatForever: true,
                animatedTexts: stepsForEdit
                    .map(
                      (e) => FadeAnimatedText(e,
                          textAlign: TextAlign.center,
                          duration: const Duration(seconds: 3)),
                    )
                    .toList(),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
