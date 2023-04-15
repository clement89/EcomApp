// To parse this JSON data, do
//
//     final substitutesuggestion = substitutesuggestionFromJson(jsonString);

import 'dart:convert';

import 'package:Nesto/models/product.dart';
import 'package:http/http.dart';

Substitutesuggestion substitutesuggestionFromJson(Response response) =>
    Substitutesuggestion.fromJson(json.decode(utf8.decode(response.bodyBytes)));

class Substitutesuggestion {
  Substitutesuggestion({
    this.data,
    this.message,
    this.source,
    this.success,
  });

  Data data;
  String message;
  String source;
  bool success;

  factory Substitutesuggestion.fromJson(Map<String, dynamic> json) =>
      Substitutesuggestion(
        data: Data.fromJson(json["data"]),
        message: json["message"],
        source: json["source"],
        success: json["success"],
      );
}

class Data {
  Data({
    this.items,
  });

  List<Product> items;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        items: List<Product>.from(
            json["items"].map((x) => Product.fromJson(x, true))),
      );
}
