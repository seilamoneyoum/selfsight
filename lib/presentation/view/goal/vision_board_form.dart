import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/priority.dart';
import 'package:selfsight/presentation/view/goal/form/confirm_button.dart';
import 'package:selfsight/presentation/view/goal/form/text.dart';
import 'package:selfsight/presentation/view/goal/form/build_dropdown_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:selfsight/presentation/view/goal/form/input_decoration.dart';
import 'package:selfsight/presentation/view/goal/form/title_field.dart';

// Create a Form widget.
class VisionBoardForm extends StatefulWidget {
  const VisionBoardForm({super.key});

  @override
  VisionBoardFormState createState() {
    return VisionBoardFormState();
  }
}

class VisionBoardFormState extends State<VisionBoardForm> {
  final _formKey = GlobalKey<FormState>();

  Category? selectedCategory;
  Priority? selectedPriority;
  DateTime? selectedStartDate;
  bool isStartDateToggleOn = false;
  DateTime? selectedEndDate;
  bool isEndDateToggleOn = false;
  bool isAccomplished = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [titleField(), confirmButton(_formKey, context)],
      ),
    );
  }
}
