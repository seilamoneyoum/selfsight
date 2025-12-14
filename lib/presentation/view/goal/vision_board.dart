import 'package:selfsight/presentation/view/goal/vision_board/tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class VisionBoard extends StatelessWidget {
  const VisionBoard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StaggeredGrid.count(
        crossAxisCount: 4, // Number of grid per line
        mainAxisSpacing: 0, // White spaces between lines
        crossAxisSpacing: 0, // White spaces between columns
        children: const [
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Tile(index: 0),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Tile(index: 1),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Tile(index: 2),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Tile(index: 3),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Tile(index: 4),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Tile(index: 5),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Tile(index: 6),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: Tile(index: 7),
          )
        ],
      ),
    );
  }
}
