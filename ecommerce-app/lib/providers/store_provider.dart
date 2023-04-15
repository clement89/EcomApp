import 'dart:convert';
import 'dart:math';

import 'package:Nesto/dio/utils/urls.dart';
import 'package:Nesto/models/address.dart';
import 'package:Nesto/models/dynamic_home_page/all_categories_section.dart';
import 'package:Nesto/models/dynamic_home_page/buy_from_cart_section.dart';
import 'package:Nesto/models/dynamic_home_page/category_header.dart';
import 'package:Nesto/models/dynamic_home_page/deal_card.dart';
import 'package:Nesto/models/dynamic_home_page/deals_section.dart';
import 'package:Nesto/models/dynamic_home_page/individual_category_sub_section.dart';
import 'package:Nesto/models/dynamic_home_page/main_offer_banner.dart';
import 'package:Nesto/models/dynamic_home_page/main_offer_section.dart';
import 'package:Nesto/models/dynamic_home_page/sponsered_ads_section.dart';
import 'package:Nesto/models/dynamic_home_page/sponsored_ad.dart';
import 'package:Nesto/models/dynamic_home_page/sub_category_tile.dart';
import 'package:Nesto/models/main_category.dart';
import 'package:Nesto/models/merchandise_category.dart';
import 'package:Nesto/models/sort_filter_section_model.dart';
import 'package:Nesto/models/subcategory.dart';
import 'package:Nesto/models/time_slot.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/services/local_storage.dart';
import 'package:Nesto/services/navigation_service.dart';
import 'package:Nesto/services/notification_service.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/constants.dart';
import 'package:Nesto/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cartItem.dart';
import '../models/product.dart';
import '../service_locator.dart';

enum PAYMENT_STATUS { NONE, AUTHORIZED, CAPTURED, FAILED }
enum COUPON_CODE_STATUS { NOT_APPLIED, APPLIED_SUCCESSFULLY, APPLIED_ERROR }

const String SLOT_TYPE_EXPRESS = "express";
const String SLOT_TYPE_SCHEDULED = "scheduled";

class StoreProvider with ChangeNotifier {
  //####Section#### {Object Declerations}
  bool donotShowCartTutorial = false;
  double minimumAmountRequiredForCouponCode;

  //Use to check if the API fetch finished in the splash screen
  bool homePageFetchFinished = false;
  COUPON_CODE_STATUS couponCodeSubmitStatus = COUPON_CODE_STATUS.NOT_APPLIED;
  bool enableSubstitution = true;
  String deliveryNote = '';
  bool fetchingTimeslot = true;

  //Home page delivery timeslot Variables
  String nextAvailableTimeSlot = '--';
  String nextTimeSlotInHours = '--';

  //Used to set the url of payment gateway
  String paymentGatewayUrl = "";

  //Used to indicate payment completion
  bool orderSuccess = false;

  //Used to indicate order error
  bool orderError = false;
  bool flushCart = false;

  //Used to indicate that home page is being fethced
  bool _isHomePageLoading = false;

  //Used to indicate error in loading dynamic homepage
  bool isHomePageError = false;

  //Error message reason
  String errorMessage = "";

  //Used to launch payment gateway on checkout screen
  bool launchNGenius = false;

  //Available timeslots
  Map<String, DateTime> timeSlotDetails = {};
  List<TimeSlot> _todayTimeSlots = [];
  List<TimeSlot> _tomorrowTimeSlots = [];

  //Selected address used for shipping
  Address _shippingAddress;

  get isHomePageLoading {
    return _isHomePageLoading;
  }

  set isHomePageLoading(bool value) {
    _isHomePageLoading = value;
    notifyListeners();
  }

  setIsHomePageLoading(bool value) {
    _isHomePageLoading = value;
  }

  //Move this function away
  Address get shippingAddress {
    return _shippingAddress;
  }

  set shippingAddress(value) {
    _shippingAddress = value;
    if (value != null) {
      addShippingInformation();
    } else {
      _clearMagentoTotals();
    }
    notifyListeners();
  }

  //Show Shipping address spinner
  bool showShippingAddressSpinner = false;
  bool cartSyncLoader = false;

  //Move this function away
  void showSpinnerInCart() {
    showShippingAddressSpinner = true;
    notifyListeners();
  }

  void showCartSyncLoader() {
    cartSyncLoader = true;
    notifyListeners();
  }

  void hideCartSyncLoader() {
    cartSyncLoader = false;
    notifyListeners();
  }

  void hideSpinnerInCart() {
    showShippingAddressSpinner = false;
    //notifyListeners();
  }

  //Show spinner in wishlist
  bool showWishlistSpinner = false;

  void showSpinnerInWishlist() {
    showWishlistSpinner = true;
    notifyListeners();
  }

  void hideSpinnerInWishlist() {
    showWishlistSpinner = false;
    notifyListeners();
  }

  //Timeslot data to send to the backend
  DateTime selectedDateForDelivery;
  String selectedTimeSlotIdForDelivery;
  String selectedDateInStringForDelivery = "";
  String selectedFromTimeForDelivery = "";
  String selectedToTimeForDelivery = "";

  //Delivery lat and Delivery ln
  double deliveryLat = 0;
  double deliveryLn = 0;

  void modifyOrderSuccess(bool value) {
    orderSuccess = value;
    notifyListeners();
  }

  void modifyOrderError(bool value) {
    orderError = value;
    notifyListeners();
  }

  void modifyLaunchNGenius(bool value) {
    launchNGenius = value;
    notifyListeners();
  }

  List<TimeSlot> get todayTimeSlots {
    return [..._todayTimeSlots];
  }

  List<TimeSlot> get tomorrowTimeSlots {
    return [..._tomorrowTimeSlots];
  }

  List<dynamic> _dynamicHomepageWidgets = [];

  List<dynamic> get dynamicHomepageWidgets {
    return [..._dynamicHomepageWidgets];
  }

  List<TimeSlot> get getValidTodayTimeSlots {
    List<TimeSlot> loadedTimeSlots = [];
    //Add day to timeslots
    for (int i = 0; i < 7; i++) {
      _todayTimeSlots.forEach((element) {
        element.day = DateTime.now().add(Duration(days: i));
      });
    }
    //Add valid timeslots to loadedTimeSlots
    _todayTimeSlots.forEach((element) {
      if (isTimeSlotValid(element.cutOffTime, element.day)) {
        loadedTimeSlots.add(element);
      }
    });
    return loadedTimeSlots;
  }

  List<TimeSlot> get getValidTomorrowTimeSlots {
    List<TimeSlot> loadedTimeSlots = [];
    //Add day to timeslots
    for (int i = 0; i < 7; i++) {
      _tomorrowTimeSlots.forEach((element) {
        element.day = DateTime.now().add(Duration(days: i));
      });
    }
    //Add valid timeslots to loadedTimeSlots
    _tomorrowTimeSlots.forEach((element) {
      if (isTimeSlotValid(element.cutOffTime, element.day)) {
        loadedTimeSlots.add(element);
      }
    });
    return loadedTimeSlots;
  }

  bool isTimeSlotValid(String cutOffTimeInString, DateTime cutOffTime) {
    //All time slots are valid except for today

    int cutOffTimeHour =
        int.parse(cutOffTimeInString[0] + cutOffTimeInString[1]);
    int cutOffTimeMinute =
        int.parse(cutOffTimeInString[3] + cutOffTimeInString[4]);

    DateTime currentTime = DateTime.now();

    cutOffTime = new DateTime(cutOffTime.year, cutOffTime.month, cutOffTime.day,
        cutOffTimeHour, cutOffTimeMinute, 0, 0, 0);

    if (currentTime.isAfter(cutOffTime))
      return false;
    else
      return true;
  }

  //Recent searches
  List<String> _recentSearches = [];

  List<String> get recentSearches {
    return _recentSearches.reversed.toList();
  }

  set recentSearches(value) {
    _recentSearches = value;
  }

  clearRecentSearch() {
    _recentSearches.clear();
  }

  void addToRecentSearches(String text) {
    logNesto("SEARCHED WORD $text");
    if (!_recentSearches.contains(text) && text != "") {
      _recentSearches.add(text);
      notifyListeners();
    }
  }

  void removeFromRecentSearches(String text) {
    logNesto("HELLO:" + text);
    for (var item in _recentSearches) {
      if (item == text) {
        _recentSearches.remove(item);
        notifyListeners();
      }
    }
  }

  //Show spinner while updating product quantity
  List<Product> updatingProducts = [];

  void modifyShowProductSpinner(bool value, Product product) {
    if (value) {
      updatingProducts.add(product);
    } else {
      updatingProducts.removeWhere((element) => element.sku == product.sku);
    }
    notifyListeners();
  }

  bool isProductInUpdatingProduct(Product product) {
    for (var item in updatingProducts) {
      if (item.sku == product.sku) return true;
    }
    return false;
  }

  //Show error message
  bool showProductOutOfStock = false;

  //General loading
  bool _isLoading = false;

  get isLoading {
    return _isLoading;
  }

  void showLoadingSpinner() {
    _isLoading = true;
    notifyListeners();
  }

  void hideLoadingSpinner() {
    _isLoading = false;
    notifyListeners();
  }

  //####Section#### {Inventory functions}

  // List<Product> _dealsOfTheDay = [];
  // List<Product> _frequentlyBoughtTogether = [];

  List<Product> _products = [];
  List<MainCategory> _mainCategories = [];
  List<Product> _productsOfACategory = [];
  List<Product> _searchedProducts = [];

  Map<String, List<Product>> _dynamicHomepageProducts = {"": []};
  List<Product> _viewMoreProducts = [];
  List<Product> _bestSellers = [];

  //This is a secure approach to retrieve the product inventory
  List<Product> get products {
    return [..._products];
  }

  List<MainCategory> get mainCategories {
    return [..._mainCategories];
  }

  List<Product> get productsOfACategory {
    return [..._productsOfACategory];
  }

  List<Product> get searchedProducts {
    return _searchedProducts;
  }

  set searchedProductsClear(value) {
    _searchedProducts = value;
  }

  Map<String, List<Product>> get dynamicHomepageProducts {
    return _dynamicHomepageProducts;
  }

  List<Product> get viewMoreProducts {
    return [..._viewMoreProducts];
  }

  List<Product> get bestSellers {
    // _bestSellers.forEach((element) {
    //   print("XXXXXXXXXXXXXXXXX "+element.name.toString()+", "+element.inStock.toString());
    // });
    return [..._bestSellers];
  }

  // List<Product> get dealsOfTheDay{
  //   return [..._dealsOfTheDay];
  // }
  //
  // List<Product> get bestSellers{
  //   return [..._bestSellers];
  // }
  //
  // List<Product> get frequentlyBoughtTogether{
  //   return [..._frequentlyBoughtTogether];
  // }

  //####Section#### {Network functions}

  void getDeliveryLocationAndLatitude() async {
    SharedPreferences encryptedSharedPreferences =
        await SharedPreferences.getInstance();

    deliveryLat = encryptedSharedPreferences.getDouble('userlat') ?? 1.0;

    deliveryLn = encryptedSharedPreferences.getDouble('userlng') ?? 1.0;
  }

  String _cartToken = "";
  String _cartTokenGraphQL = "";

  String _orderId = "";
  String incrementId = "";

  String _orderRef = "";

  PAYMENT_STATUS paymentStatus = PAYMENT_STATUS.NONE;

  Future fetchAll() async {
    logNesto("FETCH ALL");
    fetchAllDynamicHomePage();
    fetchFilterOptions();
    if (isAuthTokenValid()) {
      createMagentoCart();
    }
  }

