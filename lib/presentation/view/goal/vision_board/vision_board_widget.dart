import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';

class VisionBoardView extends StatefulWidget {
  const VisionBoardView({super.key});
  @override
  State<VisionBoardView> createState() => _VisionBoardViewState();
}

class _VisionBoardViewState extends State<VisionBoardView> {
  List<VisionBoardItem> list = [];
  XFile? _pickedImage;

  // SIMPLE FUNCTION TO PICK IMAGE
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show option: Camera or Gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

// After picking image, create a draggable widget
  Widget _buildVisionBoardImage() {
    return Positioned(
      //left: 100, // Set position
      //top: 100,
      child: Draggable(
        feedback: Image.file(
          // What shows while dragging
          File(_pickedImage!.path),
          width: 150,
          height: 150,
        ),
        childWhenDragging: Container(),
        child: Image.file(
          File(_pickedImage!.path),
          width: 150,
          height: 150,
        ), // Empty when dragging
      ),
    );
  }

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
            body: Column(
              children: <Widget>[
                Expanded(
                    flex: 6,
                    child: SizedBox(
                      child: _pickedImage != null
                          ? _buildVisionBoardImage()
                          : Container(), // Or any other placeholder widget when no image is picked
                    )),
                Column(
                  children: [
                    // Button to pick image
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Add Image to Vision Board'),
                    ),
                  ],
                ),
                Expanded(
                  flex: 3,
                  child: Container(color: Colors.yellow),
                ),
              ],
            )));
  }
}
