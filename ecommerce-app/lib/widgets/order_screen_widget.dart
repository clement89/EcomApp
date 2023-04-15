import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderScreenWidget extends StatefulWidget {
  final Color color;
  final bool showTick, showBorder;
  OrderScreenWidget({this.color, this.showBorder, this.showTick});
  @override
  _OrderScreenWidgetState createState() => _OrderScreenWidgetState();
}

class _OrderScreenWidgetState extends State<OrderScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.showBorder?Colors.white:widget.color,
                border: Border.all(
                  color: widget.showBorder?Color(0xff249140):Colors.transparent
                )
              ),
              child: widget.showTick?Padding(
                padding: EdgeInsets.all(5.0),
                child: SvgPicture.asset("assets/icons/tick.svg", color: Colors.white,),
              ):Container(),
            ),
          ],
        ),
      ],
    );
  }
}
