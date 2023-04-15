import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/values.dart' as values;
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatelessWidget {
  final Function onTapAction;
  final int currentIndex;

  BottomBar({
    this.onTapAction,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return _defaultBottomBar(context);
  }

  _defaultBottomBar(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12, width: 1.0))),
        child: BottomNavigationBar(
          // showSelectedLabels: false,
          // showUnselectedLabels: false,

          selectedFontSize: 10,
          unselectedFontSize: 10,

          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(
                  "assets/images/nav_1.png",
                ),
              ),
              label: 'Nesto',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(
                  "assets/images/nav_2.png",
                ),
              ),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(
                  "assets/images/nav_3.png",
                ),
              ),
              label: 'Top Deals',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                badgeColor: values.NESTO_GREEN,
                shape: BadgeShape.circle,
                // position: BadgePosition.topEnd(top: -3, end: -3),
                padding: EdgeInsets.all(4),

                animationType: BadgeAnimationType.slide,
                // borderRadius: BorderRadius.circular(100),
                child: ImageIcon(
                  AssetImage(
                    "assets/images/nav_4.png",
                  ),
                ),
                badgeContent: Text(
                  context.read<StoreProvider>().cartCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                showBadge:
                    context.read<StoreProvider>().cartCount > 0 ? true : false,
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(
                  "assets/images/nav_5.png",
                ),
              ),
              label: 'My profile',
            ),
          ],
          currentIndex: currentIndex,
          selectedItemColor: values.NESTO_GREEN,
          unselectedItemColor: Colors.grey,
          onTap: onTapAction,
          type: BottomNavigationBarType.fixed,
          elevation: 0.0,
          backgroundColor: Colors.white,
          selectedLabelStyle: TextStyle(color: values.NESTO_GREEN),
        ),
      ),
    );
  }

// _animatedBottomBar(BuildContext context) {
//   SnakeShape snakeShape = SnakeShape.indicator;
//   Color selectedColor = values.NESTO_GREEN;
//
//   return SnakeNavigationBar.color(
//     behaviour: SnakeBarBehaviour.pinned,
//     snakeShape: snakeShape,
//     // shape: bottomBarShape,
//     padding: EdgeInsets.zero,
//
//     ///configuration for SnakeNavigationBar.color
//     snakeViewColor: selectedColor,
//     selectedItemColor:
//         snakeShape == SnakeShape.indicator ? selectedColor : null,
//     unselectedItemColor: Colors.blueGrey,
//
//     ///configuration for SnakeNavigationBar.gradient
//     // snakeViewGradient: selectedGradient,
//     // selectedItemGradient: snakeShape == SnakeShape.indicator ? selectedGradient : null,
//     // unselectedItemGradient: unselectedGradient,
//
//     showUnselectedLabels: false,
//     showSelectedLabels: false,
//
//     currentIndex: currentIndex,
//     onTap: onTapAction,
//     items: [
//       const BottomNavigationBarItem(
//           icon: ImageIcon(AssetImage(
//             "assets/icons/nesto_bottom_nav_icon.png",
//           )),
//           label: 'tickets'),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.menu), label: 'calendar'),
//       const BottomNavigationBarItem(
//           icon: Icon(
//             Icons.favorite_border,
//           ),
//           label: 'home'),
//       BottomNavigationBarItem(
//           icon: Badge(
//             shape: BadgeShape.circle,
//             animationType: BadgeAnimationType.slide,
//             borderRadius: BorderRadius.circular(100),
//             child: Icon(Icons.shopping_cart),
//             badgeContent: Text(
//               context.read<StoreProvider>().cartCount.toString(),
//               style: TextStyle(color: Colors.white),
//             ),
//             showBadge:
//                 context.read<StoreProvider>().cartCount > 0 ? true : false,
//           ),
//           label: 'microphone'),
//       const BottomNavigationBarItem(
//           icon: Icon(
//             Icons.person_outline,
//           ),
//           label: 'search')
//     ],
//     selectedLabelStyle: const TextStyle(fontSize: 14),
//     unselectedLabelStyle: const TextStyle(fontSize: 10),
//   );
// }

}
