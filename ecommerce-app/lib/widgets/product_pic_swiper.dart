import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class PicSwiper extends StatefulWidget {
  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 1;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: ScreenUtil().setHeight(5),
      width: isActive ? 26.0 : 15.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.black26,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      height: ScreenUtil().setHeight(300),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              physics: ClampingScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                Container(
                  height: ScreenUtil().setHeight(250),
                  width: ScreenUtil().setWidth(150),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://images-na.ssl-images-amazon.com/images/I/71J4iwEKfHL._AC_SL1500_.jpg'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(250),
                  width: ScreenUtil().setWidth(150),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://images-na.ssl-images-amazon.com/images/I/71h6PpGaz9L._AC_SL1500_.jpg'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(250),
                  width: ScreenUtil().setWidth(150),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://images-na.ssl-images-amazon.com/images/I/71e7r3zf75L._AC_SL1500_.jpg'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: _buildPageIndicator(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
