import 'package:flutter/material.dart';
import 'package:map_initialization/models/found_items.dart';

import 'lost_items.dart';


class MatchResult {
  final LostItems lostItem;
  final int score;

  MatchResult({
    required this.lostItem,
    required this.score,
  });



}