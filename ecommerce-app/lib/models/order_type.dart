import 'package:Nesto/models/order.dart';

class Ongoing {
  final String status;
  final SingleOrder order;
  Ongoing({this.status, this.order});
}

class Completed {
  final String status;
  final SingleOrder order;
  Completed({this.status, this.order});
}
