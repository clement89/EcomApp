import 'dart:async';
import 'dart:convert';

import 'package:Nesto/dio/models/add_new_address_to_magento_response.dart';
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
import 'package:Nesto/dio/models/register_fcm_token_response.dart';
import 'package:Nesto/dio/models/register_new_user_magento_request.dart';
import 'package:Nesto/dio/models/register_new_user_magento_response.dart';
import 'package:Nesto/dio/models/sample_call_request_model.dart';
import 'package:Nesto/dio/models/send_mobile_number_to_magento_request.dart';
import 'package:Nesto/dio/models/send_mobile_number_to_magento_response.dart';
import 'package:Nesto/dio/models/update_fcm_in_lambda_request.dart';
import 'package:Nesto/dio/models/update_fcm_in_lambda_response.dart';
import 'package:Nesto/dio/utils/dio_client.dart';
import 'package:Nesto/dio/utils/state.dart';
import 'package:Nesto/dio/utils/urls.dart';
import 'package:Nesto/service_locator.dart';
import 'package:Nesto/utils/util.dart';
import 'package:dio/dio.dart';

final ApiService apiService = locator.get<ApiService>();

class ApiService {
  DioClient _dioClient = DioClient();

  Future initialise() async {
    try {
      await _dioClient.initClient();
    } catch (e) {
      logNestoCustom(message: e, logType: LogType.error);
    }
  }

