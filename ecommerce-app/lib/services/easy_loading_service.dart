
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:Nesto/service_locator.dart';

final EasyLoadingService easyLoadingService = locator.get<EasyLoadingService>();

class EasyLoadingService{
  bool _easyLoading = false;

  set easyLoadingStatusUpdate(value){
    _easyLoading = value;
    if(value){
      EasyLoading.show();
    }else if(!value){
      EasyLoading.dismiss();
    }
  }

  Future<void> showEasyLoading()async{
    easyLoadingStatusUpdate = true;
  }

  Future<void> hideEasyLoading()async{
    easyLoadingStatusUpdate = false;
  }

  bool get easyLoadingStatus{
    return _easyLoading;
  }
}