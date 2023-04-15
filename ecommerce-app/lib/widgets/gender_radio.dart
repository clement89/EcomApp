import 'package:Nesto/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Nesto/values.dart' as values;

class GenderRadio extends StatelessWidget {
  const GenderRadio({
    Key key,
    // @required this.value,
    @required this.isSelected,
    @required this.selectedGender,
    @required this.label,
    @required this.onPress,
  }) : super(key: key);

  // final Gender value;
  final bool isSelected;
  final Gender selectedGender;
  final String label;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    // log(isSelected.toString(), name: 'isSelected');
    var genderTextStyle = TextStyle(
        color: values.NESTO_GREEN, fontSize: 15, fontWeight: FontWeight.w600);
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: ScreenUtil().setWidth(114),
        height: ScreenUtil().setHeight(36),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
        decoration: BoxDecoration(
            color: isSelected ? values.NESTO_GREEN : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: values.NESTO_GREEN)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: isSelected,
              child: Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              ),
            ),
            Visibility(
                visible: isSelected,
                child: SizedBox(
                  width: ScreenUtil().setWidth(10),
                )),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: genderTextStyle.copyWith(
                      color: isSelected ? Colors.white : values.NESTO_GREEN),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
