import 'package:Nesto/screens/location_screen.dart';
import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:shape_of_view/shape_of_view.dart';
import 'package:Nesto/strings.dart' as strings;
class Item {
  String imageURL, title, subTitle;

  Item({
    @required this.imageURL,
    @required this.title,
    @required this.subTitle,
  });
}

List pages = [
  Item(
    imageURL: 'assets/images/onb_1.png',
    title: strings.ONDOARDING_TITLE_ONE,
    subTitle:
       strings.ONBOARDING_SUBTITLE_ONE,
  ),
  Item(
    imageURL: 'assets/images/onb_2.png',
    title: strings.ONBOARDING_TITLE_TWO,
    subTitle:
        strings.ONBOARDING_SUBTITLE_TWO,
  ),
  Item(
    imageURL: 'assets/images/onb_3.png',
    title: strings.ONBOARDING_TITLE_THREE,
    subTitle:
        strings.ONBOARDING_SUBTITLE_THREE,
  ),
  Item(
    imageURL: 'assets/images/onb_4.png',
    title: strings.ONBOARDING_TITLE_FOUR,
    subTitle:
       strings.ONBOARDING_SUBTITLE_FOUR,
  ),
];

class OnBoardingScreen extends StatefulWidget {
  static const routeName = "/onboarding_screen";

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _currentPage = 0;
  int pageIndex;
  final PageController _pageController = PageController(initialPage: 0);

  void nextPage() {
    setState(() {
      _currentPage = _currentPage + 1;
      _pageController.jumpToPage(_currentPage);
    });

    //firebase analytics logging.
    firebaseAnalytics.onboardingNextClicked(pagePosition: _currentPage);
  }

  void skip() {
    //firebase analytics logging.
    firebaseAnalytics.onboardingSkipClicked(pagePosition: _currentPage);

    Navigator.of(context).pushReplacementNamed(LocationScreen.routeName);
  }

  Widget circleDot(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: ScreenUtil().setHeight(8),
      width: ScreenUtil().setWidth(8),
      decoration: BoxDecoration(
          color: isActive
              ? values.NESTO_GREEN
              : Color(0XFF08C25E).withOpacity(0.4),
          shape: BoxShape.circle),
    );
  }

  Widget generateDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < pages.length; i++)
          if (i == _currentPage) ...[circleDot(true)] else circleDot(false),
      ],
    );
  }

  @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "OnBoarding Screen");
    super.initState();

    //firebase analytics logging
    firebaseAnalytics.onboardingScreenLoaded(pagePosition: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    //Screen Util Init
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SafeArea(
      child: Scaffold(
        body: ConnectivityWidget(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    physics: ClampingScrollPhysics(),
                    itemCount: pages.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      return OnBoardingPage(
                        index: index,
                        onPressSkip: skip,
                        onPressNext: nextPage,
                      );
                    },
                  ),
                ),
                generateDots(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(26.0),
                      vertical: ScreenUtil().setHeight(25.0)),
                  child: _currentPage != pages.length - 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: skip,
                              child: Text(
                                strings.SKIP,
                                style: skipText,
                              ),
                            ),
                            GestureDetector(
                              onTap: nextPage,
                              child: Container(
                                height: ScreenUtil().setHeight(61.97),
                                width: ScreenUtil().setWidth(186),
                                decoration: BoxDecoration(
                                  color: Color(0XFF00983D),
                                  borderRadius: BorderRadius.circular(8.85),
                                ),
                                child: Center(
                                  child: Text(strings.NEXT, style: nextStyle),
                                ),
                              ),
                            )
                          ],
                        )
                      : GestureDetector(
                          onTap: () {
                            skip();

                            //firebase analytics logging.
                            firebaseAnalytics.startShopping();
                          },
                          child: Container(
                            height: ScreenUtil().setHeight(61.97),
                            decoration: BoxDecoration(
                                color: Color(0XFF00983D),
                                borderRadius: BorderRadius.circular(8.84)),
                            child: Center(
                              child: Text(
                                strings.START_SHOPPING,
                                style: nextStyle,
                              ),
                            ),
                          ),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnBoardingPage extends StatelessWidget {
  OnBoardingPage(
      {@required this.index,
      @required this.onPressNext,
      @required this.onPressSkip});

  final int index;
  final Function onPressNext;
  final Function onPressSkip;

  @override
  Widget build(BuildContext context) {
    var image = pages[index].imageURL;
    // logNesto(image);
    return Column(
      children: [
        ShapeOfView(
            shape: ArcShape(
                direction: ArcDirection.Outside,
                height: ScreenUtil().setHeight(25),
                position: ArcPosition.Bottom),
            elevation: 0,
            height: MediaQuery.of(context).size.height /
                2, //height & width are optional
            child: Container(
              width: double.infinity,
              color: Color(0XFFF5F5F8),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            )),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(36.5),
              right: ScreenUtil().setWidth(36.5),
              top: ScreenUtil().setHeight(40.0),
              bottom: ScreenUtil().setHeight(36.5),
            ),
            child: Column(
              children: [
                Container(
                  child: Text(
                    pages[index].title,
                    textAlign: TextAlign.center,
                    style: titleTextStyle,
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(19.0),
                ),
                Container(
                  child: Text(
                    pages[index].subTitle,
                    style: subTitleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

//styles

const titleTextStyle = TextStyle(
  fontSize: 26.56,
  fontWeight: FontWeight.w700,
  color: Colors.black,
);
const subTitleTextStyle = TextStyle(
  fontSize: 15.49,
  height: 1.7,
  fontWeight: FontWeight.w400,
  color: Color(0XFF525C67),
);
const skipText = TextStyle(
  fontSize: 17.71,
  fontWeight: FontWeight.w400,
  color: Color(0XFF757D85),
);
const nextStyle =
    TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: Colors.white);
