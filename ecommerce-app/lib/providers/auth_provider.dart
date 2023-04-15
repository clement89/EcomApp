import 'dart:convert';

import 'package:Nesto/dio/models/check_if_address_is_in_current_store_id_request.dart';
import 'package:Nesto/dio/models/check_if_address_is_in_current_store_id_response.dart';
import 'package:Nesto/dio/models/check_if_user_area_serviceable_request.dart';
import 'package:Nesto/dio/models/check_if_user_area_serviceable_response.dart';
import 'package:Nesto/dio/models/edit_user_profile_response.dart';
import 'package:Nesto/dio/models/fetch_magento_user_response.dart';
import 'package:Nesto/dio/models/get_inaam_points_response.dart';
import 'package:Nesto/dio/models/header_model.dart';
import 'package:Nesto/dio/models/otp_verification_request.dart';
import 'package:Nesto/dio/models/otp_verification_response.dart';
import 'package:Nesto/dio/models/register_fcm_token_request.dart';
import 'package:Nesto/dio/models/register_new_user_magento_request.dart';
import 'package:Nesto/dio/models/register_new_user_magento_response.dart';
import 'package:Nesto/dio/models/send_mobile_number_to_magento_request.dart';
import 'package:Nesto/dio/models/send_mobile_number_to_magento_response.dart';
import 'package:Nesto/dio/utils/state.dart';
import 'package:Nesto/dio/utils/urls.dart';
import 'package:Nesto/models/address.dart';
import 'package:Nesto/models/custom_attributes.dart';
import 'package:Nesto/models/shipping_address.dart';
import 'package:Nesto/models/user.dart';
import 'package:Nesto/screens/add_address.dart';
import 'package:Nesto/services/api_service.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/firebase_cloud_messaging.dart';
import 'package:Nesto/services/firebase_subscription.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  //Object Decelerations

  FirebaseTopicSubscription topicInstance = FirebaseTopicSubscription();

  bool otpVerifiedStatus;

  String fcmToken = "";

  String inaamCode = "";

  double inaamPoints = 0.0;

  double inaamPointsLifeTime = 0.0;

  //Check if FCM token needs to be registered in Lambda
  bool registerFCMFlag = false;

  //Variable to check if user needs to be registered
  // bool doesUserNeedsToBeRegistered = false;

  //Variable to let existing proceed to otp screen directly
  bool canUserProceedToOTPScreen = false;

  //Confusing but Variable to check if user needs to magento during otp verification
  bool shouldUserBeRegisteredDuringOTPVerification = false;

  //Variable to hold temp token while logging in
  String _tempToken = "";
  String _tempLambdaToken = "";

  //Error handling for authentication
  bool isAuthError = false;
  String errorMessage = "";

  //Variables that are used during Auth Module
  String phoneNumber = "";
  String userFullName = "";
  String email = "";
  String otp = "";

  //Variable to indicate registration is complete
  bool isRegistrationComplete = false;

  //Check if user area is serviceable
  bool isAreaServicable = false;

  //Get the time at which customer opened the app
  DateTime timeAtWhichCustomerOpenedTheApp;

  String userLocationName = "";

  User magentoUser;

  set resetInaamDetails(value) {
    inaamCode = value;
    inaamPoints = 0.0;
    inaamPointsLifeTime = 0.0;
  }

  void clearMagentoUser() {
    magentoUser = null;
    notifyListeners();
  }

  //Logout a user
  bool logOutUser = false;
  bool logOutUserFailed = false;

  //Resend OTP Timer
  bool resendOTPTimer = false;

  //Show an error message based on storeId
  int storeIdInPolygonCheck = 0;
  String websiteNameInPolygonCheck = "";

  void showResendOTPTimer() {
    resendOTPTimer = true;
    notifyListeners();
  }

  void hideResendOTPTimer() {
    resendOTPTimer = false;
    notifyListeners();
  }

  SharedPreferences encryptedSharedPreferences;

  Future<void> getUserLocation() async {
    SharedPreferences encryptedSharedPreferences =
        await SharedPreferences.getInstance();

    userLocationName =
        encryptedSharedPreferences.getString('userlocationname') ?? "";

    await checkIsUserAreaServiceable(
        userLat: encryptedSharedPreferences.getDouble('userlat') ?? 1.0,
        userLn: encryptedSharedPreferences.getDouble('userlng') ?? 1.0);
  }

  bool isLoading = false;

  //Load BASE_URL from values

  Future checkIsUserAreaServiceable({double userLat, double userLn}) async {
    logNesto("check Is User Area Serviceable");

    await apiService
        .checkIsUserAreaServiceable(
            checkIfUserAreaServiceableRequest:
                CheckIfUserAreaServiceableRequest(
                    userLat: userLat, userLn: userLn))
        .then((state) {
      if (state is SuccessState) {
        CheckIfUserAreaServiceableResponse checkIfUserAreaServiceableResponse =
            state.value;
        topicInstance.unSubscribeToTopic(topic: storeCode);

        bool isPointInPolygon =
            checkIfUserAreaServiceableResponse.data.isPointInPolygon ?? false;

        String id = "1", code;

        if (ENV != "production") {
          code = "en_ajh";
        } else {
          code = "en_ajman";
        }

        if (checkIfUserAreaServiceableResponse.data.websiteId != null)
          websiteId =
              int.parse(checkIfUserAreaServiceableResponse.data.websiteId) ?? 1;

        if (checkIfUserAreaServiceableResponse.data.sapWebsiteId != null)
          sapWebsiteId =
              int.parse(checkIfUserAreaServiceableResponse.data.sapWebsiteId) ??
                  8042;

//CJC added
        if (checkIfUserAreaServiceableResponse.data.minSubTotal != null)
          minSubTotal =
              double.parse(checkIfUserAreaServiceableResponse.data.minSubTotal);
        if (checkIfUserAreaServiceableResponse.data.shippingCharge != null)
          shippingCharge = double.parse(
              checkIfUserAreaServiceableResponse.data.shippingCharge);
        if (checkIfUserAreaServiceableResponse.data.sapWebsiteId != null)
          editOrderMinSubTotal = double.parse(
              checkIfUserAreaServiceableResponse.data.editOrderMinSubTotal);
//.....
        if (checkIfUserAreaServiceableResponse.data.websiteName != null)
          websiteName = checkIfUserAreaServiceableResponse.data.websiteName;

        if (checkIfUserAreaServiceableResponse.data.stores.isNotEmpty) {
          id = checkIfUserAreaServiceableResponse.data.stores[0].storeId ?? "1";
          code = checkIfUserAreaServiceableResponse.data.stores[0].storeCode ??
              code;
        }

        getShippingInfo();

        int result;

        //-1: POINT NOT IN POLYGON
        //1: POINT IN POLYGON AND WITHIN CURRENT STORE ID
        //0: POINT IN POLYGON BUT DIFFERENT STORE ID
        //2: POINT IN POLYGON BUT COMING FROM NOT SERVICEABLE AREA
        if (isPointInPolygon) {
          isDefaultStore = false;
          int newStoreId = int.parse(id) ?? -1;

          if (storeId != -1 && storeId == newStoreId) {
            result = 1;
          } else if (storeId != -1 && storeId != newStoreId) {
            result = 0;
          } else {
            result = 1;
          }
        } else {
          isDefaultStore = true;
          result = -1;
        }

        isAreaServicable = isPointInPolygon;
        storeId = int.parse(id) ?? -1;
        storeCode = code;

        //subscribe to new topic
        topicInstance.subscribeToTopic(topic: storeCode);

        notifyListeners();
        return result;
      } else if (state is ErrorState) {
        logNestoCustom(message: state.msg, logType: LogType.error);
      }
    });
  }

  //CJC added
  Future getShippingInfo() async {
    final url = MAGENTO_BASE_URL +
        "/V1/shippingDetails?websiteId=" +
        websiteId.toString();
    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };
    //
    logNesto("URL asas" + url.toString());
    logNesto("HEADER ss" + header.toString());

    try {
      var response = await Dio().request(
        url,
        // data: body,
        options: Options(
            method: 'GET',
            headers: header,
            receiveTimeout: 20000,
            sendTimeout: 20000),
      );

      var data = json.decode(response.toString()) as Map<String, dynamic>;
      freeShippingMinTotal = double.parse(data['minSubTotal'].toString());
      print('freeShippingMinTotal--- $freeShippingMinTotal , $data');
    } on DioError catch (e) {}
  }

  Future checkIfAddressIsInCurrentStoreId(
      {double userLat, double userLn}) async {
    logNesto("CHECK IF ADDRESS IN CURRENT STORE ID");

    States state = await apiService.checkIfAddressIsInCurrentStoreId(
        checkIIfAddressIsInCurrentStoreIdRequest:
            CheckIIfAddressIsInCurrentStoreIdRequest(
                userLat: userLat, userLn: userLn));
    if (state is SuccessState) {
      CheckIfAddressIsInCurrentStoreIdResponse
          checkIfAddressIsInCurrentStoreIdResponse = state.value;

      bool isPointInPolygon =
          checkIfAddressIsInCurrentStoreIdResponse.data.isPointInPolygon ??
              false;
      int id = 1;

      if (checkIfAddressIsInCurrentStoreIdResponse.data.stores.length > 0) {
        id = int.parse(
            checkIfAddressIsInCurrentStoreIdResponse.data.stores[0].storeId);
        storeIdInPolygonCheck = id;
      }

      if (checkIfAddressIsInCurrentStoreIdResponse.data.websiteName != null)
        websiteNameInPolygonCheck =
            checkIfAddressIsInCurrentStoreIdResponse.data.websiteName;

      //-1: POINT NOT IN POLYGON
      //1: POINT IN POLYGON AND WITHIN CURRENT STORE ID
      //0: POINT IN POLYGON BUT DIFFERENT STORE ID
      //2: POINT IN POLYGON BUT COMING FROM NOT SERVICEABLE AREA

      if (isPointInPolygon) {
        if (storeId == id) {
          //For default store id,Do a reinit to avoid a bug from switching from non serviceable area to default store
          if (isDefaultStore) {
            return 2;
          } else
            return 1;
        } else if (isDefaultStore)
          return 2;
        else
          return 0;
      } else {
        return -1;
      }
    } else if (state is ErrorState) {
      logNestoCustom(message: state.msg, logType: LogType.error);
    }
  }

  // Future updateFCMTokenInLambda() async {
  //   logNesto("updateFCMTokenInLambda is called");
  //   await apiService
  //       .updateFCMTokenInLambda(
  //           magentoUserId: magentoUser.id.toString(),
  //           updateFcmTokenInLambdaRequest:
  //               UpdateFcmTokenInLambdaRequest(fcmToken: fcmToken))
  //       .then((state) {
  //     if (state is SuccessState) {
  //       logNesto("updated FCMTokenInLambda with fcm token $fcmToken");
  //     } else if (state is ErrorState) {
  //       logNestoCustom(message: state.msg, logType: LogType.error);
  //     }
  //   });
  // }

  // Future registerFCMTokenInLambda(bool isremoveToken) async {
  //   logNesto(
  //       "registerFCMTokenInLambda is called" + firebaseCloudMessaging.fcmToken);
  //   //Rif (magentoUser == null) await fetchMagentoUser();
  //   await apiService
  //       .registerFCMTokenInLambda(
  //           registerFcmTokenInLambdaRequest: RegisterFcmTokenInLambdaRequest(
  //               customerId: magentoUser.id.toString(),
  //               customerFirstName: magentoUser.firstName,
  //               customerLastName: magentoUser.lastName,
  //               customerEmail: magentoUser.emailAddress,
  //               customerPhoneNumber: magentoUser.phoneNumber,
  //               customerFcmToken:
  //                   isremoveToken ? '' : firebaseCloudMessaging.fcmToken))
  //       .then((state) async {
  //     if (state is SuccessState) {
  //       print("registerFCMTokenInLambda Success");
  //       SharedPreferences fcmToken = await SharedPreferences.getInstance();
  //       await fcmToken.setString('fcmToken', '');
  //       if (isremoveToken) {
  //         logout();
  //       }
  //       logNesto(
  //           "registered FCMTokenInLambda with fcm token ${firebaseCloudMessaging.fcmToken}");
  //     } else if (state is ErrorState) {
  //       if (isremoveToken) {
  //         logOutUserFailed = true;
  //         notifyListeners();
  //       }
  //     }
  //   });
  // }

  Future registerFcmTokenInLambda({bool removeToken}) async {
    var state = await apiService.registerFCMTokenInLambda(
      registerFcmTokenInLambdaRequest: RegisterFcmTokenInLambdaRequest(
          customerId: magentoUser.id.toString(),
          customerFirstName: magentoUser.firstName,
          customerLastName: magentoUser.lastName,
          customerEmail: magentoUser.emailAddress,
          customerPhoneNumber: magentoUser.phoneNumber,
          customerFcmToken: removeToken ? "" : firebaseCloudMessaging.fcmToken),
    );
    if (state is SuccessState) {
      print("======================>");
      print(
          "REGISTER_FCM_LAMBDA: ${removeToken ? "" : firebaseCloudMessaging.fcmToken}");
      print("<=======================");

      SharedPreferences _sharedPref = await SharedPreferences.getInstance();
      await _sharedPref.setString(
          'fcmToken', removeToken ? "" : firebaseCloudMessaging.fcmToken);
      if (removeToken) {
        await logout();
      }
    } else {
      throw Exception(strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  Future fetchMagentoUser() async {
    logNesto("fetchMagentoUser is called");

    try {
      States state = await apiService.fetchMagentoUser(
          headerModel: HeaderModel(authorization: "Bearer ${getAuthToken()}"));
      if (state is SuccessState) {
        FetchUserResponse fetchUserResponse = state.value;

        List<CustomAttributes> customAttributesArray = [];

        for (int i = 0; i < fetchUserResponse.customAttributes.length; i++) {
          customAttributesArray.add(CustomAttributes(
              attributeCode:
                  fetchUserResponse.customAttributes[i].attributeCode,
              value: fetchUserResponse.customAttributes[i].value));
        }

        for (int i = 0; i < customAttributesArray.length; i++) {
          if (customAttributesArray[i].attributeCode == "inaam_code") {
            inaamCode = customAttributesArray[i].value;
          }
        }
        logNesto(
            "inaam code from fetch magento user function(authProvider) is " +
                inaamCode.toString());

        List<dynamic> addressData = fetchUserResponse.addresses;

        List<Address> loadedAddress = [];
        addressData.forEach((element) {
          String streetAddress = "";
          (element["street"] as List<dynamic>).forEach((valueToAppend) {
            if (streetAddress == "") {
              streetAddress = streetAddress + valueToAppend.toString();
            } else {
              streetAddress = streetAddress + "\n" + valueToAppend.toString();
            }
          });

          double _latitude = -1, _longitude = -1;
          String _location;
          List<dynamic> customAttribList = element["custom_attributes"] ?? [];

          customAttribList.forEach((customAttributeElement) {
            if (customAttributeElement["attribute_code"] == "latitude") {
              _latitude = double.parse(customAttributeElement["value"]);
            } else if (customAttributeElement["attribute_code"] ==
                "longitude") {
              _longitude = double.parse(customAttributeElement["value"]);
            } else if (customAttributeElement["attribute_code"] == "location") {
              _location = customAttributeElement["value"];
            }
          });

          loadedAddress.add(Address(
              //Email address same as user's
              email: fetchUserResponse.email,
              id: element["id"],
              name: element["firstname"],
              city: element["city"],
              region: element["region"]["region"],
              postCode: element["postcode"],
              street: streetAddress,
              telephone: element["telephone"],
              countryId: element["country_id"],
              regionCode: (element["region"]["region_id"]).toString(),
              latitude: _latitude,
              longitude: _longitude,
              location: _location));
        });

        loadedAddress = loadedAddress.reversed.toList();
        //Get user's mobile number
        String userMobileNumber = "";
        String nationality;
        for (int i = 0; i < fetchUserResponse.customAttributes.length; i++) {
          if (fetchUserResponse.customAttributes[i].attributeCode ==
              "mobile_number") {
            userMobileNumber = fetchUserResponse.customAttributes[i].value;
          }
          if (fetchUserResponse.customAttributes[i].attributeCode ==
              "nationality") {
            nationality = fetchUserResponse.customAttributes[i].value;
          }
        }

        //log(fetchUserResponse.gender.toString(), name: 'fetchMag Gender');
        logNestoCustom(
            message: "fetchMag Gender: " + fetchUserResponse.gender.toString(),
            logType: LogType.debug);

        magentoUser = User(
            id: fetchUserResponse.id,
            gender: fetchUserResponse.gender == null
                ? Gender.none
                : fetchUserResponse.gender == 0
                    ? Gender.female
                    : Gender.male ?? Gender.none,
            phoneNumber: userMobileNumber,
            nationality: nationality,
            emailAddress: fetchUserResponse.email,
            createdAt: fetchUserResponse.createdAt,
            firstName: fetchUserResponse.firstname,
            lastName: fetchUserResponse.lastname,
            addresses: loadedAddress,
            dob: fetchUserResponse.dob == null
                ? ''
                : fetchUserResponse.dob ?? '');
        //
        notifyListeners();
        //PASS FCM TOKEN TO LAMBDA
        //logNesto("REGISTER FCM FLAG:" + registerFCMFlag.toString());
        SharedPreferences _sharedPref = await SharedPreferences.getInstance();
        String _fcmToken;

        try {
          _fcmToken = _sharedPref.getString('fcmToken') ?? "";
        } catch (e) {
          _fcmToken = "";
        }

        print("=========================>");
        print("FCM TOKEN: $_fcmToken");
        print("<=========================");

        bool isTokenRegNeeded =
            _fcmToken != firebaseCloudMessaging?.fcmToken ?? "";

        print("=========================>");
        print("IS_FCM_TOKEN_REG_NEEDED: $isTokenRegNeeded");
        print("<=========================");

        if (isTokenRegNeeded ?? false) {
          SharedPreferences fcmToken = await SharedPreferences.getInstance();
          await fcmToken.setString('fcmToken', firebaseCloudMessaging.fcmToken);
          await registerFcmTokenInLambda(removeToken: false);
        }

        //await updateFCMTokenInLambda();

        //firebase analytics logging
        firebaseAnalytics.logSetUserProperties(
            id: magentoUser?.id.toString(),
            env: ENV,
            gender: describeEnum(magentoUser?.gender));

        hideLoader();
      } else if (state is ErrorState) {
        logNestoCustom(message: state.msg, logType: LogType.error);
      }
    } catch (e) {
      logNestoCustom(
          message:
              (e?.message ?? strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION),
          logType: LogType.error);
    }
  }

  bool showInaamRetryButton = false;
  bool showInaamRetryLoading = true;
  set setShowInaamRetryLoading(value) {
    showInaamRetryLoading = value;
    notifyListeners();
  }

  set setShowInaamRetryButton(value) {
    showInaamRetryButton = value;
    notifyListeners();
  }

  bool get getShowInaamRetryLoading {
    return showInaamRetryLoading;
  }

  bool get getshowInaamRetryButton {
    return showInaamRetryButton;
  }

  Future getInaamPointsCall({bool shouldNotify}) async {
    if (inaamCode != null && inaamCode != "" && inaamCode != "NULL") {
      showInaamRetryLoading = true;
      showInaamRetryButton = false;
      if (shouldNotify ?? true) {
        notifyListeners();
      }
      logNesto(
          "get Inaam Points Called with inaam code: " + inaamCode.toString());
      String phoneNumber = magentoUser.phoneNumber;
      String phoneNumberFormatted;
      if (phoneNumber.startsWith("+91")) {
        phoneNumberFormatted = phoneNumber.replaceRange(0, 3, "");
      } else if (phoneNumber.startsWith("+971")) {
        phoneNumberFormatted = phoneNumber.replaceRange(0, 4, "");
      }

      await apiService
          .getInaamPoints(mobileNumber: phoneNumberFormatted)
          .then((state) {
        if (state is SuccessState) {
          GetInaamPointsResponse getInaamPointsResponse = state.value;
          logNestoCustom(
              message: getInaamPointsResponse.toJson().toString(),
              logType: LogType.warning);
          inaamPoints = double.parse(getInaamPointsResponse.total.toString());
          var lifeTimePoints = getInaamPointsResponse.lifetimePoint ?? 0.0;
          inaamPointsLifeTime = double.tryParse(lifeTimePoints.toString());
          logNesto("inaam points " + inaamPoints.toString());
          logNesto("inaam points life time " + inaamPointsLifeTime.toString());
          showInaamRetryLoading = false;
          showInaamRetryButton = false;
          notifyListeners();
        } else if (state is ErrorState) {
          showInaamRetryLoading = false;
          showInaamRetryButton = true;
          notifyListeners();
          logNestoCustom(message: state.msg, logType: LogType.error);
        }
      });
    }
  }

  Future sendMobileNumberToMagento() {
    logNesto("sendMobileNumberToMagento is called");

    return apiService
        .sendMobileNumberToMagento(
            sendMobileNumberToMagentoRequest:
                SendMobileNumberToMagentoRequest(mobilenumber: phoneNumber))
        .then((state) {
      if (state is SuccessState) {
        SendMobileNumberToMagentoResponse sendMobileNumberToMagentoResponse =
            state.value;
        logNesto("mobile number " + phoneNumber.toString());
        logNesto("sendMobileNumberToMagentoResponse " +
            sendMobileNumberToMagentoResponse.message.toString());
        canUserProceedToOTPScreen = true;
        notifyListeners();
      } else if (state is ErrorState) {
        isAuthError = true;
        errorMessage = state.msg;
        logNestoCustom(
            message: "error is " + state.msg, logType: LogType.error);
        notifyListeners();
      }
    });
  }

  Future verifyOtpMagento(
      {OtpVerificationRequest otpVerificationRequest}) async {
    return apiService
        .verifyOtpMagento(otpVerificationRequest: otpVerificationRequest)
        .then((state) {
      if (state is SuccessState) {
        OtpVerificationResponse otpVerificationResponse = state.value;
        otpVerifiedStatus = otpVerificationResponse.verify;
        if (otpVerificationResponse.registerCustomer != null) {
          firebaseAnalytics.logOtpVerificationSuccess();
          bool registerCustomer = otpVerificationResponse.registerCustomer;
          //Customer is not registered,Move him to the sign up page
          if (!registerCustomer) {
            //doesUserNeedsToBeRegistered = true;
            shouldUserBeRegisteredDuringOTPVerification = true;
          } else {
            shouldUserBeRegisteredDuringOTPVerification = false;
            _tempToken = otpVerificationResponse.token.toString();
            _tempLambdaToken =
                otpVerificationResponse.lambdaCustomerToken.toString();
          }
        }
        notifyListeners();
      } else if (state is ErrorState) {
        logNestoCustom(
            message: "Error occurred in verify otp call magento " + state.msg,
            logType: LogType.error);
      }
    });
  }

  Future resendOTP() {
    logNesto("resendOTP is called");

    return apiService
        .sendMobileNumberToMagento(
            sendMobileNumberToMagentoRequest:
                SendMobileNumberToMagentoRequest(mobilenumber: phoneNumber))
        .then((state) {
      if (state is SuccessState) {
        SendMobileNumberToMagentoResponse sendMobileNumberToMagentoResponse =
            state.value;
        showResendOTPTimer();
        notifyListeners();
      } else if (state is ErrorState) {
        isAuthError = true;
        errorMessage = state.msg;
        notifyListeners();
        logNestoCustom(message: state.msg, logType: LogType.error);
      }
    });
  }

  Future registerNewUserInMagento() async {
    States state = await apiService.registerNewUserInMagento(
        registerNewUserMagentoRequest: RegisterNewUserMagentoRequest(
            customer: Customer(
                email: email,
                name: userFullName,
                mobilenumber: phoneNumber,
                otp: int.parse(otp))));
    if (state is SuccessState) {
      RegisterNewUserMagentoResponse registerNewUserMagentoResponse =
          state.value;

      setAuthToken(registerNewUserMagentoResponse.token);
      setLambdaCustomerToken(
          registerNewUserMagentoResponse.lambdaCustomerToken);

      isRegistrationComplete = true;
      registerFCMFlag = true;
      logNesto("registerNewUserInMagento auth token" +
          registerNewUserMagentoResponse.token.toString());
      notifyListeners();
    } else if (state is ErrorState) {
      isAuthError = true;
      errorMessage = state.msg;
      logNesto("registerNewUserInMagento error " + state.msg.toString());

      //analytics logging.
      firebaseAnalytics.logSignupFailure();

      notifyListeners();
      logNestoCustom(message: state.msg, logType: LogType.error);
    }
  }

  Future saveTempAuthTokenAsAuthToken() async {
    logNesto("SAVING TEMP TOKEN:" + _tempToken);
    logNesto("SAVING TEMP LAMBDA TOKEN:" + _tempLambdaToken);
    setAuthToken(_tempToken);
    setLambdaCustomerToken(_tempLambdaToken);
    isRegistrationComplete = true;
    registerFCMFlag = false;
    notifyListeners();
  }

  logout() async {
    //Clear auth token in shared preference
    clearAuthToken();
    clearLambdaToken();
    clearMagentoUser();

    //for rate my app check
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.remove('firstOrderPlaced');
    rateMyAppShown = false;
    // logOutUser = true;
    notifyListeners();
  }

  // Future removeFCMTokenInLambda() async {
  //   logNesto("removeFCMTokenInLambda is called");
  //   await Repository()
  //       .registerFCMTokenInLambda(
  //           registerFcmTokenInLambdaRequest: RegisterFcmTokenInLambdaRequest(
  //               customerId: magentoUser.id.toString(),
  //               customerFirstName: magentoUser.firstName,
  //               customerLastName: magentoUser.lastName,
  //               customerEmail: magentoUser.emailAddress,
  //               customerPhoneNumber: magentoUser.phoneNumber,
  //               customerFcmToken: ''))
  //       .then((state) {
  //     if (state is SuccessState) {
  //       logout();
  //       logNesto("Removed FCMTokenInLambda with fcm token ");
  //     } else if (state is ErrorState) {
  //       logOutUserFailed = true;
  //       notifyListeners();
  //     }
  //   });
  //   //Route to splash screen,by making this var true
  // }

  Future addToAddresses(Address address, BuildContext context) async {
    if (true) {
      //magentoUser.addAddressToUser(address);
      await addNewAddressToMagento(address, context);
    }
    notifyListeners();
    return;
  }

  bool isAddressPresentInAddressBook(Address address) {
    magentoUser.addresses.forEach((element) {
      if (address.street == element.street) {
        return true;
      }
    });
    return false;
  }

  Future addNewAddressToMagento(Address address, BuildContext context) async {
    logNesto("addNewAddressToMagento is called");

    // //Generate address json list
    List<ShippingAddress> addressJSONList = [];

    List<Address> addressesToSend = [];
    addressesToSend.addAll(magentoUser.addresses);

    addressesToSend.add(address);

    addressesToSend.forEach((element) {
      ShippingAddress item = ShippingAddress(
          customer_id: magentoUser.id,
          countryId: "AE",
          region: element.region,
          street: element.street,
          postCode: element.postCode,
          city: element.city,
          name: element.name,
          telephone: element.telephone,
          email: element.email,
          latitude: element.latitude,
          longitude: element.longitude,
          location: element.location);
      addressJSONList.add(item);
    });

    var body = jsonEncode({
      "customer": {
        "email": magentoUser.emailAddress,
        "firstname": magentoUser.firstName,
        "lastname": ".",
        "website_id": 1,
        "addresses": addressJSONList,
        "custom_attributes": [
          {"attribute_code": "mobile_number", "value": magentoUser.phoneNumber},
          {"attribute_code": "nationality", "value": magentoUser.nationality}
        ]
      }
    });

    await apiService
        .addNewAddressToMagento(
            headerModel: HeaderModel(authorization: "Bearer ${getAuthToken()}"),
            body: body)
        .then((state) {
      if (state is SuccessState) {
        magentoUser.addAddressToUser(address);
        Navigator.pop(context, true);
        notifyListeners();
      } else if (state is ErrorState) {
        showError(
            context,
            state.msg ==
                    strings.STREET_ADDRESS_CANNOT_CONTAIN_MORE_THAN_THREE_LINES
                ? state.msg.toString()
                : strings.SOMETHING_WENT_WRONG);
        logNestoCustom(message: state.msg, logType: LogType.error);
      }
    });
  }

  Future updateAddressInMagento(
      int index, Address address, BuildContext context) async {
    logNestoCustom(
        message: "updateAddressInMagento is called", logType: LogType.verbose);

    // //Generate address json list
    List<ShippingAddress> addressJSONList = [];

    List<Address> addressesToSend = [];
    addressesToSend.addAll(magentoUser.addresses);
    addressesToSend.removeAt(index);

    addressesToSend.add(address);

    logNesto("ADDRESSES TO SEND LENGTH:" + addressesToSend.length.toString());

    addressesToSend.forEach((element) {
      ShippingAddress item = ShippingAddress(
          customer_id: magentoUser.id,
          countryId: "AE",
          region: element.region,
          street: element.street,
          postCode: element.postCode,
          city: element.city,
          name: element.name,
          telephone: element.telephone,
          email: element.email,
          latitude: element.latitude,
          longitude: element.longitude,
          location: element.location);
      addressJSONList.add(item);
    });

    var body = jsonEncode({
      "customer": {
        "email": magentoUser.emailAddress,
        "firstname": magentoUser.firstName,
        "lastname": ".",
        "website_id": 1,
        "addresses": addressJSONList,
        "custom_attributes": [
          {"attribute_code": "mobile_number", "value": magentoUser.phoneNumber},
          {"attribute_code": "nationality", "value": magentoUser.nationality}
        ]
      }
    });

    logNestoCustom(message: body, logType: LogType.error);

    await apiService
        .addNewAddressToMagento(
            headerModel: HeaderModel(authorization: "Bearer ${getAuthToken()}"),
            body: body)
        .then((state) {
      if (state is SuccessState) {
        magentoUser.addresses.removeAt(index);
        magentoUser.addAddressToUser(address);
        Navigator.of(context).maybePop();
        notifyListeners();
      } else if (state is ErrorState) {
        showError(
            context,
            state.msg ==
                    strings.STREET_ADDRESS_CANNOT_CONTAIN_MORE_THAN_THREE_LINES
                ? state.msg.toString()
                : strings.SOMETHING_WENT_WRONG);
        logNestoCustom(message: state.msg, logType: LogType.error);
      }
    });
  }

  Future deleteAddressesFromMagento(int index) async {
    logNesto("updateAddressesToMagento is called");

    // //Generate address json list
    List<ShippingAddress> addressJSONList = [];

    List<Address> addressesToSend = [];
    addressesToSend.addAll(magentoUser.addresses);
    addressesToSend.removeAt(index);

    addressesToSend.forEach((element) {
      ShippingAddress item = ShippingAddress(
          customer_id: magentoUser.id,
          countryId: "AE",
          region: element.region,
          street: element.street,
          postCode: element.postCode,
          city: element.city,
          name: element.name,
          telephone: element.telephone,
          email: element.email,
          latitude: element.latitude,
          longitude: element.longitude,
          location: element.location);
      addressJSONList.add(item);
    });

    await apiService
        .addNewAddressToMagento(
            headerModel: HeaderModel(authorization: "Bearer ${getAuthToken()}"),
            body: ({
              "customer": {
                "email": magentoUser.emailAddress,
                "firstname": magentoUser.firstName,
                "lastname": ".",
                "website_id": 1,
                "addresses": addressJSONList,
                "custom_attributes": [
                  {
                    "attribute_code": "mobile_number",
                    "value": magentoUser.phoneNumber
                  },
                  {
                    "attribute_code": "nationality",
                    "value": magentoUser.nationality
                  }
                ]
              }
            }))
        .then((state) {
      if (state is SuccessState) {
        magentoUser.addresses.removeAt(index);
        notifyListeners();
      } else if (state is ErrorState) {
        logNestoCustom(message: state.msg, logType: LogType.error);
      }
    });
  }

  Future<void> saveLocationToSharedPreferences(
      {String placeName, double lat, double ln}) async {
    SharedPreferences encryptedSharedPreferences =
        await SharedPreferences.getInstance();
    await encryptedSharedPreferences.setDouble('userlat', lat);
    await encryptedSharedPreferences.setDouble('userlng', ln);
    await encryptedSharedPreferences.setString('userlocationname', placeName);
  }

  String getFormattedAddress(Address address) {
    String formattedAddress = "";

    formattedAddress =
        address.name + "\n" + address.street + "\n" + address.city + ", UAE";

    return formattedAddress;
  }

  Future<bool> editUserProfile(payload, {bool signup = false}) async {
    final url = MAGENTO_BASE_URL + "/$storeCode/V1" + '/customers/me';
    bool success = false;
    //log('url ====> $url', name: 'editUserProfile');
    //log('payLoad ====> ${payload.toString()}', name: 'editUserProfile');
    //logNestoCustom(message: "url ====> $url ", logType: LogType.debug);
    logNestoCustom(
        message: "payLoad ====> ${payload.toString()}", logType: LogType.error);

    Map<String, String> headers = {
      "Authorization": "Bearer ${getAuthToken()}",
      "Content-Type": "application/json"
    };
    //log("headers: $headers", name: 'editUserProfile');
    //logNestoCustom(message: "headers: $headers", logType: LogType.debug);

    var encodedJson = json.encode(payload);
    await apiService
        .editUserProfile(
            headerModel: HeaderModel(
              authorization: "Bearer ${getAuthToken()}",
            ),
            body: encodedJson)
        .then((state) async {
      if (state is SuccessState) {
        EditUserProfileResponse editUserProfileProfile = state.value;
        logNesto(editUserProfileProfile.toJson().toString());
        await fetchMagentoUser();
        notificationServices.showSuccessNotification(strings.PROFILE_UPDATED);
        success = true;
        if (signup ?? false) {
          firebaseAnalytics.logRegister(
              method: "mobile", userId: magentoUser?.id);
        }
      } else if (state is ErrorState) {
        //log(state.toString(), name: 'editUserProfile');
        logNestoCustom(message: state.msg, logType: LogType.debug);
        notificationServices
            .showErrorNotification(strings.INTERNAL_SERVER_TRY_AGAIN);
      }
    });
    return success;
  }

  bool rateMyAppShown = false;

  void syncHomepageLoaderImage(String url) async {
    try {
      Dio dio = Dio(BaseOptions(
        connectTimeout: 25000,
        receiveTimeout: 25000,
      ));
      String _url = LAMBDA_BASE_URL_MINIMUM + "/ecomm/splash-image";
      var response = await dio.request(
        _url,
        options: Options(method: 'GET'),
      );
      var decodedResponse =
          json.decode(response.toString()) as Map<String, dynamic>;
      String _homepageLoaderImageUrl = decodedResponse["data"]["image"];
      if (_homepageLoaderImageUrl != null && _homepageLoaderImageUrl != url) {
        logNestoCustom(message: "Sync happened", logType: LogType.error);
        setHomePageLoadingImageURL(_homepageLoaderImageUrl);
      }
    } catch (e) {
      print(e);
      logNestoCustom(
          message: "Could not update homepage loader image",
          logType: LogType.error);
    }
  }
}
