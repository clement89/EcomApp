import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/home_builder_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/base_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class StoreSwitchModalSheet extends StatefulWidget {
  final String placeName;
  final double lat, ln;

  bool isLoading = false;

  StoreSwitchModalSheet({this.placeName, this.lat, this.ln});

  @override
  _StoreSwitchModalSheetState createState() => _StoreSwitchModalSheetState();
}

class _StoreSwitchModalSheetState extends State<StoreSwitchModalSheet> {
  @override
  Widget build(BuildContext context) {
    var storeProvider = Provider.of<StoreProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context, listen: false);

    return new Container(
        height: ScreenUtil().setHeight(430.0),
        width: ScreenUtil().screenWidth,
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: ScreenUtil().setHeight(15.0)),
              Container(
                width: ScreenUtil().setWidth(150.0),
                height: 2,
                decoration: BoxDecoration(
                    color: Color(0xFFC4C4C4),
                    borderRadius: BorderRadius.circular(1.5)),
              ),
              Expanded(child: SizedBox()),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      strings.CONFIRM_STORE_CHANGE,
                      style: TextStyle(
                          color: Color(0xFF252529),
                          fontSize: 28.0,
                          fontWeight: FontWeight.w600),
                    )),
                    SizedBox(height: ScreenUtil().setHeight(24.0)),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(32)),
                      child: Center(
                          child: Text(
                        strings.STORE_CHANGE_DESCRIPTION,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF252529),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400),
                      )),
                    ),
                  ],
                ),
              ),
              Expanded(child: SizedBox()),
              Container(
                width: ScreenUtil().setWidth(350.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                        width: ScreenUtil().setWidth(150.0),
                        height: ScreenUtil().setHeight(40.0),
                        color: Colors.transparent,
                        child: Center(
                            child: Text(
                          strings.NO,
                          style: TextStyle(
                              fontFamily: 'SFProDisplay',
                              color: Color(0xFF00983D),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400),
                        )),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(150.0),
                      height: ScreenUtil().setHeight(40.0),
                      child: RaisedButton(
                          color: Color(0xFF00883D),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.0)),
                          child: Center(
                              child: !widget.isLoading
                                  ? Text(
                                      strings.CONFIRM,
                                      style: TextStyle(
                                          fontFamily: 'SFProDisplay',
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    )
                                  : SizedBox(
                                      width: ScreenUtil().setWidth(16),
                                      height: ScreenUtil().setWidth(16),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.white)),
                                    )),
                          onPressed: () async {
                            try {
                              if (!widget.isLoading) {
                                setState(() {
                                  widget.isLoading = true;
                                });
                                await authProvider
                                    .saveLocationToSharedPreferences(
                                        placeName: widget.placeName,
                                        lat: widget.lat,
                                        ln: widget.ln);
                                await authProvider.checkIsUserAreaServiceable(
                                    userLat: widget.lat, userLn: widget.ln);
                                storeProvider.clearTimeSlots();
                                storeProvider.clearClientCart();
                                storeProvider
                                    .resetHasCartBeenFetchedInitially();
                                await storeProvider.fetchAll();
                                var multiHomePageProvider =
                                    Provider.of<MultiHomePageProvider>(context,
                                        listen: false); //CJC added

                                await multiHomePageProvider
                                    .getAllHomePageData();
                                // if (storeProvider.homePageFetchFinished) {

                                // }
                                Navigator.of(context).pushNamed(
                                    BaseScreen.routeName,
                                    arguments: {"index": 0});
                              }
                            } catch (e) {
                              widget.isLoading = false;
                            }
                          }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(35.0)),
            ]));
  }
}
