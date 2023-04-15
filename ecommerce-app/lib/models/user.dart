import 'package:Nesto/models/address.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  //Values which cannot be changed

  //Values which can be changed
  int id;
  Gender gender;
  DateTime createdAt;
  String firstName, lastName, emailAddress, phoneNumber, dob, nationality;
  List<Address> addresses;

  User(
      {this.id,
      this.gender,
      this.createdAt,
      this.firstName,
      this.lastName,
      this.emailAddress,
      this.phoneNumber,
      this.addresses,
      this.dob,
      this.nationality});

  void addAddressToUser(Address address) {
    addresses.add(address);
    notifyListeners();
  }
}

enum Gender { male, female, none }
