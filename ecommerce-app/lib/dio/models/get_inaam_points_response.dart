// To parse this JSON data, do
//
//     final getInaamPointsResponse = getInaamPointsResponseFromJson(jsonString);

import 'dart:convert';

GetInaamPointsResponse getInaamPointsResponseFromJson(String str) =>
    GetInaamPointsResponse.fromJson(json.decode(str));

String getInaamPointsResponseToJson(GetInaamPointsResponse data) =>
    json.encode(data.toJson());

class GetInaamPointsResponse {
  GetInaamPointsResponse({
    this.cardNo,
    this.total,
    this.lifetimePoint,
  });

  String cardNo;
  double total;
  double lifetimePoint;

  factory GetInaamPointsResponse.fromJson(Map<String, dynamic> json) =>
      GetInaamPointsResponse(
        cardNo: json["card_no"] == null ? null : json["card_no"],
        total: json["total"] == null
            ? null
            : double.parse(json["total"].toString()),
        lifetimePoint: json["lifetime_point"] == null
            ? null
            : double.parse(json["lifetime_point"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "card_no": cardNo == null ? null : cardNo,
        "total": total == null ? null : total,
        "lifetime_point": lifetimePoint == null ? null : lifetimePoint,
      };
}
