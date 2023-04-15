import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class ContainerCustom extends StatelessWidget {
  final String text1;
  final String text2;
  final Widget widget;

  const ContainerCustom({Key key, this.text1, this.text2, this.widget})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFAFAFA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Row(
                children: [
                  Container(
                    width: ScreenUtil().setWidth(325),
                    child: Text(
                      text1,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Text(
                    text2,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Row(
              children: [
                widget,
                // Expanded(child: SizedBox()),
                // Icon(
                //   Icons.arrow_forward_ios,
                //   color: Colors.black26,
                //   size: 15,
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}
