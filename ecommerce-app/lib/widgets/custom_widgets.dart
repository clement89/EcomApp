import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomFilledButton extends StatelessWidget {
  final String title;
  final Function action;
  const CustomFilledButton({
    this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SizedBox(
      height: ScreenUtil().setWidth(50.0),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          side: BorderSide(width: 0.8, color: values.NESTO_GREEN),
          elevation: 0,
          shadowColor: Colors.blueGrey[50],
          primary: Colors.blue[200],
          backgroundColor: values.NESTO_GREEN,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomOutlineButton extends StatelessWidget {
  final String title;
  final Function action;
  const CustomOutlineButton({
    this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SizedBox(
      height: ScreenUtil().setWidth(50.0),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          side: BorderSide(width: 1, color: values.NESTO_GREEN),
          elevation: 1,
          shadowColor: Colors.blueGrey[50],
          primary: Colors.blue[200],
          backgroundColor: Colors.white,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: values.NESTO_GREEN,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class CustomOutlineButtonRed extends StatelessWidget {
  final String title;
  final Function action;
  const CustomOutlineButtonRed({
    this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SizedBox(
      height: ScreenUtil().setWidth(50.0),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          side: BorderSide(
            width: 1,
            color: Colors.redAccent,
          ),
          elevation: 1,
          shadowColor: Colors.blueGrey[50],
          primary: Colors.blue[200],
          backgroundColor: Colors.white,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class RoundedCloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // color: Colors.grey.withOpacity(0.2),
          border: Border.all(
            color: Colors.black54,
          ),
        ),
        child: Icon(
          Icons.close,
          color: Colors.black54,
          size: 16,
        ),
      ),
    );
  }
}

class CustomDateButton extends StatelessWidget {
  final DateTime date;
  final Function action;
  // final bool isSelected;
  const CustomDateButton({
    this.date,
    this.action,
    // this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = true;

    bool isSelectedTodayTimeSlot = false;
    // context.watch<StoreProvider>().isSelectedTodayTimeSlot;

    if (date.day == DateTime.now().day) {
      isSelected = isSelectedTodayTimeSlot;
    } else {
      isSelected = !isSelectedTodayTimeSlot;
    }

    print('ok...$isSelected');

    return SizedBox(
      // height: ScreenUtil().setWidth(100.0),
      // width: 100,

      child: OutlinedButton(
        onPressed: () {
          // if (date.day == DateTime.now().day) {
          //   print('ok');
          //   context.read<StoreProvider>().updateTimeSlotDay(!isSelected);
          // } else {
          //   if (!isSelected) {
          //     context.read<StoreProvider>().updateTimeSlotDay(false);
          //   } else {
          //     context.read<StoreProvider>().updateTimeSlotDay(true);
          //   }
          // }
        },
        style: isSelected
            ? OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                side: BorderSide(width: 0.8, color: values.NESTO_GREEN),
                elevation: 0,
                shadowColor: Colors.blueGrey[50],
                primary: Colors.blue[200],
                backgroundColor: values.NESTO_GREEN,
              )
            : OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                side: BorderSide(width: 1, color: Colors.black12),
                elevation: 1,
                shadowColor: Colors.blueGrey[50],
                primary: Colors.blue[200],
                backgroundColor: Colors.white,
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                returnMonth(date),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                date.day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                returnDay(date),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String returnMonth(DateTime date) {
    return new DateFormat.MMMM().format(date);
  }

  String returnDay(DateTime date) {
    return new DateFormat.E().format(date);
  }
}

class LightBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: Colors.grey.withOpacity(0.1),
    );
  }
}
