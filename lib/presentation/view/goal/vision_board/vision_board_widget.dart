import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/view/goal/vision_board/background_manipulations.dart';
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      if (viewModel.isRotateBtnClicked)
                        Slider(
                          value: viewModel.selectedItem!.rotation,
                          onChanged: (value) {
                            setState(() {
                              viewModel.selectedItem!.rotation = value;
                              viewModel.notifyListeners();
                            });
                          },
                          min: 0,
                          max: 6.2832,
                        ),
                      if (viewModel.isResizeBtnClicked)
                        Slider(
                          value: viewModel.selectedItem!.scale,
                          onChanged: (value) {
                            setState(() {
                              viewModel.selectedItem!.scale = value;
                              viewModel.notifyListeners();
                            });
                          },
                          min: 1,
                          max: 10,
                        ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        addImageButton(viewModel),
                        selectBackgroundButton(context, viewModel)
                      ]),
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
            viewModel.resetValues();
            viewModel.selectItem(item.id);
          },
          onPanStart: (details) {
            viewModel.resetValues();
          },
          onPanUpdate: (details) {
            // Mise à jour de la position de l'image
            item.position = Offset(
              item.position.dx + details.delta.dx,
              item.position.dy + details.delta.dy,
            );
            viewModel.notifyListeners();
          },
          onPanEnd: (details) {
            viewModel.selectItem(item.id);
          },
          child: Stack(
            children: [
              Transform.rotate(
                angle: item.rotation,
                child: Image.file(
                  File(item.imagePath),
                  width: item.size.width,
                  height: item.size.height,
                  fit: BoxFit.cover,
                ),
              ),
              if (viewModel.selectedId == item.id)
                removeImageButton(viewModel, item),
              if (viewModel.selectedId == item.id)
                rotateImageButton(viewModel, item),
              if (viewModel.selectedId == item.id)
                resizeImageButton(viewModel, item)
            ],
          ),
        ),
      ),
    );
  }
  return images;
}

Positioned removeImageButton(
    VisionBoardViewModel viewModel, VisionBoardItem item) {
  return Positioned(
      right: 0,
      top: 0,
      child: GestureDetector(
        onTap: () => viewModel.removeItem(item.id),
        child: Container(
          decoration:
              const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.close, color: Colors.white, size: 13),
        ),
      ));
}

Positioned rotateImageButton(
    VisionBoardViewModel viewModel, VisionBoardItem item) {
  return Positioned(
      right: 0,
      left: 0,
      top: 0,
      child: GestureDetector(
        onTap: () {
          viewModel.isRotateBtnClicked = true;
          viewModel.isResizeBtnClicked = false;
          viewModel.notifyListeners();
        },
        child: Container(
          decoration:
              const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.rotate_left, color: Colors.white, size: 13),
        ),
      ));
}

Positioned resizeImageButton(
    VisionBoardViewModel viewModel, VisionBoardItem item) {
  return Positioned(
      left: 0,
      top: 0,
      child: GestureDetector(
        onTap: () {
          viewModel.isRotateBtnClicked = false;
          viewModel.isResizeBtnClicked = true;
          viewModel.notifyListeners();
        },
        child: Container(
          decoration:
              const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.crop, color: Colors.white, size: 13),
        ),
      ));
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
        showOptionMenu(context, viewModel);
      },
      child: Text("Select background",
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black)));
}
