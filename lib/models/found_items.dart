import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FoundItems {
  final int? id;
  final String itemName;
  final String description;
  final String categoryType;
  final DateTime foundDate;
  final LatLng location;
  final String? picture;
  final String? status;
  final String? address;


  const FoundItems({required this.itemName, required this.description, required this.categoryType, required this.foundDate, required this.location, this.picture, this.status, this.address, this.id});

  factory FoundItems.fromJson(Map<String,dynamic> json) {
    return FoundItems(
      id: json['id'],
        itemName: json['itemName'],
        description: json['description'],
        categoryType: json['categoryType'],
      foundDate: DateTime.parse(json['foundDate']),
        location: LatLng(json['latitude'], json['longitude']),
        picture:json['picture'],
        address:json['address'],
        status:json['status'],

    );
  }


  Map<String,dynamic> toMap() {
    return {
      'id':id,
      'itemName' : itemName,
      'description':description,
      'categoryType':categoryType,
      'foundDate' : foundDate.toIso8601String(),
      'latitude': location.latitude,
      'longitude': location.longitude,
      'picture':picture,
      'status' : status,
      'address':address,

    };
  }


}


