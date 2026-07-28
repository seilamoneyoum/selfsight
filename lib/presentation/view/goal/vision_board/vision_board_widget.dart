import 'dart:io';
import 'package:flutter/material.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/view/goal/vision_board/background_manipulations.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';
import 'package:selfsight/presentation/view/templates.dart';

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
                  getBackgroundContainer(viewModel, context),
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

Container getBackgroundContainer(
    VisionBoardViewModel viewModel, BuildContext context) {
  return Container(
    decoration: viewModel.isImageBackgroundSelected
        ? BoxDecoration(
            image: DecorationImage(
              image: FileImage(viewModel.backgroundImage!),
              fit: BoxFit.cover,
            ),
          )
        : null,
    color:
        viewModel.isImageBackgroundSelected ? null : viewModel.backgroundColor,
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.width,
    child: Stack(children: showImages(viewModel)),
  );
}

List<Widget> showImages(VisionBoardViewModel viewModel) {
  List<Widget> images = [];
  for (VisionBoardItem item in viewModel.allElements) {
    images.add(
      Positioned(
        left: item.position.dx,
        top: item.position.dy,
        child: Stack(
          children: [
            GestureDetector(
              onScaleStart: (details) {
                viewModel.gestureStartScale = item.scale;
                viewModel.gestureStartRotation = item.rotation;
                viewModel.selectItem(item.id);
              },
              onScaleUpdate: (details) =>
                  gestureDetectorAct(details, viewModel, item),
              onScaleEnd: (details) {
                viewModel.gestureStartScale = null;
                viewModel.gestureStartRotation = null;
              },
              onTap: () {
                viewModel.selectItem(item.id);
              },
              child: Transform.rotate(
                angle: item.rotation,
                child: Image.file(
                  File(item.imagePath),
                  width: item.size.width * item.scale,
                  height: item.size.height * item.scale,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // --- OVERLAY BUTTONS (Remove, Rotate, Resize) ---
            if (viewModel.selectedId == item.id)
              removeImageButton(viewModel, item),
          ],
        ),
      ),
    );
  }
  return images;
}

void gestureDetectorAct(
  ScaleUpdateDetails details,
  VisionBoardViewModel viewModel,
  VisionBoardItem item,
) {
  if (details.pointerCount >= 2) {
    // Si l'écran détecte deux doigts touchés -> rotation + agrandir/rétrécir image
    double newScale = (viewModel.gestureStartScale ?? 1.0) * details.scale;
    item.scale = newScale.clamp(0.5, 5.0);

    item.rotation = (viewModel.gestureStartRotation ?? 0.0) + details.rotation;
  } else {
    // Sinon, déplacement de l'image
    item.position = Offset(
      item.position.dx + details.focalPointDelta.dx,
      item.position.dy + details.focalPointDelta.dy,
    );
  }
  viewModel.notifyListeners();
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

ElevatedButton addImageButton(VisionBoardViewModel viewModel) {
  return ElevatedButton(
      onPressed: () {
        viewModel.pickMultipleImages();
      },
      child: message("Add image"));
}

ElevatedButton selectBackgroundButton(
    BuildContext context, VisionBoardViewModel viewModel) {
  return ElevatedButton(
      onPressed: () {
        showOptionMenu(context, viewModel);
      },
      child: message("Select background"));
}
