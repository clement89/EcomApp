import 'package:Nesto/services/firebase_analytics.dart';
import 'package:Nesto/strings.dart' as strings;
import 'package:Nesto/utils/formatters/card_formatter.dart';
import 'package:Nesto/utils/util.dart';
import 'package:Nesto/values.dart' as values;
import 'package:Nesto/widgets/connectivity_widget.dart';
import 'package:Nesto/widgets/headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class AddNewCard extends StatefulWidget {
  static String routeName = '/add_new_card';
  @override
  _AddNewCardState createState() => _AddNewCardState();
}

class _AddNewCardState extends State<AddNewCard> {
  var _formKey = new GlobalKey<FormState>();

  bool _value = false;
  List<int> _expiryDate;
  int _cardNumber;
  int _cvv;
  String _name;

  void valueChanged() {
    setState(() {
      _value = !_value;
    });
  }

  void setExpiryDate(String value) {
    var split = value.split(new RegExp(r'(\/)'));
    _expiryDate = [int.parse(split[0]), int.parse(split[1])];
  }

  void setCardNumber(String text) {
    RegExp regExp = new RegExp(r"[^0-9]");
    _cardNumber = int.parse(text.replaceAll(regExp, ''));
  }

  void setCvv(String text) {
    _cvv = int.parse(text);
  }

  void setName(String text) {
    _name = text;
  }

  void addCard() {
    logNesto(_cardNumber.toString());
    logNesto(_expiryDate[0].toString());
    logNesto(_cvv.toString());
    logNesto(_name.toString());
  }
    @override
  void initState() {
    firebaseAnalytics.screenView(screenName: "Add New Card Screen");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //Screen Util
    ScreenUtil.init(context,
        designSize: Size(414, 896), allowFontScaling: true);

    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: headerBar(title: strings.ADD_NEW_CARD, context: context),
          body: ConnectivityWidget(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              // color: Colors.green[100],
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(24.0),
                  right: ScreenUtil().setWidth(29.0),
                  top: ScreenUtil().setWidth(21.0),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleText(strings.CARD_NUMBER),
                      Container(
                        height: ScreenUtil().setHeight(60.84),
                        padding:
                            EdgeInsets.only(left: ScreenUtil().setWidth(24.0)),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color: Color(0XFFBBBDC1).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8.0)),
                        width: double.infinity,
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          minLines: 1,
                          onChanged: setCardNumber,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            CardNumberInputFormatter(),
                          ],
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: '',
                            suffixIcon: Icon(
                              Icons.check_circle_outline,
                              size: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      titleText(strings.CARD_HOLDER_NAME),
                      Container(
                        height: ScreenUtil().setHeight(60.84),
                        padding:
                            EdgeInsets.only(left: ScreenUtil().setWidth(24.0)),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color: Color(0XFFBBBDC1).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8.0)),
                        width: double.infinity,
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          minLines: 1,
                          onChanged: setName,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: '',
                            suffixIcon: Icon(
                              Icons.check_circle_outline,
                              size: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Expiry Date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleText(strings.EXPIRY_DATE),
                              Container(
                                height: ScreenUtil().setHeight(60.84),
                                width: ScreenUtil().setWidth(155.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(24.0)),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    color: Color(0XFFBBBDC1).withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                    CardExpiryInputFormatter(),
                                  ],
                                  minLines: 1,
                                  onChanged: setExpiryDate,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: '',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          //CVV
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleText(strings.CVV),
                              Container(
                                height: ScreenUtil().setHeight(60.84),
                                width: ScreenUtil().setWidth(155.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(24.0)),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    color: Color(0XFFBBBDC1).withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  minLines: 1,
                                  onChanged: setCvv,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: '',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: ScreenUtil().setHeight(33.0)),
                        child: Row(
                          children: [
                            CustomSwitch(
                              value: _value,
                              valueChanged: valueChanged,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(16.0)),
                            Text(
                              strings.REMEMBER_CARD_DETAILS,
                              style: titleTextStyle,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setHeight(50.0),
                            bottom: ScreenUtil().setHeight(29.0)),
                        child: SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: Color(0XFF00983D),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.84)),
                            child: MaterialButton(
                              height: ScreenUtil().setHeight(56),
                              onPressed: addCard,
                              child: Center(
                                child: Text(
                                  strings.ADD_CARD,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          cardContainer(
                              asset: "assets/svg/master_card_sabarish.svg"),
                          cardContainer(
                              asset:
                                  "assets/svg/american_express_sabarish.svg"),
                          cardContainer(asset: "assets/svg/visa_sabarish.svg")
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Container cardContainer({String asset}) {
    return Container(
      height: ScreenUtil().setHeight(40),
      width: ScreenUtil().setWidth(48),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(9.0),
      ),
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(22.0)),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0XFFF5F5F8)),
        borderRadius: BorderRadius.circular(8.54),
      ),
      child: FittedBox(fit: BoxFit.contain, child: SvgPicture.asset(asset)),
    );
  }

  Padding titleText(String title) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(21.0),
          bottom: ScreenUtil().setHeight(7.0)),
      child: Text(
        title,
        style: titleTextStyle,
      ),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({Key key, @required bool value, this.valueChanged})
      : _value = value,
        super(key: key);

  final bool _value;
  final Function valueChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: valueChanged,
      child: Container(
        height: ScreenUtil().setHeight(23),
        width: ScreenUtil().setWidth(23),
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: values.NESTO_GREEN, width: 2.0)),
        child: Center(
          child: Container(
            height: ScreenUtil().setHeight(13),
            width: ScreenUtil().setWidth(13),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _value ? values.NESTO_GREEN : Colors.transparent),
          ),
        ),
      ),
    );
  }
}

//styles
const titleTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0XFF898B9A),
);
