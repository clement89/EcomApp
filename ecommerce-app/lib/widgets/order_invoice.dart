import 'package:Nesto/strings.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Invoice extends StatelessWidget {
  const Invoice({
    Key key,
    @required this.url,
    @required this.status,
  }) : super(key: key);

  final String url;
  final String status;

  void launchInvoice() async {
    //log("invoiceURL: $url", name: "order_invoice");
    logNestoCustom(message: "invoiceURL: $url", logType: LogType.debug);
    final _url = Uri.encodeFull(url ?? "");
    try {
      if (await canLaunch(_url))
        await launch(_url);
      else
        // can't launch url, there is some error
        throw "Could not launch $url";
    } catch (e) {
      //log("launchInvoice ERR: $e", name: 'order_invoice');
      logNestoCustom(message: "launchInvoice ERR: $e", logType: LogType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: (url != null && url.isNotEmpty),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenUtil().setWidth(30)),
          SizedBox(
            height: ScreenUtil().setWidth(61.86),
            child: ElevatedButton(
              onPressed: launchInvoice,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/svg/file_pdf_sabarish.svg",
                        height: 23,
                        width: 23,
                      ),
                      SizedBox(width: ScreenUtil().setWidth(9)),
                      Text(
                        GET_TAX_INVOICE,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: ScreenUtil().setWidth(15)),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  )
                ],
              ),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  backgroundColor:
                      MaterialStateProperty.all(values.NESTO_GREEN),
                  elevation: MaterialStateProperty.all(0)),
            ),
          )
        ],
      ),
    );
  }
}
