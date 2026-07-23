import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';
import 'package:selfsight/presentation/view/general/title_interface.dart';

class VisionBoardView extends StatefulWidget {
  const VisionBoardView({super.key});
  @override
  State<VisionBoardView> createState() => _VisionBoardViewState();
}

class _VisionBoardViewState extends State<VisionBoardView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => VisionBoardViewModel(),
        builder: (context, viewModel, child) {
          viewModel as VisionBoardViewModel;
          return Scaffold(
            appBar: AppBar(title: titleInterface("Vision board")),
            body: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: viewModel.isImageBackgroundSelected
                        ? BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(viewModel.backgroundImage!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    color: viewModel.isImageBackgroundSelected
                        ? null
                        : viewModel.backgroundColor,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: Stack(children: showImages(viewModel)),
                  ),
                  addImageButton(viewModel),
                  selectBackgroundButton(context, viewModel)
                ],
              ),
            ),
          );
        });
  }
}

List<Widget> showImages(VisionBoardViewModel viewModel) {
  List<Widget> images = [];
  for (VisionBoardItem item in viewModel.allElements) {
    images.add(
      Positioned(
        left: item.position.dx,
        top: item.position.dy,
        child: GestureDetector(
          onTap: () {
            // Affiche l'option delete
          },
          //onScaleUpdate: (details) {
          // Mise à jour de la taille de l'image de l'image
          //},
          onPanUpdate: (details) {
            // Mise à jour de la position de l'image
            item.position = Offset(
              item.position.dx + details.delta.dx,
              item.position.dy + details.delta.dy,
            );
            viewModel.selectedIndex = item.id;
            viewModel.notifyListeners();
          },
          onPanEnd: (details) {},
          child: Transform.rotate(
            angle: item.rotation,
            child: Image.file(
              File(item.imagePath),
              width: item.size.width,
              height: item.size.height,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
  return images;
}

ElevatedButton addImageButton(VisionBoardViewModel viewModel) {
  return ElevatedButton(
      onPressed: () {
        viewModel.pickMultipleImages();
      },
      child: Text("Add Image",
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black)));
}

ElevatedButton selectBackgroundButton(
    BuildContext context, VisionBoardViewModel viewModel) {
  return ElevatedButton(
      onPressed: () {
        _showOptionMenu(context, viewModel);
      },
      child: Text("Select background",
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black)));
}

void _showOptionMenu(BuildContext context, VisionBoardViewModel viewModel) {
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
                viewModel.pickBackgroundImage();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Cancel'),
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
      Color tempColor = viewModel.backgroundColor;
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
              viewModel.backgroundColor = tempColor;
              Navigator.pop(context);
            },
            child: Text('Apply'),
          ),
        ],
      );
    },
  );
}
