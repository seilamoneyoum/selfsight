import 'dart:io';
import 'package:flutter/material.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/view/goal/vision_board/widget/background_container.dart';
import 'package:selfsight/presentation/view/goal/vision_board/widget/align_images_container.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';
import 'package:selfsight/presentation/view/templates.dart';

class VisionBoardWidget extends StatefulWidget {
  final VisionBoardViewModel viewModel;

  const VisionBoardWidget({super.key, required this.viewModel});

  @override
  State<VisionBoardWidget> createState() => _VisionBoardWidgetState();
}

class _VisionBoardWidgetState extends State<VisionBoardWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getBackgroundContainer(widget.viewModel, context),
              widget.viewModel.alignImagesLogic.isAlignMode
                  ? alignImagesContainer(context, widget.viewModel)
                  : mainOptions(context)
            ]));
  }

  Column mainOptions(BuildContext context) {
    return Column(
      children: [
        if (widget.viewModel.selectedId != "-1")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  imageOptions(widget.viewModel),
                  ElevatedButton(
                    onPressed: () {
                      widget.viewModel.alignImagesLogic
                          .setAlignImagesMode(true);
                    },
                    child: message("Align images"),
                  )
                ],
              )
            ],
          ),
        Wrap(
          // Ligne de boutons d'ajout d'image et de sélectionner le type de fond d'écran
          alignment: WrapAlignment.spaceBetween,
          spacing: 50,
          children: [
            ElevatedButton(
              onPressed: () {
                widget.viewModel.pickMultipleImages();
              },
              child: message("Add image"),
            ),
            ElevatedButton(
              onPressed: () {
                showOptionMenu(context, widget.viewModel);
              },
              child: message("Select background"),
            ),
          ],
        ),
      ],
    );
  }

  // Affichage des images (lors du chargement, d'ajout de l'image ou de suppression de l'image)
  List<Widget> showImages(VisionBoardViewModel viewModel) {
    List<Widget> images = [];
    for (VisionBoardItem item in viewModel.allElements) {
      images.add(
        Positioned(
          left: item.position.dx,
          top: item.position.dy,
          child: GestureDetector(
            onScaleStart: (details) {
              viewModel.gestureStartScale = item.scale;
              viewModel.gestureStartRotation = item.rotation;
              if (!viewModel.alignImagesLogic.isAlignMode) {
                viewModel.selectItem(item.id);
              }
            },
            onScaleUpdate: (details) =>
                gestureDetectorAct(details, viewModel, item),
            onScaleEnd: (details) {
              viewModel.gestureStartScale = null;
              viewModel.gestureStartRotation = null;
            },
            onTap: () {
              if (viewModel.alignImagesLogic.isAlignMode &&
                  viewModel.selectedId != item.id) {
                if (viewModel.alignImagesLogic.selectedIds.contains(item.id)) {
                  viewModel.alignImagesLogic.selectedIds.remove(item.id);
                  viewModel.notifyListeners();
                } else {
                  viewModel.alignImagesLogic.selectedIds.add(item.id);
                  viewModel.notifyListeners();
                }
              } else if (!viewModel.alignImagesLogic.isAlignMode) {
                viewModel.selectItem(item.id);
              }
            },
            child: Transform.rotate(
              angle: item.rotation,
              child: Stack(
                children: [
                  Image.file(
                    File(item.imagePath),
                    width: item.size.width * item.scale,
                    height: item.size.height * item.scale,
                    fit: BoxFit.cover,
                  ),
                  if (viewModel.selectedId == item.id)
                    IgnorePointer(
                      child: Container(
                        width: item.size.width * item.scale,
                        height: item.size.height * item.scale,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            width: 4.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    )
                  else if (viewModel.alignImagesLogic.selectedIds
                      .contains(item.id))
                    IgnorePointer(
                      child: Container(
                        width: item.size.width * item.scale,
                        height: item.size.height * item.scale,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                            width: 4.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      );
    }
    return images;
  }

  Widget imgSelectedWithBorder(VisionBoardItem item) {
    return IgnorePointer(
      child: Container(
        width: item.size.width * item.scale,
        height: item.size.height * item.scale,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 4.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }

  // Détection du movement des doigts (Changement par rapport à la taille et à la rotation de l'image)
  void gestureDetectorAct(
    ScaleUpdateDetails details,
    VisionBoardViewModel viewModel,
    VisionBoardItem item,
  ) {
    if (details.pointerCount >= 2) {
      double newScale = (viewModel.gestureStartScale ?? 1.0) * details.scale;
      item.scale = newScale.clamp(0.5, 5.0);
      item.rotation =
          (viewModel.gestureStartRotation ?? 0.0) + details.rotation;
    } else {
      item.position = Offset(
        item.position.dx + details.focalPointDelta.dx,
        item.position.dy + details.focalPointDelta.dy,
      );
    }
    viewModel.notifyListeners();
  }

  ElevatedButton addImageButton(VisionBoardViewModel viewModel) {
    return ElevatedButton(
      onPressed: () {
        viewModel.pickMultipleImages();
      },
      child: message("Add image"),
    );
  }

  // Ligne des options de l'image sélectionné
  Wrap imageOptions(VisionBoardViewModel viewModel) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton(
          onPressed: () {
            viewModel.imageLogic.removeItem(viewModel.selectedId);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 28),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            viewModel.imageLogic.resetRotation();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rotate_right, size: 28),
            ],
          ),
        ),
      ],
    );
  }
  // =================================== BACKGROUND =========================================================

  // Met à jour l'image ou la couleur de l'arrière-plan de vision board
  ElevatedButton selectBackgroundButton(
      BuildContext context, VisionBoardViewModel viewModel) {
    return ElevatedButton(
      onPressed: () {
        showOptionMenu(context, viewModel);
      },
      child: message("Select background"),
    );
  }

  // Charger l'image ou la couleur de l'arrière-plan de vision board
  Container getBackgroundContainer(
      VisionBoardViewModel viewModel, BuildContext context) {
    return Container(
      decoration: viewModel.backgroundLogic.isImageBackgroundSelected
          ? BoxDecoration(
              image: DecorationImage(
                image: FileImage(viewModel.backgroundLogic.backgroundImage!),
                fit: BoxFit.cover,
              ),
            )
          : null,
      color: viewModel.backgroundLogic.isImageBackgroundSelected
          ? null
          : viewModel.backgroundLogic.backgroundColor,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      child: Stack(children: showImages(viewModel)),
    );
  }
}
