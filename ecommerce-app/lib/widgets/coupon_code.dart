import 'package:Nesto/providers/store_provider.dart';
import 'package:Nesto/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:Nesto/strings.dart' as strings;

class CouponCode extends StatefulWidget {

  @override
  _CouponCodeState createState() => _CouponCodeState();
}

class _CouponCodeState extends State<CouponCode> {
  TextEditingController couponCodeController = TextEditingController(text: "");

  @override
  void didChangeDependencies() {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    couponCodeController.text = provider.couponCode.toUpperCase();
    super.didChangeDependencies();
  }

  void applyCoupon(String coupon) {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    if(provider.shippingAddress != null){
      if(provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.NOT_APPLIED) provider.applyCouponCode(coupon, context);
      else if (provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY) provider.removeCouponCode();
      else if(provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_ERROR) provider.couponCode = "";
    }else{
      showError(context, strings.PLEASE_CHOOSE_A_SHIPPING_ADDRESS);
      couponCodeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<StoreProvider>(context, listen: false);
    if((provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY) || (provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_ERROR)){
      couponCodeController.clear();
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
          width: ScreenUtil().setWidth(375),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
                color: provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.NOT_APPLIED
                    ? Color(0xFFE5E5E5)
                    : provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY?Color(0xFF00983D):Colors.red),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.NOT_APPLIED)?
              Container(
                width: ScreenUtil().setWidth(300),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))
                ),
                child: TextField(
                  maxLength: 57,
                        controller: couponCodeController,
                        onSubmitted: (value){
                          applyCoupon(value);
                        },
                        decoration: InputDecoration(
                          counterText: '',
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 20.0, 20.0, 19.0),
                            border: InputBorder.none,
                            hintText: strings.ENTER_COUPON_CODE,
                            hintStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                color: Color(0xFFB2B2B2),
                                fontFamily: "SFProDisplay")),
                      ),
              )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(200),
                            child: Text(
                              provider.couponCode.toUpperCase(),
                              overflow: TextOverflow.visible,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY?Color(0xFF010202):Color(0xFF7E7F80),
                                  fontFamily: "SFProDisplay"),
                            ),
                          ),
                          Text(
                            provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY
                                ? strings.COUPON_APPLIED_SUCCESFULLY
                                :strings. COUPON_INVALID_TRY_AGAIN,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                color: provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY
                                    ? Color(0xFF7E7F80)
                                    : Color(0xFFC71712),
                                fontFamily: "SFProDisplay"),
                          )
                        ],
                      ),
                    ),
              GestureDetector(
                onTap: ()=>applyCoupon(couponCodeController.text),
                child: Container(
                  height: ScreenUtil().setHeight(75),
                  width: ScreenUtil().setWidth(60),
                  decoration: BoxDecoration(
                    color: provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.NOT_APPLIED
                        ? Color(0xFF00983D)
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                    border: Border.all(
                      color: provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.NOT_APPLIED
                          ? Color(0xFF00983D)
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                      child: (provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.NOT_APPLIED)
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                              "assets/icons/coupon_apply.svg",
                              color: Colors.white),
                          Text(
                            strings.APPLY,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontFamily: "SFProDisplay"),
                          )
                        ],
                      )
                          : SvgPicture.asset(
                          provider.couponCodeSubmitStatus == COUPON_CODE_STATUS.APPLIED_SUCCESSFULLY
                              ? "assets/icons/coupon_remove_green.svg"
                              : "assets/icons/coupon_remove_red.svg")),
                ),
              )
            ],
          )),
    );
  }
}
