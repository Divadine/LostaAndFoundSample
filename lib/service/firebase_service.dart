import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_initialization/models/found_items.dart';
import 'package:map_initialization/models/lost_items.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> addLostItems(LostItems lostItems) async{
    await firestore.collection("lost_items").add(lostItems.toFirestore());
  }


  Future<void> addFoundItems(FoundItems foundItems) async {
    await firestore.collection('found_items').add(foundItems.toFirestore());
  }



}

