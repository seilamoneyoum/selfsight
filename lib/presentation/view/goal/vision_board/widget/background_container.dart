import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';

void showOptionMenu(BuildContext context, VisionBoardViewModel viewModel) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
                title: const Text('Select color background'),
                onTap: () {
                  _showColorPicker(context, viewModel);
                }),
            ListTile(
              title: const Text('Select image background'),
              onTap: () {
                viewModel.backgroundLogic.pickBackgroundImage();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Close'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showColorPicker(BuildContext context, VisionBoardViewModel viewModel) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Color tempColor = viewModel.backgroundLogic.backgroundColor;
      return AlertDialog(
        title: Text('Pick a color'),
        content: ColorPicker(
          pickerColor: tempColor,
          onColorChanged: (Color color) {
            tempColor = color;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.backgroundLogic.backgroundColor = tempColor;
              Navigator.pop(context);
            },
            child: Text('Apply'),
          ),
        ],
      );
    },
  );
}
