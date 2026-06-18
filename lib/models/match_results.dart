
import 'package:map_initialization/models/found_items.dart';

import 'lost_items.dart';


class MatchResult {
  final LostItems? lostItem;
  final FoundItems? foundItem;
  final int score;

  MatchResult({
    required this.lostItem,
    required this.score,
    this.foundItem,
  });

}