  Future fetchAllDynamicHomePage() async {
    final NavigationService _navigation = locator.get<NavigationService>();
    DateTime today = DateTime.now();

    String todayString = today.year.toString() +
        "-" +
        today.month.toString() +
        "-" +
        today.day.toString();

    logNesto("DATE today:" + todayString);

    final header = {
      "content-type": "application/json",
    };

    Dio dio = Dio(BaseOptions(
      connectTimeout: 25000,
      receiveTimeout: 25000,
    ));
    try {
      String _url = MAGENTO_BASE_URL +
          "/V2/redis/home/$storeId?categoryTree=$ROOT_CATEGORY_ID&date=$todayString&store=app&source=false";

      print("FETCHING ALL DYNAMIC HOMEPAGE JSON: $_url");

      //start laoding in home_page
      isHomePageLoading = true;

      var response = await dio.request(
        _url,
        options: Options(method: 'GET', headers: header),
      );

      var decodedResponse =
          json.decode(response.toString()) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        var homeConsoleData =
            decodedResponse["homeConsole"] as Map<String, dynamic>;
        var bestSellerData = decodedResponse["bestSeller"] as List<dynamic>;
        var categoryTreeData =
            decodedResponse["categoryTree"] as Map<String, dynamic>;
        var timeSlotsData = decodedResponse["timeSlots"] as List<dynamic>;

        var timeSlotsTomorrowData =
            decodedResponse["timeSlotsTomorrow"] as List<dynamic>;
        await dynamicHomepageDataMapping(homeConsoleData: homeConsoleData);
        await bestSellersDataMapping(bestSellerData: bestSellerData);
        await mainCategoriesDataMapping(categoryTree: categoryTreeData);
        await timeSlotsDataMapping(
            todayTimeSlot: timeSlotsData,
            tomorrowTimeSlot: timeSlotsTomorrowData);

        //stop home page loading
        setIsHomePageLoading(false);
        isHomePageError = false;
        notifyListeners();
      } else {
        //stop home page loading
        isHomePageLoading = false;
        logNesto("FETCH ALL DYNAMIC HOME PAGE ERROR 1:$decodedResponse");

        isHomePageError = true;
        fetchingTimeslot = false;
        notifyListeners();
        showError(_navigation.navigatorKey.currentContext,
            decodedResponse["message"] ?? "Something went wrong !");
      }
    } on DioError catch (e) {
      var message = e?.message ?? "Something went wrong !";
      //stop home page loading
      isHomePageLoading = false;
      isHomePageError = true;
      fetchingTimeslot = false;
      notifyListeners();
      logNesto("FETCH ALL DYNAMIC HOME PAGE ERROR 2: $e");
      showError(_navigation.navigatorKey.currentContext,
          message ?? "Something went wrong !");
    } catch (e) {
      //stop home page loading
      print('sa - 1$e');
      isHomePageLoading = false;
      var message = e?.message ?? "Something went wrong !";
      isHomePageError = true;
      fetchingTimeslot = false;
      notifyListeners();
      showError(_navigation.navigatorKey.currentContext,
          message ?? "Something went wrong !");
      logNesto("FETCH ALL DYNAMIC HOME PAGE ERROR 2: $e");
    }
  }

  Future checkIfFetchFinished() async {
    if (homePageFetchFinished) {
      homePageFetchFinished = false;
      return ConnectionState.done;
    }
  }

  Future dynamicHomepageDataMapping({var homeConsoleData}) async {
    _dynamicHomepageWidgets.clear();
    notifyListeners();

    var data = homeConsoleData["data"] as List<dynamic>;

    List<dynamic> _loadedWidgets = [];

    data.forEach((element) {
      var type = element["type"];

      //logNesto("TYPE:"+type.toString());

      if (type.toString() == "main_offer_section") {
        List<MainOfferBanner> _mainOffersBannerList = [];

        var mainOffersBannerData = element["widgets"] as List<dynamic>;

        mainOffersBannerData.forEach((mainOfferBannerElement) {
          _mainOffersBannerList.add(MainOfferBanner(
              title: mainOfferBannerElement["title"],
              imageUrl: mainOfferBannerElement["image_url"],
              isExternal: mainOfferBannerElement["is_external"],
              link: mainOfferBannerElement["link"]));
        });

        MainOfferSection mainOfferSection = MainOfferSection(
            title: element["title"], widgets: _mainOffersBannerList);
        _loadedWidgets.add(mainOfferSection);
      } else if (type.toString() == "all_categories_section") {
        List<IndividualCategorySubSection> _individualCategoriesSubsections =
            [];

        var individualCategoriesSubSectionData =
            element["widgets"] as List<dynamic>;

        individualCategoriesSubSectionData
            .forEach((individualCategoriesSubSectionElement) {
          var categoryWidgetData =
              individualCategoriesSubSectionElement["widgets"] as List<dynamic>;
          List<dynamic> _categoryWidgets = [];

          categoryWidgetData.forEach((categoryWidgetElement) {
            //TODO: SPLIT HEADERS AND NON HEADERS
            var type = categoryWidgetElement["type"];

            if (type.toString() == "category_header") {
              CategoryHeader categoryHeader = CategoryHeader(
                imageUrl: categoryWidgetElement["image_url"],
                link: categoryWidgetElement["link"],
                isExternal: categoryWidgetElement["is_external"],
                title: categoryWidgetElement["title"],
              );
              _categoryWidgets.add(categoryHeader);
            } else if (type.toString() == "sub_category_tile") {
              SubCategoryTile subCategoryTile = SubCategoryTile(
                imageUrl: categoryWidgetElement["image_url"],
                link: categoryWidgetElement["link"],
                isExternal: categoryWidgetElement["is_external"],
                title: categoryWidgetElement["title"],
              );
              _categoryWidgets.add(subCategoryTile);
            }
          });

          _individualCategoriesSubsections
              .add(IndividualCategorySubSection(widgets: _categoryWidgets));
        });

        AllCategoriesSection allCategoriesSection = AllCategoriesSection(
            title: element["title"], widgets: _individualCategoriesSubsections);

        _loadedWidgets.add(allCategoriesSection);
      } else if (type.toString() == "deals_section") {
        List<DealCard> _dealCards = [];

        var dealsCardsData = element["widgets"] as List<dynamic>;

        dealsCardsData.forEach((dealCardElement) {
          _dealCards.add(DealCard(
              imageUrl: dealCardElement["image_url"],
              isExternal: dealCardElement["is_external"],
              link: dealCardElement["link"]));
        });

        DealsSection dealsSection = DealsSection(
            title: element["title"],
            widgets: _dealCards,
            ctaLink: int.tryParse(element["cta_link"]));
        _loadedWidgets.add(dealsSection);
      } else if (type.toString() == "buy_from_cart_section") {
        var maxWidgetsData = element["max_widgets"];
        int maxWidgets = 0;
        if (maxWidgetsData is String)
          maxWidgets = int.tryParse(maxWidgetsData);
        else
          maxWidgets = maxWidgetsData;

        BuyFromCartSection buyFromCartSection = BuyFromCartSection(
            title: element["title"],
            link: element["link"],
            ctaLink: element["cta_link"],
            widgets: [],
            maxWidgets: maxWidgets);
        _loadedWidgets.add(buyFromCartSection);
        var decodedResponse = element["products"];
        var data =
            decodedResponse is Map ? decodedResponse.values.toList() : [];

        List<Product> loadedProducts = [];

        data.forEach((element) {
          if (element is Map) {
            var productData = Product.fromJson(element, false);

            if (productData != null) if (productData is Product)
              loadedProducts.add(productData);
            else
              loadedProducts.addAll(productData);
          }
        });

        _dynamicHomepageProducts.addAll({element["title"]: loadedProducts});
      } else if (type.toString() == "sponsered_ads_section") {
        List<SponsoredAd> _sponsoredAds = [];

        var sponsoredAdsData = element["widgets"] as List<dynamic>;

        sponsoredAdsData.forEach((dealCardElement) {
          _sponsoredAds.add(SponsoredAd(
              imageUrl: dealCardElement["image_url"],
              isExternal: dealCardElement["is_external"],
              link: dealCardElement["link"]));
        });

        SponsoredAdsSection dealsSection = SponsoredAdsSection(
            title: element["title"], widgets: _sponsoredAds);
        _loadedWidgets.add(dealsSection);
      }
    });

    _dynamicHomepageWidgets.addAll(_loadedWidgets);
    logNesto("DYNAMIC HOMEPAGE WIDGETS LENGTH:" +
        _dynamicHomepageWidgets.length.toString());
    homePageFetchFinished = true;
    isHomePageError = false;
    notifyListeners();
  }

  Future mainCategoriesDataMapping({var categoryTree}) async {
    //Get MainCategories
    List<dynamic> mainCategoryData = categoryTree["children_data"] is Map
        ? categoryTree["children_data"].values.toList()
        : [];

    List<MainCategory> loadedMainCategories = [];
    //For each main category element
    mainCategoryData.forEach((mainCategoryElement) {
      //Get it's subcategories
      List<dynamic> subCategoryData =
          mainCategoryElement["children_data"] is Map
              ? mainCategoryElement["children_data"].values.toList()
              : [];

      List<SubCategory> subCategoriesOfThisMainCategory = [];
      subCategoryData.forEach((subCategoryElement) {
        //Get merchandise categories of the subcategories
        List<dynamic> merchandiseCategoryData =
            subCategoryElement["children_data"] is Map
                ? subCategoryElement["children_data"].values.toList()
                : [];

        List<MerchandiseCategory> merchandiseCategoriesOfThisSubCategory = [];

        merchandiseCategoryData.forEach((merchandiseCategoryElement) {
          var merchandiseCategoryElementMediaData =
              merchandiseCategoryElement["media"];
          String merchandiseCategoryElementMedia = "";
          if (merchandiseCategoryElementMediaData is String)
            merchandiseCategoryElementMedia =
                merchandiseCategoryElementMediaData;

          if (merchandiseCategoryElement["is_active"] != null) {
            if (merchandiseCategoryElement["is_active"] == true) {
              merchandiseCategoriesOfThisSubCategory.add(MerchandiseCategory(
                  id: int.tryParse(merchandiseCategoryElement["id"]),
                  parentId:
                      int.tryParse(merchandiseCategoryElement["parent_id"]),
                  name: merchandiseCategoryElement["name"],
                  isActive: merchandiseCategoryElement["is_active"],
                  position:
                      int.tryParse(merchandiseCategoryElement["position"]),
                  productCount: merchandiseCategoryElement["product_count"],
                  imageUrl:
                      getCategoryImageUrl(merchandiseCategoryElementMedia)));
            } else {
              logNesto("REJECTED MERCHANDISE CAT");
            }
          }
        });

        //Get the subcategories of the main category
        if (subCategoryElement["is_active"] != null) {
          var subCategoryElementMediaData = subCategoryElement["media"];
          String subCategoryElementMedia = "";
          if (subCategoryElementMediaData is String)
            subCategoryElementMedia = subCategoryElementMediaData;

          //Sort merchandise categories by level
          merchandiseCategoriesOfThisSubCategory
              .sort((a, b) => a.position.compareTo(b.position));
          if (subCategoryElement["is_active"] == true) {
            subCategoriesOfThisMainCategory.add(SubCategory(
                merchandiseCategories: merchandiseCategoriesOfThisSubCategory,
                id: int.tryParse(subCategoryElement["id"]),
                parentId: int.tryParse(subCategoryElement["parent_id"]),
                name: subCategoryElement["name"],
                isActive: subCategoryElement["is_active"],
                position: int.tryParse(subCategoryElement["position"]),
                productCount: subCategoryElement["product_count"],
                imageUrl: getCategoryImageUrl(subCategoryElementMedia)));
          }
        }
      });

      //Generate description of main category
      int length = min(10, subCategoriesOfThisMainCategory.length);
      String description = "";
      for (int i = 0; i < length; i++) {
        if (subCategoriesOfThisMainCategory[i].name != null) {
          if (i == 0) {
            description += subCategoriesOfThisMainCategory[i].name;
          } else if (i == length - 1) {
            description +=
                " & " + subCategoriesOfThisMainCategory[i].name + ".";
          } else {
            description += ", " + subCategoriesOfThisMainCategory[i].name;
          }
        }
      }

      //Sort subcategories by position
      subCategoriesOfThisMainCategory
          .sort((a, b) => a.position.compareTo(b.position));

      if (mainCategoryElement["is_active"] != null) {
        if (mainCategoryElement["is_active"] == true) {
          var mainCategoryElementMediaData = mainCategoryElement["media"];
          String mainCategoryElementMedia = "";
          if (mainCategoryElementMediaData is String)
            mainCategoryElementMedia = mainCategoryElementMediaData;
          subCategoriesOfThisMainCategory
              .sort((a, b) => a.position.compareTo(b.position));
          loadedMainCategories.add(MainCategory(
              subCategories: subCategoriesOfThisMainCategory,
              description: description,
              id: int.tryParse(mainCategoryElement["id"]),
              parentId: int.tryParse(mainCategoryElement["parent_id"]),
              name: mainCategoryElement["name"],
              isActive: mainCategoryElement["is_active"],
              position: int.tryParse(mainCategoryElement["position"]),
              productCount: mainCategoryElement["product_count"],
              imageUrl: getCategoryImageUrl(mainCategoryElementMedia)));
        }
      }
    });

    _mainCategories.clear();
    //Sort main categories
    loadedMainCategories.sort((a, b) => a.position.compareTo(b.position));
    _mainCategories.addAll(loadedMainCategories);
    _mainCategories.sort((a, b) => a.position.compareTo(b.position));
    notifyListeners();
  }

  String getCategoryImageUrl(String url) {
    //Get the url value
    String value = url;
    //Remove /media if it's available
    if (value.contains("/media")) {
      value = value.replaceAll("/media", "");
    }
    //Remove /product if it's available
    if (value.contains("/product")) {
      value = value.replaceAll("/product", "");
    }
    //ADD BASE URL
    String imageUrl = "";
    if (!value.contains("http")) {
      imageUrl = CATEGORY_IMAGE_BASE_URL + value;
    } else
      imageUrl = value;

    return imageUrl;
  }

  Future bestSellersDataMapping({var bestSellerData}) async {
    _bestSellers.clear();
    List<Product> loadedProducts = [];

    bestSellerData.forEach((element) {
      var productData = Product.fromJson(element, false);

      if (productData != null) if (productData is Product)
        loadedProducts.add(productData);
      else
        loadedProducts.addAll(productData);
    });

    if (_bestSellers.isEmpty) {
      _bestSellers.addAll(loadedProducts);
    }
    notifyListeners();
  }

  Future getComplimentaryProducts({int itemId}) async {
    List<Product> loadedProducts = [];
    final url =
        MAGENTO_BASE_URL + "/V2/products/complementary/$storeId/$itemId";

    print("============================>");
    print("URL_COMP: $url");
    print("============================>");

    final header = {
      "content-type": "application/json",
    };
    try {
      var response = await http.get(Uri.parse(url), headers: header);
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response?.body);
        print("============================>");
        print("COMPLIMENTART: $decodedResponse");
        print("============================>");

        decodedResponse.forEach((element) {
          if (element is Map) {
            var productData = Product.fromJson(element, false);

            if (productData != null) if (productData is Product)
              loadedProducts.add(productData);
            else
              loadedProducts.addAll(productData);
          }
        });
        return loadedProducts;
      }
    } catch (e) {
      return [];
    }
  }

  Future fetchProductsByCategoryId(String title, int categoryId) {
    logNesto("FETCHING PRODUCTS BY CATEGORY ID:$categoryId");

    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1/category/redis/get/$storeId/$categoryId";

    final header = {
      "content-type": "application/json",
    };

    try {
      return http.get(Uri.parse(url), headers: header).then((response) {
        //logNesto("PRODUCTS OF A CATEGORY RESPONSE:" + response.body);

        if (response.statusCode == 200) {
          var decodedResponse = jsonDecode(response.body);
          var data =
              decodedResponse is Map ? decodedResponse.values.toList() : [];

          List<Product> loadedProducts = [];

          data.forEach((element) {
            if (element is Map) {
              var productData = Product.fromJson(element, false);

              if (productData != null) if (productData is Product)
                loadedProducts.add(productData);
              else
                loadedProducts.addAll(productData);
            }
          });

          _dynamicHomepageProducts.addAll({title: loadedProducts});

          notifyListeners();
        } else {
          //TODO:NO RESULTS FOUND
        }
      });
    } finally {
      //http.close();
    }
  }

  Future fetchProductsOfACategory(int categoryId) {
    logNesto("FETCHING PRODUCTS OF A CATEGORY:" + categoryId.toString());

    showLoadingSpinner();

    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1/category/redis/get/$storeId/$categoryId";
    _productsOfACategory.clear();
    notifyListeners();

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
    };

    logNesto("HEADER:" + header.toString());

    try {
      return http.get(Uri.parse(url), headers: header).then((response) {
        logNesto("CATEGORY RESPONSE:" + response.body);

        if (response.statusCode == 200) {
          var decodedResponse = jsonDecode(response.body);
          var data =
              decodedResponse is Map ? decodedResponse.values.toList() : [];

          List<Product> loadedProducts = [];

          data.forEach((element) {
            //logNesto("ELEMENT:"+element.toString());
            if (element is Map) {
              var productData = Product.fromJson(element, false);

              if (productData != null) if (productData is Product)
                loadedProducts.add(productData);
              else
                loadedProducts.addAll(productData);
            }
          });

          _productsOfACategory.clear();
          _productsOfACategory.addAll(loadedProducts);
          logNesto("PRODUCTS OF A CATEGORY LENGTH:" +
              _productsOfACategory.length.toString());

          //firebase analytics logging
          firebaseAnalytics.logViewProductList(
              categoryID: categoryId.toString(), env: ENV);
        } else {
          logNesto("No results");
          //TODO:NO RESULTS FOUND
        }
        notifyListeners();
        hideLoadingSpinner();
      });
    } finally {
      //http.close();
    }
  }

  Future<List<Product>> fetchProductsOfCategory(int categoryId) async {
    firebaseAnalytics.logViewProductList(
        categoryID: categoryId.toString(), env: ENV);

    final uri = MAGENTO_BASE_URL +
        "/$storeCode/V1/category/redis/get/$storeId/$categoryId";
    final header = {
      "content-type": "application/json",
    };

    var response = await http.get(Uri.parse(uri), headers: header);
    var decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var data = decodedResponse is Map ? decodedResponse.values.toList() : [];

      List<Product> loadedProducts = [];

      data.forEach((element) {
        if (element is Map) {
          var productData = Product.fromJson(element, false);

          if (productData != null) if (productData is Product)
            loadedProducts.add(productData);
          else
            loadedProducts.addAll(productData);
        }
      });

      return loadedProducts;
    } else {
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  Future<List<Product>> fetchProductsOfCategoryPagination(
      int pageNumber, int categoryId,
      {bool applyFilter = false,
      Option selectedSort,
      Option selectedFilter}) async {
    firebaseAnalytics.logViewProductList(
        categoryID: categoryId.toString(), env: ENV);

    int pageLimit = 10;

    final uri =
        "$MAGENTO_BASE_URL/V1/category/redis/get/${storeId.toString()}/${categoryId.toString()}/${pageLimit.toString()}/${pageNumber.toString()}" +
            "${applyFilter ? "?${selectedFilter != null ? "filtername=${selectedFilter?.optionKey}&filter=${selectedFilter?.optionValue}" : ''}" + "${selectedSort != null ? "&sortname=${selectedSort?.optionKey}&sort=${selectedSort?.optionValue}" : ''}" : ''}";
    //"/V1/redis/pagination/$storeId/$categoryId?page=$pageNumber&limit=$pageLimit";

    print("\n\n===================>");
    print("URI: $uri");
    print("<===================\n\n");

    final header = {
      "content-type": "application/json",
    };

    var response = await http.get(Uri.parse(uri), headers: header);
    var decodedResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var data = decodedResponse is Map ? decodedResponse.values.toList() : [];

      List<Product> loadedProducts = [];

      data.forEach((element) {
        if (element is Map) {
          var productData = Product.fromJson(element, false);

          if (productData != null) if (productData is Product)
            loadedProducts.add(productData);
          else
            loadedProducts.addAll(productData);
        }
      });

      print("\n\n===================>");
      print("loaded lne: ${loadedProducts.length}");
      print("<===================\n\n");

      return loadedProducts;
    } else {
      if (response.statusCode.isServerErr() ?? false) {
        throw Exception(strings.SOMETHING_WENT_WRONG);
      } else {
        throw Exception(
            decodedResponse["message"] ?? strings.SOMETHING_WENT_WRONG);
      }
    }
  }

  Future fetchProductsForViewMore(int categoryId) {
    logNesto("FETCHING PRODUCTS FOR VIEW MORE:" + categoryId.toString());

    showLoadingSpinner();

    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1/category/redis/get/$storeId/$categoryId";
    _productsOfACategory.clear();
    notifyListeners();

    logNesto("fetchProductsForViewMore URL:" + url);

    final header = {
      "content-type": "application/json",
    };

    //logNesto("HEADER:" + header.toString());

    try {
      return http.get(Uri.parse(url), headers: header).then((response) {
        logNesto("VIEW MORE RESPONSE:" + response.body);

        if (response.statusCode == 200) {
          var decodedResponse = jsonDecode(response.body);
          var data =
              decodedResponse is Map ? decodedResponse.values.toList() : [];

          List<Product> loadedProducts = [];

          data.forEach((element) {
            //logNesto("ELEMENT:"+element.toString());
            if (element is Map) {
              var productData = Product.fromJson(element, false);

              if (productData != null) if (productData is Product)
                loadedProducts.add(productData);
              else
                loadedProducts.addAll(productData);
            }
          });

          _viewMoreProducts.clear();
          _viewMoreProducts.addAll(loadedProducts);

          //firebase analytics logging.
          firebaseAnalytics.logViewProductList(
              categoryID: categoryId.toString(), env: ENV);
        } else {
          logNesto("No results");
          //TODO:NO RESULTS FOUND
        }
        notifyListeners();
        hideLoadingSpinner();
      });
    } finally {
      //http.close();
    }
  }

  bool isPaginationLoadingForSearchNotForTheFirstTime = false;
  bool isPaginationLoadingForSearchForTheFirstTime = false;
  bool noNeedToCallSearchPaginationAgain = false;
  int currentPageForSearchPagination = 1;
  // int limitForSearchPagination = 10;

  Future searchProductsByNameInMagentoForPagination(String productName,
      {String email = anonymousEmail,
      int pageCount = 10,
      bool skipLogging = false}) async {
    if (!noNeedToCallSearchPaginationAgain) {
      //firebase analytics logging
      firebaseAnalytics.logSearch(searchTerm: productName);
      if (_searchedProducts.length > 0 &&
          !isPaginationLoadingForSearchForTheFirstTime) {
        currentPageForSearchPagination++;
        isPaginationLoadingForSearchNotForTheFirstTime = true;
        notifyListeners();
      } else {
        currentPageForSearchPagination = 1;
        _isLoading = true;
        notifyListeners();
      }

      final url = MAGENTO_BASE_URL +
          "/V2/elasticsearch/search/$storeId?currentPage=$currentPageForSearchPagination&limit=$pageCount&searchQuery=$productName&customerData=$email&skipLogging=$skipLogging";
      logNesto("SEARCHING PRODUCT URL:" + url);

      final header = {"content-type": "application/json", "Store": storeCode};

      logNesto("BATMAN:" + header.toString());

      try {
        return http.get(Uri.tryParse(url), headers: header).then((response) {
          if (response.statusCode == 200) {
            logNesto("SEARCH RESPONSE:" + response.body);
            List<dynamic> forListLengthCheck =
                json.decode(response.body) as List<dynamic>;
            if (forListLengthCheck.length == 0) {
              noNeedToCallSearchPaginationAgain = true;
            }
            var data = json.decode(response.body.toString()) as dynamic;

            //logNesto("DATA TO STRING:" + data.toString());

            List<Product> loadedProducts = [];

            data.forEach((element) {
              if (element != null) {
                var productData = Product.fromJson(element, false);

                if (productData != null) if (productData is Product)
                  loadedProducts.add(productData);
                else
                  loadedProducts.addAll(productData);
              }
            });

            _searchedProducts.addAll(loadedProducts);
          } else {
            //TODO:NO RESULTS FOUND
          }
          _isLoading = false;
          isPaginationLoadingForSearchNotForTheFirstTime = false;
          isPaginationLoadingForSearchForTheFirstTime = false;
          notifyListeners();
        });
      } finally {
        //http.close();
      }
    }
    return null;
  }

  Future setSelectedProductBySKU(String sku) {
    logNesto("SET SELECTED PRODUCTS BY SKU $sku");
    _selectedProduct = null;
    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1" +
        "/customapi/products/$sku?store_id=$storeId";

    logNesto("URL:" + url);
    final header = {"content-type": "application/json"};

    try {
      return http.get(Uri.parse(url), headers: header).then((response) {
        logNesto("SELECTED PRODUCT BY SKU RESPONSE:" + response.body);

        if (response.statusCode == 200) {
          var element = json.decode(response.body.toString()) as dynamic;

          List<Product> loadedProducts = [];

          loadedProducts.add(Product.fromJson(element, true));

          _selectedProduct = loadedProducts.first;

          notifyListeners();
          //firbase analytics logging.
          firebaseAnalytics.logViewProduct(
            sku: sku,
            env: ENV,
            currency: "AED",
            price: _selectedProduct?.priceWithTax,
            itemName: _selectedProduct?.name,
          );
        } else {
          //TODO:NO RESULTS FOUND
        }
        notifyListeners();
      });
    } finally {
      //http.close();
    }
  }

  Future<Product> fetchProductWithSku(String sku) async {
    var uri =
        MAGENTO_BASE_URL + "/V1/customapi/products/$sku?store_id=$storeId";
    final header = {"content-type": "application/json"};
    print("\n=====================>");
    print("URL: $uri");
    print("<=====================\n");

    var response = await http.get(
      Uri.parse(uri),
      headers: header,
    );
    var decodedResponse = jsonDecode(response.body);

    print("\n=====================>");
    print("RESPONSE: $decodedResponse");
    print("<=====================\n");

    if (response.statusCode == 200) {
      print("\n=====================>");
      print("PRICE: ${decodedResponse["tax_included_price"]}");
      print("<=====================\n");

      if (double.parse(decodedResponse["tax_included_price"] ?? "0") == 0 ||
          double.parse(decodedResponse["price"] ?? "0") == 0) {
        throw Exception(strings.PRODUCT_NOT_FOUND);
      }

      return Product.fromJson(decodedResponse, true);
    } else {
      throw Exception(decodedResponse["message"] ??
          strings.SOMETHING_WENT_WRONG_WITH_EXCLAMATION);
    }
  }

  Future createMagentoCart() {
    logNesto("Creating magento cart");

    final url = MAGENTO_BASE_URL + "/$storeCode/V1" + "/carts/mine/";

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    //logNesto("AUTH TOKEN (CREATE MAGENTO CART):"+getAuthToken());
    try {
      return http.post(Uri.tryParse(url), headers: header).then((response) {
        if (response.statusCode == 200) {
          int _cartTokenInInt = int.tryParse(response.body.toString());
          _cartToken = _cartTokenInInt.toString();
          logNesto("CART TOKEN:" + _cartToken);
          getMagentoCart();
          getMagentoWishList();
          notifyListeners();
        } else {
          //TODO:NO RESULTS FOUND
        }
        notifyListeners();
      });
    } finally {
      //http.close();
    }
  }

  bool showCouponRemovalAlertAfterAppRestart = false;
  Future getMagentoCart() async {
    showCartSyncLoader();
    notifyListeners();
    logNesto("Getting magento cart");

    final url = MAGENTO_BASE_URL + "/$storeCode/V1" + "/carts/mine";

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    logNesto("HEADER:" + header.toString());

    try {
      return http
          .get(Uri.tryParse(url), headers: header)
          .then((response) async {
        if (response.statusCode == 200) {
          var decodedResponse =
              json.decode(response.body.toString()) as Map<String, dynamic>;
          final items = decodedResponse["items"] ?? [];
          if (items.length == 0) {
            showCouponRemovalAlertAfterAppRestart = false;
          } else {
            (decodedResponse["items"] as List<dynamic>).forEach((element) {
              if (element["extension_attributes"]["discount_amount"] > 0) {
                showCouponRemovalAlertAfterAppRestart = true;
              } else {
                showCouponRemovalAlertAfterAppRestart = false;
              }
            });
          }

          //logNesto("ITEMS IN MAGENTO CART:" + items.toString());
          logNesto("Response:" + decodedResponse.toString());
          await addAllItemsInMagentoCartToClientCart(items);
        } else {
          hideCartSyncLoader();
          //TODO:NO RESULTS FOUND
        }
        notifyListeners();
      });
    } catch (e) {
      hideCartSyncLoader();
    } finally {
      //http.close();
    }
  }

  static bool _hasBeenCartFetchedInitially = false;

  void resetHasCartBeenFetchedInitially() {
    _hasBeenCartFetchedInitially = false;
  }

  Future addAllItemsInMagentoCartToClientCart(List items) async {
    logNesto("ADD ALL ITEMS IN MAGENTO CART TO CLIENT CART");

    List<String> skuList = [];

    items.forEach((element) {
      skuList.add(element["sku"].toString());
    });

    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1" +
        "/customapi/getproductfromsku?store_id=$storeId";

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    final body = json.encode(skuList);

    logNesto("BODY:" + body.toString());

    try {
      var response =
          await http.post(Uri.tryParse(url), headers: header, body: body);
      logNesto(
          "GET PRODUCTS FROM SKU CART RESPONSE:" + response.body.toString());
      var data = jsonDecode(response.body.toString()) as List<dynamic>;

      Set<CartItem> loadedCartItems = {};

      int i = 0;
      data.forEach((element) async {
        if (element == null) logNesto("BATMAN: ITEM IN CART IS NULL");
        CartItem _cartItem = CartItem(
          itemId: items[i]["item_id"],
          product: Product.fromJson(element, true),
          quantity: items[i]["qty"],
          productInStockMagento: element["quantity_and_stock_status"]
              ["is_in_stock"],
          quantityMagento: element["quantity_and_stock_status"]["qty"],
          minimumQuantity: element["min_qty"] ?? 0,
          maximumQuantity: element["max_qty"] ?? 10000,
          finalTax: double.parse(
              items[i]["extension_attributes"]["final_tax"].toString()),
          taxAmount: double.parse(
              items[i]["extension_attributes"]["item_tax_amount"].toString()),
          rowTotal: double.parse(
              items[i]["extension_attributes"]["item_row_total"].toString()),
          finalRowTotal: double.parse(
              items[i]["extension_attributes"]["final_row_total"].toString()),
          discountAmount: double.parse(
              items[i]["extension_attributes"]["discount_amount"].toString()),
        );
        //#VARIANTS
        // if (_cartItem.hasVariants) {
        //   getVariants(_cartItem.itemId, _cartItem.product.name);
        // }
        loadedCartItems.add(_cartItem);
        i++;
      });
      _cart.clear();
      _cart.addAll(loadedCartItems);
      //modifyShowProductSpinner(false, Product());
    } finally {
      hideCartSyncLoader();
      //http.close();
    }
  }

  Future<void> getVariants(int itemId, String name) async {
    await searchProductsByNameInMagentoForPagination(name,
        pageCount: 4, skipLogging: true);
    for (CartItem _cartItem in _cart) {
      if (_cartItem.itemId == itemId) {
        _cartItem.setVariants(_searchedProducts);
        _searchedProducts.clear();
        notifyListeners();
      }
    }
  }

  bool isElementInCart(CartItem element) {
    bool isItemInCart = false;
    for (var item in _cart) {
      if (item.product.sku == element.product.sku) isItemInCart = true;
    }
    return isItemInCart;
  }

  void clearClientCart() async {
    _cart.clear();
    _cartQueue.clear();
    _shippingAddress = null;
    _clearMagentoTotals();
    notifyListeners();

    try {
      await LocalStorage().clearCart();
    } catch (e) {
      print(e.toString());
    }
  }

  Future applyCouponCode(String couponCode, BuildContext context) async {
    logNesto("APPLY COUPON CODE:" + couponCode);
    if (couponCode.isNotEmpty) {
      _couponCode = couponCode;
      showLoader();

      final header = {
        "content-type": "application/json",
        "Authorization": "Bearer ${getAuthToken()}"
      };

      try {
        var url =
            "$MAGENTO_BASE_URL/$storeCode/V1/carts/mine/coupons/$couponCode";
        http.put(Uri.tryParse(url), headers: header).then((response) async {
          hideLoader();

          var decodedResponse = json.decode(response.body.toString());

          print("APPLY COUPON CODE RESPONSE:" + decodedResponse.toString());
          print("APPLY COUPON CODE RESPONSE STATUS :" +
              json.decode(response.statusCode.toString()).toString());

          if (response.statusCode == 200) {
            couponCodeSubmitStatus = COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY;
            showSuccess(context, "Coupon code applied successfully");
            getMagentoCart();
            addShippingInformation();
            await getMinimumAmountRequiredForCoupon();
          } else {
            showError(context, decodedResponse["message"]);
            couponCodeSubmitStatus = COUPON_CODE_STATUS.APPLIED_ERROR;
          }
          notifyListeners();
        });
      } catch (e) {
        print("APPLY COUPON CODE ERROR:" + e.toString());
        couponCodeSubmitStatus = COUPON_CODE_STATUS.APPLIED_ERROR;
        notifyListeners();
        hideLoader();
        showError(context, "ERROR");
      }
    } else {
      showError(context, strings.PLEASE_ENTER_A_COUPON_CODE);
    }
  }

  // ignore: missing_return
  Future getMinimumAmountRequiredForCoupon() {
    final url = MAGENTO_BASE_URL + "/$storeCode/V1/couponinfo/$_couponCode";
    final header = {"content-type": "application/json"};
    try {
      http.get(Uri.parse(url), headers: header).then((response) {
        if (response.statusCode == 200) {
          logNesto("getMinimumAmountRequiredForCoupon response is " +
              response.body.toString());
          var decodedResponse = json.decode(response.body) as List<dynamic>;
          if (decodedResponse[0]["error"] == false) {
            minimumAmountRequiredForCouponCode =
                double.parse(decodedResponse[0]["minCartValue"].toString());
          } else {
            logNestoCustom(
                message:
                    "error occurred calling getMinimumAmountRequiredForCoupon",
                logType: LogType.error);
          }
        } else {
          logNestoCustom(
              message:
                  "error occurred calling getMinimumAmountRequiredForCoupon",
              logType: LogType.error);
        }
      });
    } catch (e) {
      logNestoCustom(
          message: "error occurred calling getMinimumAmountRequiredForCoupon",
          logType: LogType.error);
    }
  }

  Future<bool> removeCouponCode(
      {bool calledFromCouponRemovalAlertDialogue}) async {
    showLoader();

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    try {
      Dio dio = Dio(BaseOptions(
        baseUrl: MAGENTO_BASE_URL + "/$storeCode/V1",
        connectTimeout: 20000,
        receiveTimeout: 20000,
      ));

      var response = await dio.request(
        "/carts/mine/coupons",
        options: Options(method: 'DELETE', headers: header),
      );

      hideLoader();
      logNesto("DELETE COUPON CODE:" + response.toString());

      // var decodedResponse = json.decode(response.toString()) as Map<
      //     String,
      //     dynamic>;

      if (response.statusCode == 200) {
        showCouponRemovalAlertAfterAppRestart = false;
        couponCodeSubmitStatus = COUPON_CODE_STATUS.NOT_APPLIED;
        _couponCode = "";
        notificationServices
            .showInformationNotification(strings.COUPON_CODE_REMOVED);
        // if ((calledFromCouponRemovalAlertDialogue ?? false) == false) {
        //   await getMagentoCart();
        // }
        await getMagentoCart();

        if (shippingAddress != null) {
          addShippingInformation();
        }
        notifyListeners();
        return true;
      } else {
        notificationServices
            .showErrorNotification(strings.ERROR_REMOVING_COUPON_CODE);
        return false;
      }
    } on DioError catch (e) {
      hideLoader();
      notificationServices
          .showErrorNotification(strings.ERROR_REMOVING_COUPON_CODE);
      if (e.message.contains("404")) {
        notificationServices.showErrorNotification(strings.INVALID_COUPON_CODE);
      } else if (e.type == DioErrorType.connectTimeout ||
          e.type == DioErrorType.receiveTimeout ||
          e.type == DioErrorType.sendTimeout) {
        logNesto("APPLY COUPON CODE:" + e.message);
        notificationServices
            .showErrorNotification(strings.INTERNAL_SERVER_ERROR);
      } else {
        logNesto("APPLY COUPON CODE:" + e.message);
        notificationServices
            .showErrorNotification(strings.ERROR_REMOVING_COUPON_CODE);
      }
      return false;
    }
  }

  Future addProductToMagentoWishlist(Product product) {
    logNesto(
        "Add Product to magento wishlist:${product.id} || ${product.sku} ");

    final url = MAGENTO_BASE_URL + "/$storeCode/V1/wishlist/add/${product.id}";

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    logNesto("HEADER:" + header.toString());

    try {
      return http.post(Uri.parse(url), headers: header).then((response) async {
        logNesto("ADD PRODUCT TO MAGENTO WISHLIST:" + response.body);
        //firebase analytics logging
        firebaseAnalytics.logAddToWishlist(
            sku: product?.sku,
            price: product?.priceWithTax,
            currency: "AED",
            itemName: product?.name,
            value: product?.priceWithTax,
            env: ENV);
      });
    } finally {
      //http.close();
    }
  }

  Future removeProductFromMagentoWishlist(int id) {
    logNesto("Removing product from magento wishlist");
    showSpinnerInWishlist();

    final url = MAGENTO_BASE_URL + "/$storeCode/V1/wishlist/delete/$id";

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    logNesto("HEADER:" + header.toString());

    try {
      return http.post(Uri.parse(url), headers: header).then((response) async {
        logNesto(response.body);
        hideSpinnerInWishlist();
      });
    } finally {
      hideSpinnerInWishlist();
      //http.close();
    }
  }

  Future getMagentoWishList() {
    logNesto("Getting magento wishlist");
    _wishlist.clear();
    notifyListeners();

    final url = MAGENTO_BASE_URL + "/$storeCode/V1/wishlist/items";

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    logNesto("HEADER:" + header.toString());

    try {
      return http.get(Uri.parse(url), headers: header).then((response) async {
        logNesto("MAGENTO WISHLIST:" + response.body);

        if (response.statusCode == 200) {
          var items = json.decode(response.body.toString()) as List<dynamic>;

          addAllItemsInMagentoWishlistToClientWishlist(items);
        } else {
          //TODO:NO RESULTS FOUND
        }
        notifyListeners();
      });
    } finally {
      //http.close();
    }
  }

  Future addAllItemsInMagentoWishlistToClientWishlist(List items) {
    logNesto("ADD ALL ITEMS IN MAGENTO WISHLIST TO CLIENT WISHLIST");

    List<String> skuList = [];

    items.forEach((element) {
      skuList.add(element["product"]["sku"].toString());
    });

    final url =
        MAGENTO_BASE_URL + "/$storeCode/V1" + "/customapi/getproductfromsku";

    //logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    final body = json.encode(skuList);

    //logNesto("BODY:"+body.toString());

    try {
      return http
          .post(Uri.tryParse(url), headers: header, body: body)
          .then((response) async {
        var data = jsonDecode(response.body.toString()) as List<dynamic>;

        List<Product> loadedItems = [];

        int i = 0;
        data.forEach((element) {
          Product product = Product.fromJson(element, true);
          if (product is Product) {
            loadedItems.add(product);
          }
          i++;
        });

        _wishlist.clear();
        _wishlist.addAll(loadedItems);

        notifyListeners();
      });
    } finally {
      //http.close();
    }
  }

  List<String> listOfProductSku = [];

  Future addProductToMagentoCart(Product product, int quantity) async {
    if (!showCouponRemovalAlertAfterAppRestart) {
      listOfProductSku.clear();
      _cart.forEach((element) async {
        listOfProductSku.add(element.product.sku);
      });
      if (listOfProductSku.contains(product.sku)) {
        logNesto("Item already in cart");
      } else {
        logNesto("Adding product to magento cart");
        showSpinnerInCart();

        //logNesto("CART TOKEN:" + _cartToken);
        modifyShowProductSpinner(true, product);

        final url = MAGENTO_BASE_URL + "/$storeCode/V1" + "/carts/mine/items";

        final header = {
          "content-type": "application/json",
          "Authorization": "Bearer ${getAuthToken()}"
        };

        final body = jsonEncode({
          "cartItem": {
            "quote_id": _cartToken,
            "sku": product.sku,
            "qty": quantity
          }
        });
        logNesto("URL " + url.toString());
        logNesto("BODY " + body.toString());
        logNesto("HEADER " + header.toString());

        try {
          var response = await Dio().request(
            url,
            data: body,
            options: Options(
                method: 'POST',
                headers: header,
                receiveTimeout: 20000,
                sendTimeout: 20000),
          );

          logNestoCustom(
              message:
                  'ADD PRODUCT TO MAGENTO CART RESPONSE:' + response.toString(),
              logType: LogType.warning);

          var data = json.decode(response.toString()) as Map<String, dynamic>;

          hideSpinnerInCart();
          if (response.statusCode == 200) {
            //Dummy addition to dismiss spinner,Will be actually added after magento cart sync
            await updateMagentoQuantityOfCartItemAndAddToClientCart(
                product: product, data: data, quantity: quantity);
            //Dismiss spinner
            modifyShowProductSpinner(false, product);
            //Haptic feedback
            Vibrate.feedback(FeedbackType.success);
            if (shippingAddress != null && _cart.isNotEmpty) {
              addShippingInformation();
            } else {
              _clearMagentoTotals();
              notifyListeners();
            }
            //await getMagentoCart();
            //logging to firebase
            firebaseAnalytics.logAddToCart(
                itemId: product.sku,
                itemName: product.name,
                price: product.priceWithTax,
                currency: "AED",
                value: product.priceWithTax,
                quantity: quantity);
          } else {
            logNesto("ADD PRODUCT TO MAGENTO CART:" + "ERROR");
            getMagentoCart();
            _cartQueue.removeWhere((element) => element.sku == product.sku);
            _cart.removeWhere((element) => element.product.sku == product.sku);
            modifyShowProductSpinner(false, product);
            showProductOutOfStock = true;
            if (ENV == "production" || ENV == "staging") {
              errorMessage =
                  strings.CANNOT_ADD_ITEM_TO_THE_CART_PLEASE_TRY_AGAIN;
            } else {
              errorMessage = response.statusMessage;
            }
            notifyListeners();
          }
        } on DioError catch (e) {
          getMagentoCart();
          hideSpinnerInCart();
          if (e.type == DioErrorType.connectTimeout ||
              e.type == DioErrorType.receiveTimeout ||
              e.type == DioErrorType.sendTimeout) {
            logNestoCustom(message: e.toString(), logType: LogType.error);
          }
          logNestoCustom(message: e.toString(), logType: LogType.error);

          _cartQueue.removeWhere((element) => element.sku == product.sku);
          _cart.removeWhere((element) => element.product.sku == product.sku);
          modifyShowProductSpinner(false, product);
          showProductOutOfStock = true;
          if (ENV == "production" || ENV == "staging") {
            var errorMsg = json.decode(e.response.toString());
            if ((errorMsg["message"].toString() ==
                    "This product is out of stock.") ||
                (errorMsg["message"].toString() ==
                    "Product that you are trying to add is not available.")) {
              errorMessage = strings.Out_of_stock;
            } else {
              errorMessage =
                  strings.CANNOT_ADD_ITEM_TO_THE_CART_PLEASE_TRY_AGAIN;
            }
          } else {
            errorMessage = e.message;
          }
          notifyListeners();
        }
      }
    } else {
      await showCouponRemovalAlert(
          action: "ADD", product: product, quantity: quantity);
      // await getMagentoCart();
    }
  }

  Future updateMagentoQuantityOfCartItemAndAddToClientCart(
      {Product product, var data, int quantity}) async {
    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1" +
        "/customapi/products/${product.sku}?store_id=$storeId";

    logNesto("URL:" + url);
    final header = {"content-type": "application/json"};

    try {
      return http.get(Uri.parse(url), headers: header).then((response) {
        logNesto("SELECTED PRODUCT BY SKU RESPONSE:" + response.body);

        if (response.statusCode == 200) {
          var element = json.decode(response.body.toString()) as dynamic;

          Product product = Product.fromJson(element, true);

          bool isInCart = false;
          _cart.forEach((element) {
            if (element.product.sku == product.sku) {
              isInCart = true;
            }
          });

          if (listOfProductSku.contains(product.sku) || isInCart) {
            logNesto("Item already in cart");
          } else {
            _cart.add(CartItem(
              itemId: data["item_id"],
              product: product,
              quantity: quantity ?? 1,
              productInStockMagento: element["quantity_and_stock_status"]
                  ["is_in_stock"],
              quantityMagento: element["quantity_and_stock_status"]["qty"],
              minimumQuantity: element["min_qty"] ?? 0,
              maximumQuantity: element["max_qty"] ?? 10000,
              finalTax: double.parse(
                  data["extension_attributes"]["final_tax"].toString()),
              taxAmount: double.parse(
                  data["extension_attributes"]["item_tax_amount"].toString()),
              rowTotal: double.parse(
                  data["extension_attributes"]["item_row_total"].toString()),
              finalRowTotal: double.parse(
                  data["extension_attributes"]["final_row_total"].toString()),
              discountAmount: double.parse(
                  data["extension_attributes"]["discount_amount"].toString()),
            ));
          }
        } else {
          //TODO:NO RESULTS FOUND
        }
      });
    } finally {
      //http.close();
    }
  }

  Future updateProductQuantityInMagentoCart(
      {CartItem cartItem, bool isIncrease}) async {
    showSpinnerInCart();
    logNesto("Updating product quantity to magento cart:" +
        cartItem.itemId.toString());

    modifyShowProductSpinner(true, cartItem.product);

    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1" +
        "/carts/mine/items/${cartItem.itemId}";

    logNesto("URL:" + url.toString());

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    logNesto("HEADER:" + header.toString());

    final body = jsonEncode({
      "cartItem": {
        "quote_id": _cartToken,
        "sku": cartItem.product.sku,
        "qty": cartItem.quantity
      }
    });

    logNesto(body);

    var response;
    try {
      response = await Dio().request(
        url,
        data: body,
        options: Options(
            method: 'PUT',
            headers: header,
            receiveTimeout: 20000,
            sendTimeout: 20000),
      );

      logNestoCustom(
          message: 'UPDATE PRODUCT IN MAGENTO RESPONSE:' + response.toString(),
          logType: LogType.warning);

      modifyShowProductSpinner(false, cartItem.product);
      hideSpinnerInCart();
      if (response.statusCode == 200) {
        var decodedResponse =
            json.decode(response.toString()) as Map<String, dynamic>;
        CartItem rowPriceUpdatedCartItem = CartItem(
          itemId: cartItem.itemId,
          quantity: decodedResponse["qty"],
          quantityMagento: cartItem.quantityMagento,
          minimumQuantity: cartItem.minimumQuantity,
          maximumQuantity: cartItem.maximumQuantity,
          product: cartItem.product,
          productInStockMagento: cartItem.productInStockMagento,
          finalTax: double.parse(
              decodedResponse["extension_attributes"]["final_tax"].toString()),
          taxAmount: double.parse(decodedResponse["extension_attributes"]
                  ["item_tax_amount"]
              .toString()),
          rowTotal: double.parse(decodedResponse["extension_attributes"]
                  ["item_row_total"]
              .toString()),
          finalRowTotal: double.parse(decodedResponse["extension_attributes"]
                  ["final_row_total"]
              .toString()),
          discountAmount: double.parse(decodedResponse["extension_attributes"]
                  ["discount_amount"]
              .toString()),
        );
        //Dummy update product quantity in client cart
        updateProductQuantityInClientCart(rowPriceUpdatedCartItem);
        if (shippingAddress != null && _cart.isNotEmpty) {
          addShippingInformation();
        } else {
          _clearMagentoTotals();
          notifyListeners();
        }
        //firebase analytics logging
        if (isIncrease) {
          firebaseAnalytics.logAddToCart(
              itemId: cartItem.product.sku,
              itemName: cartItem.product.name,
              price: cartItem.product.priceWithTax,
              value: getProductTotal(rowPriceUpdatedCartItem),
              currency: "AED",
              quantity: cartItem.quantity);
        } else {
          firebaseAnalytics.logRemoveFromCart(
              itemId: cartItem.product.sku,
              itemName: cartItem.product.name,
              price: cartItem.product.priceWithTax,
              value: getProductTotal(rowPriceUpdatedCartItem),
              currency: "AED",
              quantity: cartItem.quantity);
        }
      } else {
        modifyShowProductSpinner(false, cartItem.product);
        getMagentoCart();
        showProductOutOfStock = true;
        var errorMsg = json.decode(response.toString());
        String errorMessageOnly = errorMsg["message"].toString();
        if (ENV == "production" || ENV == "staging") {
          if (errorMessageOnly == "The requested quantity is not available") {
            errorMessage = errorMessageOnly;
          } else if (errorMessageOnly ==
                  "The requested qty is not available\nThis product is out of stock." ||
              errorMessageOnly.contains("requested qty is not available")) {
            errorMessage = strings.Out_of_stock;
          } else if (errorMessageOnly ==
                  "There are no source items with the in stock status." ||
              errorMessageOnly
                  .contains("source items with the in stock status")) {
            errorMessage = strings.Out_of_stock;
          } else if (errorMessageOnly ==
                  "The requested qty exceeds the maximum qty allowed in shopping cart" ||
              errorMessageOnly.contains("maximum qty")) {
            errorMessage = strings.MAXIMUM_QUANTITY_REACHED;
          } else if (errorMessageOnly.contains("minimum qty")) {
            errorMessage = strings.PLEASE_MAINTAIN_THE_MINIMUM_QUANTITY;
          } else {
            errorMessage = errorMessageOnly;
          }
        } else {
          errorMessage = errorMessageOnly;
        }
        notifyListeners();
      }
    } on DioError catch (e) {
      getMagentoCart();
      hideSpinnerInCart();
      if (e.type == DioErrorType.connectTimeout ||
          e.type == DioErrorType.receiveTimeout ||
          e.type == DioErrorType.sendTimeout) {
        logNesto("UPDATE MAGENTO CART:" + e.message);
      }
      logNesto("UPDATE MAGENTO CART: e.message" + e.message);
      logNesto("UPDATE MAGENTO CART: e.response" + e.response.toString());

      modifyShowProductSpinner(false, cartItem.product);
      showProductOutOfStock = true;
      var errorMsg = json.decode(e.response.toString()) as Map<String, dynamic>;
      String errorMessageOnly = errorMsg["message"].toString();
      if (ENV == "production" || ENV == "staging") {
        if (errorMessageOnly == "The requested quantity is not available") {
          errorMessage = errorMessageOnly;
        } else if (errorMessageOnly ==
                "The requested qty is not available\nThis product is out of stock." ||
            errorMessageOnly.contains("qty is not available")) {
          errorMessage = strings.Out_of_stock;
        } else if (errorMessageOnly ==
                "There are no source items with the in stock status." ||
            errorMessageOnly.contains("stock status")) {
          errorMessage = strings.Out_of_stock;
        } else if (errorMessageOnly ==
                "The requested qty exceeds the maximum qty allowed in shopping cart" ||
            errorMessageOnly.contains("maximum qty")) {
          errorMessage = strings.MAXIMUM_QUANTITY_REACHED;
        } else if (errorMessageOnly.contains("minimum qty")) {
          errorMessage = strings.PLEASE_MAINTAIN_THE_MINIMUM_QUANTITY;
        } else {
          errorMessage = errorMessageOnly;
        }
      }
      notifyListeners();
    }
  }

  void updateProductQuantityInClientCart(CartItem cartItem) {
    _cart.forEach((element) {
      if (element.product.sku == cartItem.product.sku) {
        element.itemId = cartItem.itemId;
        element.quantity = cartItem.quantity;
        element.quantityMagento = cartItem.quantityMagento;
        element.minimumQuantity = cartItem.minimumQuantity;
        element.maximumQuantity = cartItem.maximumQuantity;
        element.product = cartItem.product;
        element.productInStockMagento = cartItem.productInStockMagento;
        element.finalTax = cartItem.finalTax;
        element.taxAmount = cartItem.taxAmount;
        element.rowTotal = cartItem.rowTotal;
        element.finalRowTotal = cartItem.finalRowTotal;
        element.discountAmount = cartItem.discountAmount;
        //Dismiss spinner
        modifyShowProductSpinner(false, cartItem.product);
        //Haptic feedback
        Vibrate.feedback(FeedbackType.success);
      }
    });
  }

  Future removeProductFromMagentoCart(CartItem cartItem, isFromDismiss) async {
    logNesto("BATMAN:Removing item from Magento cart");
    if (isFromDismiss) {
      modifyShowProductSpinner(true, cartItem.product);
    }
    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1" +
        "/carts/mine/items/${cartItem?.itemId}";

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    try {
      var response = await Dio().request(
        url,
        options: Options(
            method: 'DELETE',
            headers: header,
            receiveTimeout: 20000,
            sendTimeout: 20000),
      );

      logNesto('REMOVE FROM CART RESPONSE:' + response.toString());

      if (response.statusCode == 200) {
        if (!isFromDismiss) {
          _cart.removeWhere(
              (element) => cartItem.product.sku == element.product.sku);
          _cartQueue
              .removeWhere((element) => cartItem.product.sku == element.sku);
          Vibrate.feedback(FeedbackType.warning);
        }

        if (shippingAddress != null && _cart.isNotEmpty) {
          addShippingInformation();
        }

        LocalStorage localStorage = LocalStorage();
        await localStorage.removeItem(sku: cartItem.product.sku);

        //logging to firebase
        firebaseAnalytics.logRemoveFromCart(
          itemId: cartItem.product.sku,
          itemName: cartItem.product.name,
          price: cartItem.product.priceWithTax,
          value: getProductTotal(cartItem),
          currency: "AED",
          quantity: cartItem.quantity,
        );
      } else {
        _cart.add(cartItem);
        _cartQueue.add(cartItem.product);
        getMagentoCart();
        notifyListeners();
        if (ENV == "production") {
          notificationServices.showErrorNotification(
              strings.CANNOT_REMOVE_ITEM_FROM_CART_PLEASE_TRY_AGAIN_LATER);
        } else {
          notificationServices.showErrorNotification(response.statusMessage);
        }
      }
      modifyShowProductSpinner(false, cartItem.product);
      if (shippingAddress == null) hideSpinnerInCart();
      notifyListeners();
    } on DioError catch (e) {
      hideSpinnerInCart();
      _cart.add(cartItem);
      _cartQueue.add(cartItem.product);
      getMagentoCart();
      modifyShowProductSpinner(false, cartItem.product);
      notifyListeners();
      if (!e.message.contains("404")) {
        if (ENV == "production") {
          notificationServices.showErrorNotification(
              strings.CANNOT_REMOVE_ITEM_FROM_CART_PLEASE_TRY_AGAIN_LATER);
        } else {
          notificationServices.showErrorNotification(e.message);
        }
      }
    }
  }

  Future addAllProductsToMagentoCart() async {
    await createMagentoCart();
    _cart.forEach((element) {
      addProductToMagentoCart(element.product, element.quantity);
    });
  }

  bool showCouponRemovedError = false;

  Future addShippingInformation() {
    logNesto("ADDING SHIPPING IFO");
    showSpinnerInCart();

    final url = MAGENTO_BASE_URL +
        "/$storeCode/V1" +
        "/carts/mine/shipping-information";

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    logNesto("HEADER:" + header.toString());

    final body = jsonEncode({
      "addressInformation": {
        "shipping_address": {
          "region": shippingAddress.region,
          "region_id": 43,
          "region_code": "AE",
          "country_id": "AE",
          "street": [shippingAddress.street],
          "postcode": "",
          "city": shippingAddress.city,
          "firstname": shippingAddress.name,
          "lastname": ".",
          "email": shippingAddress.email,
          "telephone": shippingAddress.telephone,
        },
        "billing_address": {
          "region": shippingAddress.region,
          "region_id": 43,
          "region_code": "AE",
          "country_id": "AE",
          "street": [shippingAddress.street],
          "postcode": "",
          "city": shippingAddress.city,
          "firstname": shippingAddress.name,
          "lastname": ".",
          "email": shippingAddress.email,
          "telephone": shippingAddress.telephone,
        },
        "shipping_carrier_code": "tablerate",
        "shipping_method_code": "bestway"
      }
    });

    logNesto("BODY:" + body);

    return http
        .post(Uri.tryParse(url), headers: header, body: body)
        .then((response) {
      logNesto("SHIPPING INFO RESPONSE:" + response.body);

      if (response.statusCode == 200) {
        showCouponRemovalAlertAfterAppRestart = false;
        var data = jsonDecode(response.body) as Map<String, dynamic>;

        var totalsData = data["totals"];

        if (totalsData != null) {
          var shippingFee = totalsData["shipping_amount"];
          var subTotal = totalsData["subtotal"];
          var grandTotal = totalsData["base_grand_total"];
          var tax = totalsData["tax_amount"];
          var discount = totalsData["discount_amount"];
          var code = totalsData["coupon_code"];

          _magentoShippingFee = shippingFee.toDouble();
          _magentoSubTotal = subTotal.toDouble();
          _magentoGrandTotal = grandTotal.toDouble();
          _magentoTax = tax.toDouble();
          _magentoDiscount = discount.toDouble();
          _couponCode = code ?? "";
          if (_couponCode != null && _couponCode != "") {
            getMinimumAmountRequiredForCoupon();
          }
          if (_couponCode.isNotEmpty) {
            couponCodeSubmitStatus = COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY;
          } else {
            //Show an alert when coupon is removed below limit
            if (couponCodeSubmitStatus ==
                COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY) {
              showCouponRemovedError = true;
              notifyListeners();
            }
            couponCodeSubmitStatus = COUPON_CODE_STATUS.NOT_APPLIED;
          }
          logNesto("MAGENTO COUPON CODE:" + _couponCode);
          logNesto("ADDED MAGENTO TOTALS");
          notifyListeners();
        }
      } else {
        //TODO:NO RESULTS FOUND
      }
      Future.delayed(Duration(seconds: 1, milliseconds: 750), () {
        hideSpinnerInCart();
        notifyListeners();
      });
    });
  }

  Future placeOrder(String paymentMethod, String latitude, String longitude,
      bool enableSubstitution, String deliveryNote) async {
    logNesto("Placing Order:COD");

    final url = MAGENTO_BASE_URL + "/$storeCode/V1" + "/customapi/createorder";

    logNesto("URL:" + url);

    final header = {
      "content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    String cartNotes = "";
    try {
      cartNotes = await LocalStorage().deliveryNote ?? "";
    } catch (e) {
      print("ERR: $e");
      cartNotes = "";
    }

    final body = jsonEncode({
      "quote_id": _cartToken,
      "payment_method": paymentMethod,
      "custom_data": {
        "delivery_date": selectedDateInStringForDelivery,
        "from": selectedFromTimeForDelivery,
        "to": selectedToTimeForDelivery,
        "lat": latitude,
        "long": longitude,
        "timeslot_id": selectedTimeSlotIdForDelivery,
        "store_id": storeId,
        "is_substitution": enableSubstitution,
        "delivery_notes": deliveryNote + cartNotes ?? ''
      },
      "reference_id": paymentMethod == 'ngeniusonline' ? _orderRef ?? '' : '',
    });

    logNesto("BODY:" + body);

    return http
        .post(Uri.tryParse(url), headers: header, body: body)
        .then((response) async {
      logNesto(response.body);

      logNesto("PLACING ORDER NGENIUS STATUS CODE:" +
          response.statusCode.toString());
      // if (response.statusCode == 200) {
      var responseBody =
          json.decode(response.body.toString()) as Map<String, dynamic>;

      if (responseBody["success"] != null) {
        showCouponRemovalAlertAfterAppRestart = false;
        _orderId = responseBody["orderid"];
        incrementId = responseBody["incrementid"];
        logNesto("ORDER ID:" + _orderId);
        // await sendTimeSlotToBackend(
        //     latitude, longitude, enableSubstitution, deliveryNote);
        // modifyOrderSuccess(true);
        //firebase analytics logging.
        orderSuccess = true;
        firebaseAnalytics.logPurchase(
            paymentType: "cash_on_delivery",
            currency: "AED",
            location: shippingAddress?.city,
            cartToken: _cartToken,
            deliveryDate: selectedDateInStringForDelivery,
            deliveryTime:
                selectedFromTimeForDelivery + ' - ' + selectedToTimeForDelivery,
            timeslotID: selectedTimeSlotIdForDelivery,
            storeID: storeId.toString(),
            affiliation: "Mobile Application",
            value: _magentoGrandTotal.toString(),
            tax: _magentoTax.toString(),
            shipping: _magentoShippingFee.toString(),
            cartID: _cartToken,
            orderID: _orderId,
            grandTotal: grandTotal,
            discount: _magentoDiscount);
        await LocalStorage().clearCart();
      } else {
        //ERROR PLACING ORDER
        getMagentoCart();
        addShippingInformation();

        var decodedResponse =
            json.decode(response.body.toString()) as Map<String, dynamic>;
        int _code = decodedResponse['code'] ?? 0;
        String _message =
            (decodedResponse['message'] ?? decodedResponse['msg'])?.toString();
        if (_message.contains("Minimum Order Required AED")) {
          errorMessage = _message.replaceAll(
              "Minimum Order Required AED", strings.SUBTOTAL_SHOULD_BE_ATLEAST);
        } else if (_code == 1062) {
          errorMessage = strings.ITEMS_IN_THIS_CART_HAS_BEEN_ORDERED;
          flushCart = true;
        } else if (_message.contains("minimum subtotal")) {
          errorMessage = _message;
        } else if (_message?.contains('Payment Error') ?? false) {
          errorMessage = _message;
        } else {
          if (ENV == 'production') {
            errorMessage =
                strings.COULD_NOT_COMPLETE_THE_REQUEST_SOMETHING_WENT_WRONG;
          } else {
            errorMessage = _message;
          }
        }
        modifyOrderError(true);
      }
      notifyListeners();
    });
  }

  Future sendTimeSlotToBackend(String latitude, String longitude,
      bool enableSubstitution, String deliveryNote,
      {errorCount = 1}) {
    logNesto("Sending time slot to backend");

    final url =
        MAGENTO_BASE_URL + "/$storeCode/V1" + "/delivery_date/save_data";

    logNesto("URL:" + url);

    final header = {
      "Content-type": "application/json",
      "Authorization": "Bearer ${getAuthToken()}"
    };

    logNesto("HEADER:" + header.toString());

    //Double quotes while passing fix
    String orderIdInString = _orderId.substring(1, _orderId.length - 1);
    logNesto("ORDER ID IN STRING:" + orderIdInString);

    final body = jsonEncode({
      "delivery_date": selectedDateInStringForDelivery,
      "from": selectedFromTimeForDelivery,
      "to": selectedToTimeForDelivery,
      "lat": latitude,
      "long": longitude,
      "order_id": orderIdInString,
      "timeslot_id": selectedTimeSlotIdForDelivery,
      "store_id": storeId,
      "is_substitution": enableSubstitution,
      "delivery_notes": deliveryNote ?? ''
    });

    logNesto("BODY:" + body.toString());

    return http
        .post(Uri.tryParse(url), headers: header, body: body)
        .then((response) async {
      logNesto("TIMESLOT RESPONSE:" + response.body);

      if (response.statusCode != 200) {
        await handleErrorForSendTimeSlotToBackend(
            response.statusCode.toString(),
            errorCount,
            latitude,
            longitude,
            enableSubstitution,
            deliveryNote);
      }
    }).catchError((err) async => await handleErrorForSendTimeSlotToBackend(err,
            errorCount, latitude, longitude, enableSubstitution, deliveryNote));
  }

  // This function will be called max 3 times. If it fails for the thrid
  // time, then the error is silently ignored. This function should be removed
  // when single orderplacing api is implemented.
  Future handleErrorForSendTimeSlotToBackend(err, errorCount, latitude,
      longitude, enableSubstitution, deliveryNote) async {
    if (errorCount < 3) {
      await sendTimeSlotToBackend(
          latitude, longitude, enableSubstitution, deliveryNote,
          errorCount: errorCount + 1);
    }
  }

  String getDateText(DateTime date) {
    return DateFormat("MMMM d").format(date);
  }

  Future paymentGateway(bool _enableSubstitution, String _deliveryNote,
      {bool isFromCheckOut = false}) async {
    enableSubstitution = _enableSubstitution;
    deliveryNote = _deliveryNote;
    logNesto("PAYMENT GATEWAY CREATE ORDER");
    String url = PAYMENT_GATEWAY_URL + "/createorder";
    var data = {
      "env": ENV,
      "quot_id": _cartToken,
      "currencyCode": "AED",
      "value": double.parse(grandTotal.toString()),
      "redirectUrl": PAYMENT_REDIRECT_URL,
      "sub_total": double.parse(subTotal.toString()),
      "store_code": storeCode,
      "sap_website_id": sapWebsiteId
    };

    logNesto('data>>>>>>>>>$data');
    var encodedJson = jsonEncode(data);
    try {
      Response response = await Dio().post(url, data: encodedJson);
      logNesto(response);

      var decodedResponse =
          json.decode(response.toString()) as Map<String, dynamic>;
      if (response.statusCode == 200 &&
          (decodedResponse['error'] ?? false) != true) {
        _orderRef = decodedResponse["reference_id"];
        paymentGatewayUrl = decodedResponse["payment_link"];
        if (paymentGatewayUrl == null || paymentGatewayUrl == '') {
          errorMessage = strings.CARD_PAYMENT_IS_NOT_AVAILABLE_AT_THE_MOMENT;
          modifyOrderError(true);
          notifyListeners();
        } else {
          modifyLaunchNGenius(true);
          notifyListeners();
          //firbase analytics logging
          firebaseAnalytics.logPurchase(
              paymentType: "ngenius_online",
              currency: "AED",
              location: shippingAddress?.city,
              cartToken: _cartToken,
              deliveryDate: selectedDateInStringForDelivery,
              deliveryTime: selectedFromTimeForDelivery +
                  ' - ' +
                  selectedToTimeForDelivery,
              timeslotID: selectedTimeSlotIdForDelivery,
              storeID: storeId.toString(),
              transactionID: _orderRef,
              affiliation: "Mobile Application",
              value: _magentoGrandTotal.toString(),
              tax: _magentoTax.toString(),
              shipping: _magentoShippingFee.toString(),
              cartID: _cartToken,
              orderID: _orderId,
              grandTotal: grandTotal,
              discount: _magentoDiscount);
        }
      } else {
        // errorMessage = "Card payment not available at the moment";
        if (isFromCheckOut) {
          addShippingInformation();
        }

        errorMessage = decodedResponse['msg']?.toString();
        int _code = decodedResponse['code'] ?? 0;
        if (_code == 1062) {
          errorMessage = strings.ITEMS_IN_THIS_CART_HAS_BEEN_ORDERED;
          flushCart = true;
        }
        modifyOrderError(true);
        notifyListeners();
      }
    } catch (e) {
      logNesto(e);
    }
  }

  Future cancelOrder() async {
    logNesto("PAYMENT GATEWAY CANCEL ORDER");

    String url = PAYMENT_GATEWAY_URL + "/cancel_quote";

    //TODO:REPLACE THIS WITH ACTUAL VALUE
    try {
      Response response = await Dio().post(url, data: {
        "env": ENV,
        "quot_id": _cartToken,
      });
      logNesto(response);

      if (response.statusCode == 200) {
        logNesto("PAYMENT CANCEL SUCCESSFUL");
        notifyListeners();
      }
    } catch (e) {
      logNesto(e);
    }
  }

  Future checkPaymentStatus() async {
    logNesto("Check payment status");

    String url = PAYMENT_GATEWAY_URL + "/payment_status?order_ref=$_orderRef";

    logNesto("URL:" + url);

    try {
      Response response = await Dio().get(url);
      logNesto(response);

      var decodedResponse =
          json.decode(response.toString()) as Map<String, dynamic>;

      String status = decodedResponse["status"];
      logNesto("PAYMENT STATUS:" + status);

      if (status == "AUTHORISED")
        paymentStatus = PAYMENT_STATUS.AUTHORIZED;
      else if (status == "CAPTURED")
        paymentStatus = PAYMENT_STATUS.CAPTURED;
      else if (status == "FAILED") paymentStatus = PAYMENT_STATUS.FAILED;
      logNesto("PAYMENT STATUS MODIFIED");
      notifyListeners();
    } catch (e) {
      logNesto(e);
    }
  }

  bool hasTimeSlotFetchFinished = false;

  Future fetchTimeSlots() async {
    logNesto("FETCH TIMESLOT");
    clearTimeSlots();

    DateTime today = DateTime.now();
    DateTime tomorrow = today.add(Duration(days: 1));

    String todayString = today.year.toString() +
        "-" +
        today.month.toString() +
        "-" +
        today.day.toString();
    String tomorrowString = tomorrow.year.toString() +
        "-" +
        tomorrow.month.toString() +
        "-" +
        tomorrow.day.toString();

    logNesto("DATE today:" + todayString);
    logNesto("DATE tomorrow:" + tomorrowString);

    final todayUrl = MAGENTO_BASE_URL +
        "/V1" +
        "/delivery_date/$todayString?store_id=$storeId";
    final tomorrowUrl = MAGENTO_BASE_URL +
        "/V1" +
        "/delivery_date/$tomorrowString?store_id=$storeId";

    logNesto("today URL:" + todayUrl);
    logNesto("tomorrow URL:" + tomorrowUrl);

    final header = {
      "content-type": "application/json",
    };

    Future.wait([
      http.get(Uri.tryParse(todayUrl), headers: header),
      http.get(Uri.tryParse(tomorrowUrl), headers: header)
    ]).then((responses) async {
      var todayResponse = responses[0];
      var tomorrowResponse = responses[1];
      //logNesto("TODAY TIMESLOT FETCH RESPONSE:" + todayResponse.body);
      //logNesto("TOMORROW TIMESLOT FETCH RESPONSE:" + tomorrowResponse.body);

      if (todayResponse.statusCode == 200) {
        var timeSlotsData = jsonDecode(todayResponse.body) as List<dynamic>;
        var timeSlotsTomorrowData =
            jsonDecode(tomorrowResponse.body) as List<dynamic>;
        await timeSlotsDataMapping(
            todayTimeSlot: timeSlotsData,
            tomorrowTimeSlot: timeSlotsTomorrowData);
      } else {
        fetchingTimeslot = false;
      }
    }).onError((error, stackTrace) {
      fetchingTimeslot = false;
    });
  }

  Future timeSlotsDataMapping({var todayTimeSlot, var tomorrowTimeSlot}) async {
    clearTimeSlots();

    if (todayTimeSlot.length >= 9) {
      var timeSlotId = todayTimeSlot[0];
      timeSlotDetails = {
        "startDate": DateTime.tryParse(todayTimeSlot[7]),
        "endDate": DateTime.tryParse(todayTimeSlot[8])
      };
      var data = todayTimeSlot[9] as Map<dynamic, dynamic>;
      List<dynamic> timeLimitData = data["default"]["time_limits"];
      List<TimeSlot> loadedTimeSlots = [];
      timeLimitData.forEach((element) {
        loadedTimeSlots.add(TimeSlot(
          id: timeSlotId,
          position: int.tryParse(element["position"]),
          recordId: element["record_id"],
          fromTime: element["from"],
          toTime: element["to"],
          extraCharge: element["extra_charge"],
          quoteLimit: element["quote_limit"],
          cutOffTime: element["cut_off_time"],
          startTime: element["start_time"],
          slotType: element["slot_type"],
        ));
      });
      _todayTimeSlots.clear();
      _todayTimeSlots.addAll(loadedTimeSlots);
      _todayTimeSlots.sort((a, b) => a.position.compareTo(b.position));
    }

    if (tomorrowTimeSlot.length >= 9) {
      var timeSlotId = tomorrowTimeSlot[0];
      timeSlotDetails = {
        "startDate": DateTime.tryParse(tomorrowTimeSlot[7]),
        "endDate": DateTime.tryParse(tomorrowTimeSlot[8])
      };
      var data = tomorrowTimeSlot[9] as Map<dynamic, dynamic>;
      List<dynamic> timeLimitData = data["default"]["time_limits"];
      List<TimeSlot> loadedTimeSlots = [];
      timeLimitData.forEach((element) {
        loadedTimeSlots.add(TimeSlot(
          id: timeSlotId,
          position: int.tryParse(element["position"]),
          recordId: element["record_id"],
          fromTime: element["from"],
          toTime: element["to"],
          extraCharge: element["extra_charge"],
          quoteLimit: element["quote_limit"],
          cutOffTime: element["cut_off_time"],
          startTime: element["start_time"],
          slotType: element["slot_type"],
        ));
      });
      //logNesto("tomorrow length: " + loadedTimeSlots.length.toString());
      _tomorrowTimeSlots.clear();
      _tomorrowTimeSlots.addAll(loadedTimeSlots);
      _tomorrowTimeSlots.sort((a, b) => a.position.compareTo(b.position));
    }
    fetchingTimeslot = false;
    updateAvailabelTimeSlotString();
    hasTimeSlotFetchFinished = true;
    notifyListeners();
  }

  void clearTimeSlots() {
    hasTimeSlotFetchFinished = false;
    fetchingTimeslot = true;
    _todayTimeSlots.clear();
    _tomorrowTimeSlots.clear();
    timeSlotDetails.clear();
    notifyListeners();
  }

  ////####Section#### {Cart Management Functions}

  Set<CartItem> _cart = {};

  Set<CartItem> get cart {
    final _cartList = _cart.toList();
    _cartList.sort((a, b) => a.product.name.compareTo(b.product.name));

    return _cartList.toSet();
  }

  Set<Product> _cartQueue = {};

  Set<Product> _wishlist = {};

  Set<Product> get wishlist {
    return _wishlist;
  }

  int get cartCount {
    return _cart.length;
  }

  List<String> get uniqueSubCategories {
    List<String> subCats = [];
    _wishlist.forEach((element) {
      if (!subCats.contains(element.subCategory.name)) {
        subCats.add(element.subCategory.name);
      }
    });
    return subCats;
  }

  List<String> get allMerchandiseCategoryNamesOfASubCategory {
    // logNesto("ALL MERCHANDISE CATEGORY NAMES");
    List<String> names = [];

    _selectedSubCategory.merchandiseCategories.forEach((element) {
      if (!names.contains(element.name)) names.add(element.name);
    });
    return names;
  }

  List<String> get getCategoryNavigationStrings {
    List<String> names = [];

    var category = categoryOfSelectedCategoryId();

    if (category is MainCategory) {
      MainCategory _mainCategory = category;
      _mainCategory.subCategories.forEach((element) {
        if (!names.contains(element.name)) names.add(element.name);
      });
    } else if (category is SubCategory) {
      SubCategory _subCategory = category;
      _subCategory.merchandiseCategories.forEach((element) {
        if (!names.contains(element.name)) names.add(element.name);
      });
    } else if (category is MerchandiseCategory) {
      SubCategory _subCategory = subCategoryParentForNavigation;
      _subCategory.merchandiseCategories.forEach((element) {
        if (!names.contains(element.name)) names.add(element.name);
      });
    }

    return names;
    //For main categories
  }

  List<int> get getCategoryNavigationIds {
    List<int> ids = [];

    var category = categoryOfSelectedCategoryId();

    if (category is MainCategory) {
      MainCategory _mainCategory = category;
      _mainCategory.subCategories.forEach((element) {
        if (!ids.contains(element.id)) ids.add(element.id);
      });
      ids.insert(0, parentCategoryIdForNavigation);
    } else if (category is SubCategory) {
      SubCategory _subCategory = category;
      _subCategory.merchandiseCategories.forEach((element) {
        if (!ids.contains(element.id)) ids.add(element.id);
      });
      ids.insert(0, parentCategoryIdForNavigation);
    } else if (category is MerchandiseCategory) {
      SubCategory _subCategory = subCategoryParentForNavigation;
      _subCategory.merchandiseCategories.forEach((element) {
        if (!ids.contains(element.id)) ids.add(element.id);
      });
      ids.insert(0, parentCategoryIdForNavigation);
      selectedMerchandiseCategoryIndex =
          ids.indexOf(_selectedCategoryIdForNavigation);
    }

    return ids;
    //For main categories
  }

  dynamic categoryOfSelectedCategoryId() {
    var valueToReturn;

    //Check for main categories
    for (var mainCats in _mainCategories) {
      if (mainCats.id == _selectedCategoryIdForNavigation) {
        valueToReturn = mainCats;
        parentCategoryIdForNavigation = mainCats.id;
        isMerchandiseCategorySelected = false;
        selectedCategoryName = mainCats.name;
      }
    }

    _mainCategories.forEach((element) {
      for (var subCats in element.subCategories) {
        if (subCats.id == _selectedCategoryIdForNavigation) {
          valueToReturn = subCats;
          parentCategoryIdForNavigation = element.id;
          isMerchandiseCategorySelected = false;
          selectedCategoryName = subCats.name;
        }
      }
    });

    _mainCategories.forEach((element) {
      element.subCategories.forEach((subElement) {
        for (var merchCats in subElement.merchandiseCategories) {
          if (merchCats.id == _selectedCategoryIdForNavigation) {
            valueToReturn = merchCats;
            subCategoryParentForNavigation = subElement;
            parentCategoryIdForNavigation = subElement.id;
            isMerchandiseCategorySelected = true;
            selectedCategoryName = merchCats.name;
          }
        }
      });
    });

    return valueToReturn;
  }

  getHorizontalCategoryList(int catId) {
    print("\n\n=======================>");
    print("CAT ID: $catId");
    print("<=======================\n\n");

    var itemToReturn;
    for (var mainCat in _mainCategories) {
      if (mainCat.id == catId) {
        itemToReturn = mainCat;
        break;
      } else {
        for (var subCat in mainCat.subCategories) {
          if (subCat.id == catId) {
            itemToReturn = subCat;
            break;
          } else {
            for (var merchCat in subCat.merchandiseCategories) {
              if (merchCat.id == catId) {
                itemToReturn = [merchCat, subCat];
                break;
              }
            }
          }
        }
      }
    }

    return itemToReturn;
  }

  Future showCouponRemovalAlert(
      {String action,
      bool isFromCartScreen,
      Product product,
      CartItem cartItem,
      int quantity,
      bool isFromDismiss = false,
      bool alertIsAlreadyShown}) async {
    await notificationServices.showCustomDialog(
        title: strings.REMOVE_COUPON,
        description:
            strings.IF_YOU_UPDATE_THE_CART_APPLIEDCOUPON_WILL_BE_REMOVED,
        negativeText: strings.NO,
        positiveText: strings.YES,
        onNopressed: () {
          getMagentoCart();
        },
        action: () async {
          await removeCouponCode(calledFromCouponRemovalAlertDialogue: true);
          switch (action) {
            case "ADD":
              {
                await addProductToMagentoCart(product, quantity);
              }
              break;
            case "INCREASE":
              {
                await increaseQuantity(product);
              }
              break;
            case "DECREASE":
              {
                await decreaseQuantity(
                    isFromCartScreen: isFromCartScreen, product: product);
              }
              break;
            case "REMOVE":
              {
                await removeFromCart(
                    cartItem: cartItem,
                    isFromDismiss: isFromDismiss,
                    isFromCartScreen: isFromCartScreen,
                    alertIsAlreadyShown: alertIsAlreadyShown);
                // await getMagentoCart();
              }
              break;
          }
        });
  }

  void addToCart(Product product) async {
    bool isProductInQueue = false;
    bool isProductInCart = false;
    if ((product.minimumQuantity > 1)) {
      notificationServices.showCustomDialog(
          title: strings.CHANGE_QUANTITY,
          description:
              strings.MINIMUM_QUANTITY_REQUIRED_TO_PURCHASE_THIS_ITEM_IS +
                  product.minimumQuantity.toString() +
                  strings.DO_YOU_wANT_TO_CHANGE_QANTIITY_TO +
                  product.minimumQuantity.toString(),
          negativeText: strings.NO,
          positiveText: strings.YES,
          action: () async {
            _cartQueue.forEach((element) {
              if (element.sku == product.sku) {
                isProductInQueue = true;
              }
            });

            _cart.forEach((element) {
              if (element.product.sku == product.sku) {
                isProductInQueue = true;
              }
            });

            if (!isProductInQueue || !isProductInCart) {
              logNesto("ADDING ITEM TO CART");
              _cartQueue.add(product);
              await addProductToMagentoCart(product, product.minimumQuantity);
            }
          });
    } else {
      _cartQueue.forEach((element) {
        if (element.sku == product.sku) {
          isProductInQueue = true;
        }
      });

      _cart.forEach((element) {
        if (element.product.sku == product.sku) {
          isProductInQueue = true;
        }
      });

      if (!isProductInQueue || !isProductInCart) {
        logNesto("ADDING ITEM TO CART");
        _cartQueue.add(product);
        await addProductToMagentoCart(product, 1);
      }
    }
  }

  Future removeFromCart(
      {CartItem cartItem,
      bool isFromDismiss = false,
      bool isFromCartScreen,
      bool alertIsAlreadyShown}) async {
    if (!showCouponRemovalAlertAfterAppRestart) {
      logNesto('Removing from cart');
      if (!isFromDismiss) {
        modifyShowProductSpinner(true, cartItem.product);
      }
      showSpinnerInCart();
      if (isFromDismiss) {
        _cart.removeWhere(
            (element) => cartItem.product.sku == element.product.sku);
        _cartQueue
            .removeWhere((element) => cartItem.product.sku == element.sku);
        Vibrate.feedback(FeedbackType.warning);
      }

      if (!isFromCartScreen) {
        notifyListeners();
      } else {
        if (_cart.isEmpty) notifyListeners();
      }
      await removeProductFromMagentoCart(cartItem, isFromDismiss);
    } else {
      await showCouponRemovalAlert(
          action: "REMOVE",
          cartItem: cartItem,
          isFromDismiss: isFromDismiss,
          isFromCartScreen: isFromCartScreen,
          alertIsAlreadyShown: alertIsAlreadyShown);
      notifyListeners();
      // await getMagentoCart();
    }
    return;
  }

  void minMaxQuantityCheckForIncrementCase(CartItem cartItem) async {
    int cartQuantityAfterIncrement = cartItem.quantity + 1;
    if (cartQuantityAfterIncrement < cartItem.minimumQuantity) {
      if ((cartItem.minimumQuantity > cartItem.quantityMagento) &&
          (!cartItem.product.isBackOrder)) {
        notificationServices.showCustomDialog(
            title: strings.CHANGE_QUANTITY,
            description: strings.Only +
                "${cartItem.quantityMagento}" +
                strings.IN_STOCK_DO_YOU_WANT_TO_CHANGE_QUANTITY_TO +
                "${cartItem.quantityMagento}.",
            negativeText: strings.NO,
            positiveText: strings.YES,
            action: () async {
              CartItem cartItemWithUpdatedQuantity = CartItem(
                  itemId: cartItem.itemId,
                  product: cartItem.product,
                  productInStockMagento: cartItem.productInStockMagento,
                  quantity: cartItem.quantityMagento,
                  quantityMagento: cartItem.quantityMagento,
                  maximumQuantity: cartItem.maximumQuantity,
                  minimumQuantity: cartItem.minimumQuantity,
                  rowTotal: cartItem.rowTotal,
                  finalRowTotal: cartItem.finalRowTotal,
                  taxAmount: cartItem.taxAmount,
                  finalTax: cartItem.finalTax,
                  discountAmount: cartItem.discountAmount);
              await updateProductQuantityInMagentoCart(
                  cartItem: cartItemWithUpdatedQuantity, isIncrease: true);
            });
      } else {
        notificationServices.showCustomDialog(
            title: strings.INCREASE_QUANTITY,
            description:
                strings.MINIMUM_QUANTITY_REQUIRED_TO_ORDER_THIS_ITEM_IS +
                    "${cartItem.minimumQuantity}" +
                    strings.DO_YOU_WANT_TO_CHANGE_QUANTITY_TO +
                    "${cartItem.minimumQuantity}.",
            negativeText: strings.NO,
            positiveText: strings.YES,
            action: () async {
              CartItem cartItemWithUpdatedQuantity = CartItem(
                  itemId: cartItem.itemId,
                  product: cartItem.product,
                  productInStockMagento: cartItem.productInStockMagento,
                  quantity: cartItem.minimumQuantity,
                  quantityMagento: cartItem.quantityMagento,
                  maximumQuantity: cartItem.maximumQuantity,
                  minimumQuantity: cartItem.minimumQuantity,
                  rowTotal: cartItem.rowTotal,
                  finalRowTotal: cartItem.finalRowTotal,
                  taxAmount: cartItem.taxAmount,
                  finalTax: cartItem.finalTax,
                  discountAmount: cartItem.discountAmount);
              await updateProductQuantityInMagentoCart(
                  cartItem: cartItemWithUpdatedQuantity, isIncrease: true);
            });
      }
    } else if (cartQuantityAfterIncrement > cartItem.maximumQuantity) {
      notificationServices.showErrorNotification(
          strings.MAXIMUM_QUANTITY_ALLOWED_TO_PURCHASE_THIS_ITEM_IS +
              "${cartItem.maximumQuantity}.");
    } else if ((cartQuantityAfterIncrement >= cartItem.minimumQuantity) &&
        (cartQuantityAfterIncrement <= cartItem.maximumQuantity)) {
      CartItem cartItemWithUpdatedQuantity = CartItem(
          itemId: cartItem.itemId,
          product: cartItem.product,
          productInStockMagento: cartItem.productInStockMagento,
          quantity: cartItem.quantity + 1,
          quantityMagento: cartItem.quantityMagento,
          maximumQuantity: cartItem.maximumQuantity,
          minimumQuantity: cartItem.minimumQuantity,
          rowTotal: cartItem.rowTotal,
          finalRowTotal: cartItem.finalRowTotal,
          taxAmount: cartItem.taxAmount,
          finalTax: cartItem.finalTax,
          discountAmount: cartItem.discountAmount);
      updateProductQuantityInMagentoCart(
          cartItem: cartItemWithUpdatedQuantity, isIncrease: true);
    } else {
      CartItem cartItemWithUpdatedQuantity = CartItem(
          itemId: cartItem.itemId,
          product: cartItem.product,
          productInStockMagento: cartItem.productInStockMagento,
          quantity: cartItem.quantity + 1,
          quantityMagento: cartItem.quantityMagento,
          maximumQuantity: cartItem.maximumQuantity,
          minimumQuantity: cartItem.minimumQuantity,
          rowTotal: cartItem.rowTotal,
          finalRowTotal: cartItem.finalRowTotal,
          taxAmount: cartItem.taxAmount,
          finalTax: cartItem.finalTax,
          discountAmount: cartItem.discountAmount);
      await updateProductQuantityInMagentoCart(
          cartItem: cartItemWithUpdatedQuantity, isIncrease: true);
    }
  }

  Future quantityRemainingCheckIncrementCase(CartItem cartItem) async {
    if ((cartItem.quantity) < cartItem.quantityMagento) {
      minMaxQuantityCheckForIncrementCase(cartItem);
    } else if ((cartItem.quantity) == cartItem.quantityMagento) {
      notificationServices.showErrorNotification(strings.Out_of_stock);
    } else if ((cartItem.quantity) > cartItem.quantityMagento) {
      if ((cartItem.quantityMagento) > cartItem.maximumQuantity) {
        notificationServices.showCustomDialog(
            title: strings.CHANGE_QUANTITY,
            description:
                "${strings.max_quantity_allowed_toast_error} ${cartItem.maximumQuantity}" +
                    strings.DO_YOU_WANT_TO_CHANGE_QUANTITY_TO +
                    "${cartItem.maximumQuantity}.",
            negativeText: strings.NO,
            positiveText: strings.YES,
            action: () async {
              CartItem cartItemWithUpdatedQuantity = CartItem(
                  itemId: cartItem.itemId,
                  product: cartItem.product,
                  productInStockMagento: cartItem.productInStockMagento,
                  quantity: cartItem.maximumQuantity,
                  quantityMagento: cartItem.quantityMagento,
                  maximumQuantity: cartItem.maximumQuantity,
                  minimumQuantity: cartItem.minimumQuantity,
                  rowTotal: cartItem.rowTotal,
                  finalRowTotal: cartItem.finalRowTotal,
                  taxAmount: cartItem.taxAmount,
                  finalTax: cartItem.finalTax,
                  discountAmount: cartItem.discountAmount);
              await updateProductQuantityInMagentoCart(
                  cartItem: cartItemWithUpdatedQuantity, isIncrease: false);
            });
      } else {
        notificationServices.showCustomDialog(
            title: strings.DECREASE_QUANTITY,
            description: strings.Only +
                "${cartItem.quantityMagento}" +
                strings.IN_STOCK_DO_YOU_WANT_TO_DECREASE_QUANTITY_TO +
                "${cartItem.quantityMagento}.",
            negativeText: strings.NO,
            positiveText: strings.YES,
            action: () async {
              CartItem cartItemWithUpdatedQuantity = CartItem(
                  itemId: cartItem.itemId,
                  product: cartItem.product,
                  productInStockMagento: cartItem.productInStockMagento,
                  quantity: cartItem.quantityMagento,
                  quantityMagento: cartItem.quantityMagento,
                  maximumQuantity: cartItem.maximumQuantity,
                  minimumQuantity: cartItem.minimumQuantity,
                  rowTotal: cartItem.rowTotal,
                  finalRowTotal: cartItem.finalRowTotal,
                  taxAmount: cartItem.taxAmount,
                  finalTax: cartItem.finalTax,
                  discountAmount: cartItem.discountAmount);
              await updateProductQuantityInMagentoCart(
                  cartItem: cartItemWithUpdatedQuantity, isIncrease: false);
            });
      }
    }
  }

  Future increaseQuantity(Product product) async {
    if (!showCouponRemovalAlertAfterAppRestart) {
      for (var cartItem in _cart) {
        var cartProduct = cartItem.product;
        if (cartProduct.sku == product.sku) {
          if (cartItem.product.inStock) {
            if (cartItem.productInStockMagento) {
              if ((cartItem.product.isBackOrder ?? false) == true) {
                minMaxQuantityCheckForIncrementCase(cartItem);
              } else if ((cartItem.product.isBackOrder ?? false) == false) {
                if (cartItem.quantityMagento > 0) {
                  quantityRemainingCheckIncrementCase(cartItem);
                } else if (cartItem.quantityMagento == 0) {
                  notificationServices.showErrorNotification(
                      strings.PLEASE_REMOVE_PRODUCTS_THAT_ARE_OUT_OF_STOCK);
                }
              }
            } else {
              notificationServices.showErrorNotification(
                  strings.PLEASE_REMOVE_PRODUCTS_THAT_ARE_OUT_OF_STOCK);
            }
          } else {
            notificationServices.showErrorNotification(
                strings.PLEASE_REMOVE_PRODUCTS_THAT_ARE_OUT_OF_STOCK);
          }
          return;
        }
      }
    } else {
      await showCouponRemovalAlert(
          action: "INCREASE", isFromCartScreen: false, product: product);
      // await getMagentoCart();
    }
  }

  void minMaxQuantityCheckForDecrementCase(
      CartItem cartItem, bool isFromCartScreen) async {
    int cartQuantityAfterDecrement = cartItem.quantity - 1;
    if (cartItem.quantity > 1) {
      if (cartQuantityAfterDecrement < cartItem.minimumQuantity) {
        notificationServices.showCustomDialog(
            title: strings.REMOVE_ITEM,
            description:
                strings.MINIMUM_QUANTITY_REQUIRED_TO_PURCHASE_THIS_ITEM_IS +
                    "${cartItem.minimumQuantity}" +
                    strings.DO_YOU_WANT_TO_REMOVE_THIS_ITEM,
            negativeText: strings.NO,
            positiveText: strings.YES,
            action: () async {
              removeFromCart(
                  alertIsAlreadyShown: true,
                  cartItem: cartItem,
                  isFromCartScreen: isFromCartScreen);
            });
      } else if ((cartQuantityAfterDecrement > cartItem.maximumQuantity)) {
        if (((cartItem.maximumQuantity) > cartItem.quantityMagento) &&
            (!cartItem.product.isBackOrder)) {
          notificationServices.showCustomDialog(
              title: strings.CHANGE_QUANTITY,
              description: strings.Only +
                  "${cartItem.quantityMagento}" +
                  strings.IN_STOCK_DO_YOU_WANT_TO_DECREASE_QUANTITY_TO +
                  "${cartItem.quantityMagento}",
              negativeText: strings.NO,
              positiveText: strings.YES,
              action: () async {
                CartItem cartItemWithUpdatedQuantity = CartItem(
                    itemId: cartItem.itemId,
                    product: cartItem.product,
                    productInStockMagento: cartItem.productInStockMagento,
                    quantity: cartItem.quantityMagento,
                    quantityMagento: cartItem.quantityMagento,
                    maximumQuantity: cartItem.maximumQuantity,
                    minimumQuantity: cartItem.minimumQuantity,
                    rowTotal: cartItem.rowTotal,
                    finalRowTotal: cartItem.finalRowTotal,
                    taxAmount: cartItem.taxAmount,
                    finalTax: cartItem.finalTax,
                    discountAmount: cartItem.discountAmount);
                await updateProductQuantityInMagentoCart(
                    cartItem: cartItemWithUpdatedQuantity, isIncrease: true);
              });
        } else {
          notificationServices.showCustomDialog(
              title: strings.CHANGE_QUANTITY,
              description:
                  strings.MAXIMUM_QUANTITY_ALLOWED_TO_PURCHASE_THIS_ITEM_IS +
                      "${cartItem.maximumQuantity}" +
                      strings.DO_YOU_wANT_TO_CHANGE_QANTIITY_TO +
                      "${cartItem.maximumQuantity}.",
              negativeText: strings.NO,
              positiveText: strings.YES,
              action: () async {
                CartItem cartItemWithUpdatedQuantity = CartItem(
                    itemId: cartItem.itemId,
                    product: cartItem.product,
                    productInStockMagento: cartItem.productInStockMagento,
                    quantity: cartItem.maximumQuantity,
                    quantityMagento: cartItem.quantityMagento,
                    maximumQuantity: cartItem.maximumQuantity,
                    minimumQuantity: cartItem.minimumQuantity,
                    rowTotal: cartItem.rowTotal,
                    finalRowTotal: cartItem.finalRowTotal,
                    taxAmount: cartItem.taxAmount,
                    finalTax: cartItem.finalTax,
                    discountAmount: cartItem.discountAmount);
                await updateProductQuantityInMagentoCart(
                    cartItem: cartItemWithUpdatedQuantity, isIncrease: true);
              });
        }
      } else if ((cartQuantityAfterDecrement >= cartItem.minimumQuantity) &&
          (cartQuantityAfterDecrement <= cartItem.maximumQuantity)) {
        CartItem cartItemWithUpdatedQuantity = CartItem(
            itemId: cartItem.itemId,
            product: cartItem.product,
            productInStockMagento: cartItem.productInStockMagento,
            quantity: cartItem.quantity - 1,
            quantityMagento: cartItem.quantityMagento,
            maximumQuantity: cartItem.maximumQuantity,
            minimumQuantity: cartItem.minimumQuantity,
            rowTotal: cartItem.rowTotal,
            finalRowTotal: cartItem.finalRowTotal,
            taxAmount: cartItem.taxAmount,
            finalTax: cartItem.finalTax,
            discountAmount: cartItem.discountAmount);
        await updateProductQuantityInMagentoCart(
            cartItem: cartItemWithUpdatedQuantity, isIncrease: false);
      } else {
        CartItem cartItemWithUpdatedQuantity = CartItem(
            itemId: cartItem.itemId,
            product: cartItem.product,
            productInStockMagento: cartItem.productInStockMagento,
            quantity: cartItem.quantity - 1,
            quantityMagento: cartItem.quantityMagento,
            maximumQuantity: cartItem.maximumQuantity,
            minimumQuantity: cartItem.minimumQuantity,
            rowTotal: cartItem.rowTotal,
            finalRowTotal: cartItem.finalRowTotal,
            taxAmount: cartItem.taxAmount,
            finalTax: cartItem.finalTax,
            discountAmount: cartItem.discountAmount);
        await updateProductQuantityInMagentoCart(
            cartItem: cartItemWithUpdatedQuantity, isIncrease: false);
      }
    } else if (cartItem.quantity == 1) {
      removeFromCart(
          alertIsAlreadyShown: true,
          cartItem: cartItem,
          isFromCartScreen: isFromCartScreen);
    }
  }

  Future quantityRemainingCheckDecrementCase(CartItem cartItem) async {
    if ((cartItem.quantity) <= cartItem.quantityMagento) {
      minMaxQuantityCheckForDecrementCase(cartItem, false);
    } else if ((cartItem.quantity) > cartItem.quantityMagento) {
      if ((cartItem.quantityMagento) > cartItem.maximumQuantity) {
        notificationServices.showCustomDialog(
            title: strings.CHANGE_QUANTITY,
            description:
                "${strings.max_quantity_allowed_toast_error} ${cartItem.maximumQuantity}" +
                    strings.IN_STOCK_DO_YOU_WANT_TO_CHANGE_QUANTITY_TO +
                    "${cartItem.maximumQuantity}.",
            negativeText: strings.NO,
            positiveText: strings.YES,
            action: () async {
              CartItem cartItemWithUpdatedQuantity = CartItem(
                  itemId: cartItem.itemId,
                  product: cartItem.product,
                  productInStockMagento: cartItem.productInStockMagento,
                  quantity: cartItem.maximumQuantity,
                  quantityMagento: cartItem.quantityMagento,
                  maximumQuantity: cartItem.maximumQuantity,
                  minimumQuantity: cartItem.minimumQuantity,
                  rowTotal: cartItem.rowTotal,
                  finalRowTotal: cartItem.finalRowTotal,
                  taxAmount: cartItem.taxAmount,
                  finalTax: cartItem.finalTax,
                  discountAmount: cartItem.discountAmount);
              await updateProductQuantityInMagentoCart(
                  cartItem: cartItemWithUpdatedQuantity, isIncrease: false);
            });
      } else {
        notificationServices.showCustomDialog(
            title: strings.DECREASE_QUANTITY,
            description: strings.Only +
                '${cartItem.quantityMagento}' +
                strings.IN_STOCK_DO_YOU_WANT_TO_DECREASE_QUANTITY_TO +
                '${cartItem.quantityMagento}.',
            negativeText: strings.NO,
            positiveText: strings.YES,
            action: () async {
              CartItem cartItemWithUpdatedQuantity = CartItem(
                  itemId: cartItem.itemId,
                  product: cartItem.product,
                  productInStockMagento: cartItem.productInStockMagento,
                  quantity: cartItem.quantityMagento,
                  quantityMagento: cartItem.quantityMagento,
                  maximumQuantity: cartItem.maximumQuantity,
                  minimumQuantity: cartItem.minimumQuantity,
                  rowTotal: cartItem.rowTotal,
                  finalRowTotal: cartItem.finalRowTotal,
                  taxAmount: cartItem.taxAmount,
                  finalTax: cartItem.finalTax,
                  discountAmount: cartItem.discountAmount);
              await updateProductQuantityInMagentoCart(
                  cartItem: cartItemWithUpdatedQuantity, isIncrease: false);
            });
      }
    }
  }

  Future decreaseQuantity({bool isFromCartScreen, Product product}) async {
    if (!showCouponRemovalAlertAfterAppRestart) {
      var cartItem = _cart.firstWhere(
          (element) => product.sku == element.product.sku,
          orElse: () => null);
      if (cartItem.product.inStock) {
        if (cartItem.productInStockMagento) {
          if ((cartItem.product.isBackOrder ?? false) == true) {
            minMaxQuantityCheckForDecrementCase(cartItem, false);
          } else if ((cartItem.product.isBackOrder ?? false) == false) {
            if (cartItem.quantityMagento > 0) {
              quantityRemainingCheckDecrementCase(cartItem);
            } else if (cartItem.quantityMagento == 0) {
              notificationServices.showErrorNotification(
                  strings.PLEASE_REMOVE_PRODUCTS_THAT_ARE_OUT_OF_STOCK);
            }
          }
        } else {
          notificationServices.showErrorNotification(
              strings.PLEASE_REMOVE_PRODUCTS_THAT_ARE_OUT_OF_STOCK);
        }
      } else {
        notificationServices.showErrorNotification(
            strings.PLEASE_REMOVE_PRODUCTS_THAT_ARE_OUT_OF_STOCK);
      }
    } else {
      await showCouponRemovalAlert(
          action: "DECREASE",
          isFromCartScreen: isFromCartScreen,
          product: product);
      // await getMagentoCart();
    }
  }

  Future<void> resetCart(bool paymentSucces) async {
    //FUNCTION TO BE CALLED AFTER EVERY ORDER PLACEMENT
    modifyOrderSuccess(false);
    modifyOrderError(false);
    modifyLaunchNGenius(false);
    paymentGatewayUrl = "";
    errorMessage = "";
    paymentStatus = PAYMENT_STATUS.NONE;
    if (paymentSucces) {
      _cart.clear();
      _cartQueue.clear();
      createMagentoCart();
      _shippingAddress = null;
      _clearMagentoTotals();
    }
    notifyListeners();
  }

  void clearWishlist() {
    _wishlist.clear();
    notifyListeners();
  }

  int getCartQuantity(Product product) {
    int quantity;
    for (var item in _cart) {
      var cartProduct = item.product;
      if (cartProduct.sku == product.sku) {
        quantity = item.quantity;
        break;
      }
    }
    return quantity;
  }

  void addToWishList(Product product) {
    if (!isProductInWishlist(product)) {
      _wishlist.add(product);
      addProductToMagentoWishlist(product);
    }
    notifyListeners();
  }

  void removeFromWishList(Product product) {
    _wishlist.removeWhere((element) => element.sku == product.sku);
    removeProductFromMagentoWishlist(product.id);
    notifyListeners();
  }

  bool isProductInCart(Product product) {
    //Check if a product is present in a cart
    if (product == null || product.sku == null) return false;

    for (var cartItem in _cart) {
      var prod = cartItem.product;
      if (product.sku == prod.sku) {
        return true;
      }
    }
    return false;
  }

  bool isProductInWishlist(Product product) {
    //Check if a product is present in the wishlist

    if (product == null || product.sku == null) return false;

    for (var item in _wishlist) {
      if (product.sku == item.sku) {
        return true;
      }
    }

    return false;
  }

  double getProductTotal(CartItem cartItem) {
    return roundDouble(
        (cartItem.discountAmount > 0.0)
            ? cartItem.finalRowTotal
            : cartItem.rowTotal,
        2);
  }

  // double getProductTotal(CartItem cartItem) {
  //   return roundDouble(
  //       cartItem.rowTotal + cartItem.finalTax - cartItem.discountAmount, 2);
  // }

  // double getProductTotal(CartItem cartItem) {
  //   return roundDouble(
  //       (roundDouble(cartItem.product.priceWithoutTax * cartItem.quantity, 2) +
  //           (((cartItem.product.priceWithoutTax * cartItem?.product?.tax) /
  //                   100) *
  //               cartItem?.quantity)),
  //       2);
  // }

  ////####Section#### {Accounting Functions}

  double get subTotal {
    //Get the sum of prices of all products
    if (_cart.isEmpty)
      return 0;
    else {
      double sum = 0;
      _cart.forEach((cartItem) {
        sum += getProductTotal(cartItem);
      });
      if (magentoSubTotal != 0)
        return magentoSubTotal;
      else
        return sum;
    }
  }

  double get grandTotal {
    if (_magentoGrandTotal == 0)
      return getRoundedOffPrice(
          (subTotal + _magentoShippingFee + magentoTax + _magentoDiscount));
    else
      return _magentoGrandTotal;
  }

  void updateOrderid(String orderId) {
    _orderId = orderId;
  }

  double getRoundedOffPrice(double price) {
    double a1 = price * 10;
    double a2 = double.parse(a1.toStringAsFixed(1)) / 10;
    String finalResult = a2.toStringAsFixed(2);
    return double.parse(finalResult);
  }

  double _magentoSubTotal = 0;
  double _magentoGrandTotal = 0;
  double _magentoShippingFee = 0;
  double _magentoTax = 0;
  double _magentoDiscount = 0;

  String _couponCode = "";

  double get magentoSubTotal {
    return _magentoSubTotal;
  }

  // double get magentoGrandTotal {
  //   return (_magentoGrandTotal + _magentoTax);
  // }

  double get magentoShippingFee {
    return _magentoShippingFee;
  }

  double get magentoTax {
    return _magentoTax;
  }

  double get magentoDiscount {
    return _magentoDiscount;
  }

  String get couponCode {
    return _couponCode;
  }

  set couponCode(value) {
    _couponCode = value;
    if (value == "") couponCodeSubmitStatus = COUPON_CODE_STATUS.NOT_APPLIED;
    notifyListeners();
  }

  void _clearMagentoTotals() {
    _magentoSubTotal = 0;
    _magentoGrandTotal = 0;
    _magentoShippingFee = 0;
    _magentoTax = 0;
    _magentoDiscount = 0;
    _couponCode = "";
    couponCodeSubmitStatus = COUPON_CODE_STATUS.NOT_APPLIED;
  }

  //####Section#### {UI Functions}
  Product _selectedProduct;
  MainCategory _selectedCategory;

  //Widget that controls the subcategory in merchandise category listing screen
  SubCategory _selectedSubCategory;
  SubCategory _selectedViewMoreSubCategory;

  //Widget that controls the category in category navigation
  int _selectedCategoryIdForNavigation = 0;

  String selectedCategoryName = "";
  int parentCategoryIdForNavigation = 0;
  SubCategory subCategoryParentForNavigation;

  bool isMerchandiseCategorySelected = false;
  int selectedMerchandiseCategoryIndex = 0;

  Product get selectedProduct {
    return _selectedProduct;
  }

  set selectedProduct(value) {
    _selectedProduct = value;
    //_frequentlyBoughtTogether.clear();
    //TODO:ENABLE FETCH RELATED PRODUCTS
    //fetchRelatedProducts(_selectedProduct.sku);
  }

  MainCategory get selectedCategory {
    return _selectedCategory;
  }

  set selectedCategory(value) => _selectedCategory = value;

  SubCategory get selectedSubCategory {
    return _selectedSubCategory;
  }

  set selectedSubCategory(value) {
    _selectedSubCategory = value;
    fetchProductsOfACategory(_selectedSubCategory.id);
    notifyListeners();
  }

  var subCatid;

  set selectedCategoryForNavigation(value) {
    _selectedCategoryIdForNavigation = value;
    subCatid = value;
    fetchProductsOfACategory(_selectedCategoryIdForNavigation);
  }

  SubCategory get selectedCategoryForViewMore {
    return _selectedViewMoreSubCategory;
  }

  set selectedCategoryForViewMore(value) {
    _selectedViewMoreSubCategory = value;
    fetchProductsForViewMore(_selectedViewMoreSubCategory.id);
    notifyListeners();
  }

  //If brand/category filters of product is involved
  var selectedBrands = [true, true, true, true];

  List<Product> _filteredProducts = [];

  List<Product> get filteredProducts {
    return [..._filteredProducts];
  }

  List<Product> _filteredProductsByCategory = [];

  List<Product> get filteredProductsByCategory {
    return [..._filteredProductsByCategory];
  }

  List<Product> _sortedProducts = [];

  List<Product> get sortedProducts {
    return [..._filteredProducts];
  }

  List<Product> getProductsByCategory(MainCategory category) {
    //Function to filter products
    List<Product> _matchingProducts = [];
    _products.forEach((item) {
      if (item.mainCategory.name == category.name) _matchingProducts.add(item);
    });
    return _matchingProducts;
  }

  void filterProductsByCategory(MainCategory category) {
    //Function to filter products

    _filteredProductsByCategory.clear();
    _products.forEach((item) {
      if (item.mainCategory.name == category.name)
        _filteredProductsByCategory.add(item);
    });

    notifyListeners();
  }

  void filterProducts() {
    //Function to filter products

    _filteredProducts.clear();
    _products.forEach((item) {
      if (selectedBrands[0] && item.mainCategory.name == "Fruits")
        _filteredProducts.add(item);
      else if (selectedBrands[1] && item.mainCategory.name == "Snacks")
        _filteredProducts.add(item);
      else if (selectedBrands[2] && item.mainCategory.name == "Condiments")
        _filteredProducts.add(item);
    });
    notifyListeners();
  }

  void sortProducts(int type) {
    _filteredProducts.clear();
    _sortedProducts.clear();
    _sortedProducts.addAll(_products);

    //.sort doesn't assign value to the list,.. assigns value to the list it sorts
    if (type == 0) {
      //Sort by price
      _sortedProducts
        ..sort((a, b) => (a.priceWithTax).compareTo((b.priceWithTax)));
    } else if (type == 1) {
      //Rating
      _sortedProducts
        ..sort((a, b) => b.rating.toInt().compareTo(a.rating.toInt()));
    } else if (type == 2) {
      //A-Z
      _sortedProducts
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (type == 3) {
      //Z-A
      _sortedProducts
        ..sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    }

    _filteredProducts = _sortedProducts;

    notifyListeners();
  }

  String getWeightText(double weight) {
    if (weight < 1000) {
      return weight.toInt().toString() + "g";
    } else {
      double kilosInDouble = weight.toInt() / 1000;
      int kilos = kilosInDouble.toInt();
      int grams = weight.toInt() % 1000;
      double gramsInHudreds = grams / 100;
      String text = "";
      if (gramsInHudreds != 0) {
        text = kilos.toInt().toString() +
            "." +
            gramsInHudreds.toInt().toString() +
            "kg";
      } else {
        text = kilos.toInt().toString() + " kg";
      }
      return text;
    }
  }

  Future updateAvailabelTimeSlotString() async {
    bool hasTimeSlotMatched = false;
    String textOfNextAvailableTimeSlot = "";
    DateTime nextAvailableFromTime;
    DateTime now = DateTime.now();

    List<TimeSlot> tempTodayTimeSlots = List.castFrom(_todayTimeSlots);
    tempTodayTimeSlots.sort((a, b) {
      int aFromTimeHour = int.parse(a.fromTime[0] + a.fromTime[1]);
      int aFromTimeMinute = int.parse(a.fromTime[3] + a.fromTime[4]);
      int bFromTimeHour = int.parse(b.fromTime[0] + b.fromTime[1]);
      int bFromTimeMinute = int.parse(b.fromTime[3] + b.fromTime[4]);

      DateTime aFromDate = new DateTime(now.year, now.month, now.day,
          aFromTimeHour, aFromTimeMinute, 0, 0, 0);

      DateTime bFromDate = new DateTime(now.year, now.month, now.day,
          bFromTimeHour, bFromTimeMinute, 0, 0, 0);
      return aFromDate.compareTo(bFromDate);
    });

    for (var element in tempTodayTimeSlots) {
      int cutOffTimeHour =
          int.parse(element.cutOffTime[0] + element.cutOffTime[1]);
      int cutOffTimeMinute =
          int.parse(element.cutOffTime[3] + element.cutOffTime[4]);

      DateTime cutOffDate = new DateTime(now.year, now.month, now.day,
          cutOffTimeHour, cutOffTimeMinute, 0, 0, 0);

      if (now.isBefore(cutOffDate)) {
        if (!hasTimeSlotMatched) {
          if (element.slotType == SLOT_TYPE_EXPRESS) {
            int startTimeHour =
                int.parse(element.startTime[0] + element.startTime[1]);
            int startTimeMinute =
                int.parse(element.startTime[3] + element.startTime[4]);
            DateTime startTime = new DateTime(now.year, now.month, now.day,
                startTimeHour, startTimeMinute, 0, 0, 0);
            if (now.isAfter(startTime)) {
              textOfNextAvailableTimeSlot =
                  "Tod " + element.fromTime + " - " + element.toTime;
              int fromTimeHour =
                  int.parse(element.fromTime[0] + element.fromTime[1]);
              int fromTimeMinute =
                  int.parse(element.fromTime[3] + element.fromTime[4]);
              DateTime fromDate = new DateTime(now.year, now.month, now.day,
                  fromTimeHour, fromTimeMinute, 0, 0, 0);
              nextAvailableFromTime = fromDate;
              hasTimeSlotMatched = true;
              break;
            }
          } else {
            textOfNextAvailableTimeSlot =
                "Tod " + element.fromTime + " - " + element.toTime;
            int fromTimeHour =
                int.parse(element.fromTime[0] + element.fromTime[1]);
            int fromTimeMinute =
                int.parse(element.fromTime[3] + element.fromTime[4]);
            DateTime fromDate = new DateTime(now.year, now.month, now.day,
                fromTimeHour, fromTimeMinute, 0, 0, 0);
            nextAvailableFromTime = fromDate;
            hasTimeSlotMatched = true;
            break;
          }
        }
      }
    }
    //If nothing matches,Send's tomorrow's first timeslot
    if (!hasTimeSlotMatched) {
      List<TimeSlot> tempTomorrowTimeSlots = List.castFrom(_tomorrowTimeSlots);
      tempTomorrowTimeSlots.sort((a, b) {
        int aFromTimeHour = int.parse(a.fromTime[0] + a.fromTime[1]);
        int aFromTimeMinute = int.parse(a.fromTime[3] + a.fromTime[4]);
        int bFromTimeHour = int.parse(b.fromTime[0] + b.fromTime[1]);
        int bFromTimeMinute = int.parse(b.fromTime[3] + b.fromTime[4]);

        DateTime aFromDate = new DateTime(now.year, now.month, now.day,
            aFromTimeHour, aFromTimeMinute, 0, 0, 0);

        DateTime bFromDate = new DateTime(now.year, now.month, now.day,
            bFromTimeHour, bFromTimeMinute, 0, 0, 0);
        return aFromDate.compareTo(bFromDate);
      });
      for (var element in tempTomorrowTimeSlots) {
        int cutOffTimeHour =
            int.parse(element.cutOffTime[0] + element.cutOffTime[1]);
        int cutOffTimeMinute =
            int.parse(element.cutOffTime[3] + element.cutOffTime[4]);

        DateTime cutOffDate = new DateTime(now.year, now.month, now.day,
                cutOffTimeHour, cutOffTimeMinute, 0, 0, 0)
            .add(const Duration(days: 1));

        if (now.isBefore(cutOffDate)) {
          if (!hasTimeSlotMatched) {
            if (element.slotType == SLOT_TYPE_EXPRESS) {
              int startTimeHour =
                  int.parse(element.startTime[0] + element.startTime[1]);
              int startTimeMinute =
                  int.parse(element.startTime[3] + element.startTime[4]);
              DateTime startTime = new DateTime(now.year, now.month, now.day,
                      startTimeHour, startTimeMinute, 0, 0, 0)
                  .add(const Duration(days: 1));
              if (now.isAfter(startTime)) {
                textOfNextAvailableTimeSlot =
                    "Tom " + element.fromTime + " - " + element.toTime;
                int fromTimeHour =
                    int.parse(element.fromTime[0] + element.fromTime[1]);
                int fromTimeMinute =
                    int.parse(element.fromTime[3] + element.fromTime[4]);
                DateTime fromDate = new DateTime(now.year, now.month, now.day,
                        fromTimeHour, fromTimeMinute, 0, 0, 0)
                    .add(const Duration(days: 1));
                nextAvailableFromTime = fromDate;
                hasTimeSlotMatched = true;
                break;
              }
            } else {
              textOfNextAvailableTimeSlot =
                  "Tom " + element.fromTime + " - " + element.toTime;
              int fromTimeHour =
                  int.parse(element.fromTime[0] + element.fromTime[1]);
              int fromTimeMinute =
                  int.parse(element.fromTime[3] + element.fromTime[4]);
              DateTime fromDate = new DateTime(now.year, now.month, now.day,
                      fromTimeHour, fromTimeMinute, 0, 0, 0)
                  .add(const Duration(days: 1));
              nextAvailableFromTime = fromDate;
              hasTimeSlotMatched = true;
              break;
            }
          }
        }
      }
    }
    nextAvailableTimeSlot = textOfNextAvailableTimeSlot ?? '--';
    if (nextAvailableFromTime != null) {
      int timeDifference = nextAvailableFromTime.difference(now).inHours;
      if (timeDifference == 0) {
        nextTimeSlotInHours = "${timeDifference + 1} Hour";
      } else {
        nextTimeSlotInHours = "${timeDifference + 1} Hours";
      }
    } else {
      nextTimeSlotInHours = '--';
    }
  }

  List<SortFilterSection> sections = [];

  Future<void> fetchFilterOptions() async {
    try {
      Dio dio = Dio(BaseOptions(
        connectTimeout: 25000,
        receiveTimeout: 25000,
      ));
      String _url = LAMBDA_BASE_URL_MINIMUM + "/ecomm/product-filter";
      var response = await dio.request(
        _url,
        options: Options(method: 'GET'),
      );
      var decodedResponse =
          json.decode(response.toString()) as Map<String, dynamic>;
      if (decodedResponse != null) {
        Map<String, dynamic> data =
            decodedResponse["data"] as Map<String, dynamic>;
        List<dynamic> _sections = data["sections"];
        sections.clear();
        _sections
            .map((element) => SortFilterSection.fromJson(element))
            .toList()
            .forEach((_section) {
          if (_section != null) {
            sections.add(_section);
          }
        });
      }
    } catch (e) {
      print(e);
      logNestoCustom(
          message: "Could not update filter optons", logType: LogType.error);
    }
  }
}

double roundDouble(double value, int places) {
  double mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

extension WhereNotIn<T> on Iterable<T> {
  Iterable<T> whereNotIn(Iterable<T> reject) {
    final rejectSet = reject.toSet();
    return where((el) => !rejectSet.contains(el));
  }
}

extension serverErr on int {
  bool isServerErr() => (this ~/ 100) == 5;
}
