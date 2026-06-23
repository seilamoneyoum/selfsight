import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';

class VisionBoard {
  final List<VisionBoardItem> items;
  final Size boardSize;
  final String snapshot;

  const VisionBoard(List list,
      {required this.snapshot,
      this.items = const [],
      this.boardSize = const Size(1000, 1000)});

  List<VisionBoardItem>? get elements => null;
}