  ///  sample call
  Future<States> sampleCall(SampleRequest sampleRequest) async {
    try {
      final response =
          await _dioClient.post(url: "baseUrl", data: sampleRequest);
      if (response.statusCode == 200) {
        return States<String>.success(response.statusMessage);
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  Future fetchConsolidatedInitialDataNew({int storeId}) async {
    // try {
    //   String url =
    //       'https://stag-homepage-builder.nesto.shop/api/v1/template/store/$sapWebsiteId';
    //   var headers = {
    //     'Authorization': 'Bearer hbs',
    //   };
    //   var response = await api.getData(url: url, headers: headers);
    //   return response;
    // } catch (e) {
    //   throw e;
    // }

    print(
        'Home_builder url -- ${'https://api-hbs.nesto.shop/api/v1/template/store/$sapWebsiteId'}');

    //https://api-hbs.nesto.shop sapWebsiteId
    try {
      // String url = 'https://api-hbs.nesto.shop/api/v1/template/store/9051';
      String url =
          'https://api-hbs.nesto.shop/api/v1/template/store/$sapWebsiteId';
      final response = await _dioClient.get(url: url);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  ///  check if User Area Serviceable or not
  Future<States> checkIsUserAreaServiceable(
      {CheckIfUserAreaServiceableRequest
          checkIfUserAreaServiceableRequest}) async {
    try {
      final response = await _dioClient.post(
          url: LAMBDA_BASE_URL + "/point-in-polygon?version=2",
          data: jsonEncode({
            "point": {
              "lat": checkIfUserAreaServiceableRequest.userLat,
              "long": checkIfUserAreaServiceableRequest.userLn
            }
          }));
      logNesto("POLYGON CHECK RESPONSE:" + response.toString());
      if (response.statusCode == 200) {
        return States<CheckIfUserAreaServiceableResponse>.success(
            CheckIfUserAreaServiceableResponse.fromJson(response.data));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  ///  check if Address is in Current Store Id or not
  Future<States> checkIfAddressIsInCurrentStoreId(
      {CheckIIfAddressIsInCurrentStoreIdRequest
          checkIIfAddressIsInCurrentStoreIdRequest}) async {
    try {
      final response = await _dioClient.post(
          url: LAMBDA_BASE_URL + "/point-in-polygon?version=2",
          data: jsonEncode({
            "point": {
              "lat": checkIIfAddressIsInCurrentStoreIdRequest.userLat,
              "long": checkIIfAddressIsInCurrentStoreIdRequest.userLn
            }
          }));

      logNesto(
        LAMBDA_BASE_URL + "/point-in-polygon?version=2",
      );
      logNesto("POLYGON CHECK RESPONSE:" + response.toString());
      if (response.statusCode == 200) {
        return States<CheckIfAddressIsInCurrentStoreIdResponse>.success(
            CheckIfAddressIsInCurrentStoreIdResponse.fromJson(response.data));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  ///  update FCM token in lambda
  Future<States> updateFCMTokenInLambda(
      {String magentoUserId,
      UpdateFcmTokenInLambdaRequest updateFcmTokenInLambdaRequest}) async {
    try {
      final response = await _dioClient.post(
          url: LAMBDA_BASE_URL + '/update-customer-fcm-token/' + magentoUserId,
          data: jsonEncode(
              {"customer_fcm_token": updateFcmTokenInLambdaRequest.fcmToken}));

      if (response.statusCode == 200) {
        return States<UpdateFcmTokenInLambdaResponse>.success(
            UpdateFcmTokenInLambdaResponse.fromJson(response.data));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  ///  register FCM Token In Lambda
  Future<States> registerFCMTokenInLambda(
      {RegisterFcmTokenInLambdaRequest registerFcmTokenInLambdaRequest}) async {
    try {
      var queryParam = await getQueryParams() ?? "";
      final response = await _dioClient.post(
          url: LAMBDA_BASE_URL + '/add-customer' + queryParam,
          header: HeaderModel(accessToken: getLambdaToken()),
          data: jsonEncode({
            "customer_id": registerFcmTokenInLambdaRequest.customerId,
            "customer_first_name":
                registerFcmTokenInLambdaRequest.customerFirstName,
            "customer_last_name":
                registerFcmTokenInLambdaRequest.customerLastName,
            "customer_email": registerFcmTokenInLambdaRequest.customerEmail,
            "customer_phone_number":
                registerFcmTokenInLambdaRequest.customerPhoneNumber,
            "customer_fcm_token":
                registerFcmTokenInLambdaRequest.customerFcmToken
          }));
      if (response.statusCode == 200) {
        return States<RegisterFcmTokenInLambdaResponse>.success(
            RegisterFcmTokenInLambdaResponse.fromJson(response.data));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  ///  fetch magento user
  Future<States> fetchMagentoUser({HeaderModel headerModel}) async {
    try {
      final response = await _dioClient.get(
          url: MAGENTO_BASE_URL + "/V1" + '/customers/me', header: headerModel);
      if (response.statusCode == 200) {
        return States<FetchUserResponse>.success(
            FetchUserResponse.fromJson(response.data));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  /// get inaam points
  Future<States> getInaamPoints({String mobileNumber}) async {
    try {
      final response = await _dioClient.get(
          url: MAGENTO_BASE_URL +
              "/$storeCode/V1" +
              '/inaam/user_point/' +
              mobileNumber);
      if (response.statusCode == 200) {
        return States<GetInaamPointsResponse>.success(
            GetInaamPointsResponse.fromJson(json.decode(response.data)));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  ///  send mobile number to magento
  Future<States> sendMobileNumberToMagento(
      {SendMobileNumberToMagentoRequest
          sendMobileNumberToMagentoRequest}) async {
    try {
      final response = await _dioClient.post(
          url: MAGENTO_BASE_URL + "/$storeCode/V1" + "/registerauthtw/",
          data: jsonEncode({
            "mobilenumber": sendMobileNumberToMagentoRequest.mobilenumber,
            "source": _dioClient.packageName,
            "app_name": _dioClient.appName,
            "build_number": _dioClient.buildNumber,
            "app_version": _dioClient.version
          }));
      if (response.statusCode == 200) {
        return States<SendMobileNumberToMagentoResponse>.success(
            SendMobileNumberToMagentoResponse.fromJson(response.data[0]));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  /// verify otp
  Future<States> verifyOtpMagento(
      {OtpVerificationRequest otpVerificationRequest}) async {
    try {
      final response = await _dioClient.post(
          url: MAGENTO_BASE_URL + "/$storeCode/V1" + "/registerverify/",
          data: jsonEncode({
            "customer": {
              "mobilenumber":
                  otpVerificationRequest.customer.mobilenumber.toString(),
              "otp": otpVerificationRequest.customer.otp.toString(),
              "source": _dioClient.packageName,
              "app_name": _dioClient.appName,
              "build_number": _dioClient.buildNumber,
              "app_version": _dioClient.version
            }
          }));
      if (response.statusCode == 200) {
        return States<OtpVerificationResponse>.success(
            OtpVerificationResponse.fromJson(response.data[0]));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  ///  register new user to magento
  Future<States> registerNewUserInMagento(
      {RegisterNewUserMagentoRequest registerNewUserMagentoRequest}) async {
    try {
      final response = await _dioClient.post(
          url: MAGENTO_BASE_URL + "/$storeCode/V1" + "/registertw/",
          data: jsonEncode({
            'customer': {
              'email': registerNewUserMagentoRequest.customer.email,
              'name': registerNewUserMagentoRequest.customer.name,
              'mobilenumber':
                  registerNewUserMagentoRequest.customer.mobilenumber,
              'otp': registerNewUserMagentoRequest.customer.otp,
              "source": _dioClient.packageName,
              "app_name": _dioClient.appName,
              "build_number": _dioClient.buildNumber,
              "app_version": _dioClient.version
            },
          }));
      if (response.statusCode == 200) {
        return States<RegisterNewUserMagentoResponse>.success(
            RegisterNewUserMagentoResponse.fromJson(response.data[0]));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  ///  register new address to magento
  Future<States> addNewAddressToMagento(
      {HeaderModel headerModel, final body}) async {
    try {
      final response = await _dioClient.put(
          url: MAGENTO_BASE_URL + '/$storeCode/V1' + '/customers/me',
          data: body,
          header: headerModel);
      if (response.statusCode == 200) {
        return States<AddNewAddressToMagentoResponse>.success(
            AddNewAddressToMagentoResponse.fromJson(response.data));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }

  /// edit user profile
  Future<States> editUserProfile({HeaderModel headerModel, body}) async {
    try {
      final response = await _dioClient.put(
          url: MAGENTO_BASE_URL + "/$storeCode/V1" + '/customers/me',
          data: body,
          header: headerModel);
      if (response.statusCode == 200) {
        return States<EditUserProfileResponse>.success(
            EditUserProfileResponse.fromJson(response.data));
      } else {
        String errorMessage = response.statusMessage;
        return States<String>.error(errorMessage);
      }
    } catch (e) {
      return States<String>.error(DioExceptions.fromDioError(e).toString());
    }
  }
}

class DioExceptions implements Exception {
  String message;

  DioExceptions.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        {
          // to do if request to API server was cancelled
          message = dioError.message;
        }
        break;
      case DioErrorType.connectTimeout:
        {
          //to do if connection timeout with API server
          message = dioError.message;
        }
        break;
      case DioErrorType.other:
        {
          //to do if other error
          if (dioError.message.contains("SocketException")) {
            message = "Please check your network connection";
          } else
            message = "Something went wrong";
        }
        break;
      case DioErrorType.receiveTimeout:
        {
          //to do if receive timeout in connection with API server
          message = dioError.message;
        }
        break;
      case DioErrorType.response:
        {
          message = _handleError(
              dioError.response.statusCode, dioError.response.data);
        }
        break;
      case DioErrorType.sendTimeout:
        {
          //to do if send timeout in connection with API server
          message = dioError.message;
        }
        break;
      default:
        {
          //to do if something went wrong;
          message = dioError.message;
        }
        break;
    }
  }

  String _handleError(int statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        {
          //if bad request
          return error["message"];
        }
      case 404:
        {
          return error["message"];
        }
      case 500:
        {
          //to do if internal server error
          return error["message"];
        }
      default:
        {
          //to do if something went wrong
          return error["message"];
        }
    }
  }

  @override
  String toString() => message;
}
