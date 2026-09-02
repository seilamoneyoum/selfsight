import 'dart:io';
import 'package:flutter/material.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/view/goal/vision_board/widget/background_container.dart';
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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getBackgroundContainer(widget.viewModel, context),
          mainOptions(context),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: saveButton(context, widget.viewModel),
          ),
        ],
      ),
    );
  }

  Column mainOptions(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        if (widget.viewModel.selectedId != "-1")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  imageOptions(widget.viewModel),
                ],
              )
            ],
          ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 50,
          children: [
            ElevatedButton(
              onPressed: () {
                widget.viewModel.pickMultipleImages();
              },
              child: message("Add image(s)"),
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

  Widget saveButton(BuildContext context, VisionBoardViewModel viewModel) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
        onPressed: viewModel.isBusy
            ? null
            : () async {
                await viewModel.saveVisionBoard();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: message('Vision board saved successfully')),
                );
              },
        child: message("Save"),
      ),
    );
  }

  // ======================== Sous-méthodes existantes (inchangées) ====================================

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
                        /*decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            width: 4.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),*/
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
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            fixedSize: const Size(40, 40),
          ),
          child: const Icon(Icons.delete_outline, size: 20),
        ),
        // Reset rotation
        ElevatedButton(
          onPressed: () {
            viewModel.imageLogic.resetRotation();
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            fixedSize: const Size(40, 40),
          ),
          child: const Icon(Icons.rotate_right, size: 20),
        ),
        ElevatedButton(
          onPressed: () {
            viewModel.bringForward(viewModel.selectedId);
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            fixedSize: const Size(40, 40),
          ),
          child: const Icon(Icons.arrow_upward, size: 20),
        ),
        // Send backward (down)
        ElevatedButton(
          onPressed: () {
            viewModel.sendBackward(viewModel.selectedId);
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            fixedSize: const Size(40, 40),
          ),
          child: const Icon(Icons.arrow_downward, size: 20),
        ),
      ],
    );
  }

  ElevatedButton selectBackgroundButton(
      BuildContext context, VisionBoardViewModel viewModel) {
    return ElevatedButton(
      onPressed: () {
        showOptionMenu(context, viewModel);
      },
      child: message("Select background"),
    );
  }

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
