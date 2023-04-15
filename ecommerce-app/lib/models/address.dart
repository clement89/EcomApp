import 'package:flutter/material.dart';

class Address with ChangeNotifier {
  final int id;
  String region,
      regionCode,
      countryId,
      street,
      postCode,
      city,
      name,
      telephone,
      email;
  int regionId;
  double latitude, longitude;
  String location;

  Address(
      {@required this.id,
      @required this.region,
      this.regionCode,
      this.countryId,
      @required this.street,
      @required this.postCode,
      @required this.city,
      @required this.name,
      @required this.telephone,
      @required this.email,
      this.latitude,
      this.longitude,
      this.location});

  Map toJson() => {
        'region': {
          "region_code": regionCode,
          "region": region,
          "region_id": regionId,
        },
        "region_id": regionId,
        "country_id": countryId,
        "street": [street],
        "telephone": telephone,
        "postcode": postCode,
        "city": city,
        "firstname": name,
        "lastname": name,
        "default_shipping": false,
        "default_billing": false,
        "custom_attributes": [
          {
            "attribute_code": "latitude",
            "value": latitude.toString(),
          },
          {
            "attribute_code": "longitude",
            "value": longitude.toString(),
          },
          {
            "attribute_code": "location",
            "value": location,
          }
        ]
      };
}
