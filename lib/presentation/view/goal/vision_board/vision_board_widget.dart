import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';

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
        builder: (context, viewModel, child) => Scaffold(
              appBar: AppBar(
                title: Text(
                  "Vision board",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              body: SizedBox(
                width: double
                    .infinity, // 1. Forces the Column to take up the full screen width
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .start, // 2. Keeps the content at the very top
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // 3. Centers the Stack horizontally
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      child: Stack(
                          children:
                              showImages(viewModel as VisionBoardViewModel)),
                    ),
                    addImageButton(viewModel),
                  ],
                ),
              ),
            ));
  }
}

List<Widget> showImages(VisionBoardViewModel viewModel) {
  List<Widget> images = [];
  for (VisionBoardItem item in viewModel.elements) {
    images.add(
      Positioned(
        left: item.position.dx,
        top: item.position.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            // Update position when dragging
            item.position = Offset(
              item.position.dx + details.delta.dx,
              item.position.dy + details.delta.dy,
            );
            viewModel.notifyListeners(); // Rebuild UI
          },
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
