import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class LostItems {

  final String itemName;
  final String description;
  final String categoryType;
  final DateTime lostDate;
  final LatLng location;
  final String? picture;
  final String? address;

  const LostItems({required this.itemName, required this.description, required this.categoryType, required this.lostDate, required this.location, this.picture, this.address});

  factory LostItems.fromJson(Map<String,dynamic> json) {
    return LostItems(
        itemName: json['itemName'],
        description: json['description'],
        categoryType: json['categoryType'],
      location: LatLng(json['latitude'], json['longitude']),
        lostDate: DateTime.parse(json['lostDate']),
      picture: json['picture'],
        address:json['address']
    );
  }

  Map<String,dynamic> toMap() {
    return {
      'itemName' : itemName,
      'description':description,
      'categoryType':categoryType,
      'lostDate' : lostDate.toIso8601String(),
      'latitude': location.latitude,
      'longitude': location.longitude,
      'picture':picture,
      'address' : address,
      //'location':location,
    };
  }
}