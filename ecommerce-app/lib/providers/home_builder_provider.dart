import 'dart:async';

import 'package:Nesto/models/home_builder/home_model.dart';
import 'package:Nesto/models/home_builder/home_page_section.dart';
import 'package:Nesto/services/api_service.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/cupertino.dart';

class MultiHomePageProvider with ChangeNotifier {
  List<HomePageModel> allPageData = [];
  bool isHomePageLoading = false;
  bool isHomePageError = false;
  String selectedPageId = '';

  Future getAllHomePageData() async {
    isHomePageLoading = true;
    allPageData = [];
    // notifyListeners();
    try {
      var decodedResponse =
          await apiService.fetchConsolidatedInitialDataNew(storeId: storeId);

      // print('kkk --- $decodedResponse');

      var data = decodedResponse['data'] as Map<String, dynamic>;
      var homeConsoleData = data["pages"] as List<dynamic>;
      homeConsoleData.forEach((eachPage) {
        allPageData.add(
          HomePageModel.fromJson(eachPage),
        );
        print('page added');
      });
      isHomePageError = false;
      isHomePageLoading = false;
      notifyListeners();
    } catch (e) {
      logNesto('Got error in multi home page - 1 $e');
      isHomePageError = true;
      isHomePageLoading = false;
      notifyListeners();
    }
  }

  List<HomePageSection> get dynamicHomepageWidgets {
    if (homeData != null) {
      return homeData.pageSections;
    }
    return [];
  }

  HomePageModel get homeData {
    return allPageData.firstWhere((element) => element.type == 'HOME',
        orElse: () {
      return null;
    });
  }

  List<HomePageSection> get categoryPageWidgets {
    if (categoryPage != null) {
      return categoryPage.pageSections;
    }
    return [];
  }

  HomePageModel get categoryPage {
    return allPageData.firstWhere((element) => element.id == selectedPageId,
        orElse: () {
      return null;
    });
  }

  List<HomePageSection> get dealsPageWidgets {
    print('dealsPage - $dealsPage');
    if (dealsPage != null) {
      return dealsPage.pageSections;
    }
    return [];
  }

  HomePageModel get dealsPage {
    return allPageData.firstWhere((element) => element.type == 'DEALS',
        orElse: () {
      return null;
    });
  }
}
