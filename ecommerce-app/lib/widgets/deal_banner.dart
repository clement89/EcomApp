// import 'package:Nesto/values.dart' as values;
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class DealBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: Padding(
//         padding: EdgeInsets.only(
//             right: ScreenUtil().setWidth(values.SPACING_MARGIN_STANDARD)),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Image.asset(
//               "assets/images/banner_1.webp",
//               fit: BoxFit.fitWidth,
//               height: ScreenUtil().setWidth(180),
//               width: ScreenUtil().setWidth(264),
//             ),
//             Positioned(
//                 top: ScreenUtil().setWidth(16),
//                 left: ScreenUtil().setWidth(12),
//                 child: Text(
//                   "Head Phones",
//                   style: TextStyle(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 20),
//                 )),
//             Positioned(
//               bottom: ScreenUtil().setWidth(16),
//               left: ScreenUtil().setWidth(12),
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(5)),
//                 padding: EdgeInsets.symmetric(
//                     horizontal: ScreenUtil().setWidth(8),
//                     vertical: ScreenUtil().setWidth(8)),
//                 child: Text(
//                   "UP TO 50% OFF",
//                   style: TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
