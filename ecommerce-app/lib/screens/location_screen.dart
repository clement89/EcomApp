import 'dart:convert';
import 'package:Nesto/providers/home_builder_provider.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/providers/auth_provider.dart';
import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/screens/add_address.dart';
import 'package:Nesto/screens/edit_address_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/store_switch_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

import '../utils/util.dart';
import 'base_screen.dart';

class LocationScreen extends StatefulWidget {
  static final routeName = "/location_screen";

  const LocationScreen({
    Key key,
  }) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final String _env = FlavorConfig.instance.variables["env"];
  final apiKey = 'AIzaSyAimaNx9Tt9eNjl_urKFci2g_aom8n0hno';
  final prodApiKey = "AIzaSyDLG4LWs4cAdr03jGfJy3DcPuJHQSRz54Q";
  LatLng _initialPosition = LatLng(25.41111, 55.43504);
  double lat = 25.41111;
  double long = 55.43504;
  //bool _isButtonTapped = false;
  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Location Screen");
    super.initState();
    //firebase analytics logging.
    firebaseAnalytics.locationScreenLoaded();
  }

  @override
  Widget build(BuildContext context) {
    var storeProvider = Provider.of<StoreProvider>(context, listen: false);

    return Scaffold(
      body: ConnectivityWidget(
        child: Container(
            color: Colors.white,
            height: double.infinity,
            width: double.infinity,
            child: PlacePicker(
              apiKey: _env == 'production' ? prodApiKey : apiKey,
              initialPosition: _initialPosition,
              useCurrentLocation: true,
              selectInitialPosition: true,
              usePlaceDetailSearch: true,
              hidePlaceDetailsWhenDraggingPin: false,
              pinBuilder: (context, pinState) {
                switch (pinState) {
                  case PinState.Idle:
                    return Icon(
                      Icons.location_on,
                      color: values.NESTO_GREEN,
                      size: 30,
                    );
                    break;
                  case PinState.Dragging:
                    return Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    );
                    break;
                  default:
                    return Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    );
                    break;
                }
              },
              onPlacePicked: (PickResult result) {
                setState(() {
                  lat = result.geometry.location.lat;
                  long = result.geometry.location.lng;
                });
              },
              selectedPlaceWidgetBuilder:
                  (_, selectedPlace, searchState, isSearchBarFocused) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: searchState == SearchingState.Searching
                      ? Container(
                          height: ScreenUtil().setHeight(200),
                          width: ScreenUtil().setWidth(400),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(values.NESTO_GREEN),
                            ),
                          ))
                      : Container(
                          height: ScreenUtil().setHeight(400),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: ScreenUtil().setHeight(100),
                                  width: ScreenUtil().setWidth(100),
                                  decoration: BoxDecoration(
                                    color: Color(0xffD0F7C3),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: SvgPicture.asset(
                                      'assets/svg/place_holder_9_arun.svg'),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Text(
                                  strings.SELECT_YOUR_LOCATION,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: Color(0xff172B4D),
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(300),
                                  child: Text(
                                    strings
                                        .MOVE_THE_MAP_PIN_TO_FIND_YOUR_LOCATION,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xff7A869A),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.navigation,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          selectedPlace.formattedAddress,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Color(0xff172B4D)),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.green,
                                  thickness: 2.0,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
                                    //            this will override default 'Select here' Button.

                                    //firebase analytics logging.

                                    firebaseAnalytics.locationConfirmed();

                                    logNesto(
                                        "do something with [selectedPlace] data");
                                    EasyLoading.show(
                                        maskType: EasyLoadingMaskType.black);
                                    var currentLat =
                                        selectedPlace.geometry.location.lat;
                                    var currentLng =
                                        selectedPlace.geometry.location.lng;
                                    //TODO:[selectedPlace] HAS VALUE
                                    final authProvider =
                                        Provider.of<AuthProvider>(context,
                                            listen: false);
                                    String previousScreen =
                                        ModalRoute.of(context)
                                            .settings
                                            .arguments;
                                    if (previousScreen ==
                                        AddAddress.routeName) {
                                      int result = await authProvider
                                          .checkIfAddressIsInCurrentStoreId(
                                              userLat: selectedPlace
                                                  .geometry.location.lat,
                                              userLn: selectedPlace
                                                  .geometry.location.lng);

                                      if (result == -1)
                                        showError(
                                            context,
                                            strings
                                                .DELIVERY_NOT_AVAILABLE_IN_THIS_LOCATION);
                                      else {
                                        Navigator.pop(
                                            context,
                                            jsonEncode({
                                              'value': selectedPlace
                                                  .formattedAddress
                                                  .toString(),
                                              'lat': currentLat,
                                              'lng': currentLng,
                                            }));
                                      }
                                    } else if (previousScreen ==
                                        EditAddressScreen.routeName) {
                                      int result = await authProvider
                                          .checkIfAddressIsInCurrentStoreId(
                                              userLat: currentLat,
                                              userLn: currentLng);

                                      if (result == -1) {
                                        showError(
                                            context,
                                            strings
                                                .DELIVERY_NOT_AVAILABLE_IN_THIS_LOCATION);
                                      } else {
                                        Navigator.pop(
                                            context,
                                            jsonEncode({
                                              'value': selectedPlace
                                                  .formattedAddress
                                                  .toString(),
                                              'lat': currentLat,
                                              'lng': currentLng,
                                            }));
                                      }
                                    } else {
                                      int result = await authProvider
                                          .checkIfAddressIsInCurrentStoreId(
                                              userLat: currentLat,
                                              userLn: currentLng);

                                      print('RESULT----->> $result');
                                      //-1: POINT NOT IN POLYGON
                                      //1: POINT IN POLYGON AND WITHIN CURRENT STORE ID
                                      //0: POINT IN POLYGON BUT DIFFERENT STORE ID
                                      //2: POINT IN POLYGON BUT COMING FROM NOT SERVICEABLE AREA
                                      if (result == 1) {
                                        await authProvider
                                            .saveLocationToSharedPreferences(
                                                placeName: selectedPlace
                                                    .formattedAddress
                                                    .toString(),
                                                lat: currentLat,
                                                ln: currentLng);
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                BaseScreen.routeName,
                                                (route) => false,
                                                arguments: {"index": 0});
                                      } else if (result == 0) {
                                        showModalBottomSheet<dynamic>(
                                            isScrollControlled: true,
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(30),
                                              ),
                                            ),
                                            builder: (builder) {
                                              return StoreSwitchModalSheet(
                                                placeName: selectedPlace
                                                    .formattedAddress
                                                    .toString(),
                                                lat: currentLat,
                                                ln: currentLng,
                                              );
                                            });
                                      } else if (result == -1) {
                                        showError(
                                            context,
                                            strings
                                                .DELIVERY_NOT_AVAILABLE_IN_THIS_LOCATION);
                                        // await authProvider
                                        //     .checkIsUserAreaServiceable(
                                        //         userLat: currentLat,
                                        //         userLn: currentLng);
                                        // await authProvider
                                        //     .saveLocationToSharedPreferences(
                                        //         placeName: selectedPlace
                                        //             .formattedAddress
                                        //             .toString(),
                                        //         lat: currentLat,
                                        //         ln: currentLng);
                                        // Navigator.of(context)
                                        //     .pushNamedAndRemoveUntil(
                                        //         BaseScreen.routeName,
                                        //         (route) => false,
                                        //         arguments: {"index": 0});

                                      } else if (result == 2) {
                                        await authProvider
                                            .saveLocationToSharedPreferences(
                                                placeName: selectedPlace
                                                    .formattedAddress
                                                    .toString(),
                                                lat: currentLat,
                                                ln: currentLng);
                                        await authProvider
                                            .checkIsUserAreaServiceable(
                                                userLat: currentLat,
                                                userLn: currentLng);
                                        storeProvider.clearClientCart();
                                        await storeProvider.fetchAll();
                                        var multiHomePageProvider =
                                            Provider.of<MultiHomePageProvider>(
                                                context,
                                                listen: false); //CJC added

                                        await multiHomePageProvider
                                            .getAllHomePageData();
                                        // if (storeProvider
                                        //     .homePageFetchFinished) {

                                        // }
                                        Navigator.of(context).pushNamed(
                                            BaseScreen.routeName,
                                            arguments: {"index": 0});
                                      }
                                    }
                                    EasyLoading.dismiss();
                                  },
                                  child: Container(
                                    height: ScreenUtil().setHeight(68),
                                    width: ScreenUtil().setWidth(300),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        strings.CONFIRM_LOCATION,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 17,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                              ],
                            ),
                          ),
                        ),
                );
              },
            )),
      ),
    );
  }
}
