import 'package:flutter/material.dart';
import 'package:goal_garden/presentation/view/goal/goal_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:goal_garden/domain/entities/goal/category.dart';
import 'package:flutter/cupertino.dart';
import 'package:getwidget/getwidget.dart';

// Create a Form widget.
class GoalForm extends StatefulWidget {
  const GoalForm({super.key});

  @override
  GoalFormState createState() {
    return GoalFormState();
  }
}

class GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();

  Category? selectedCategory;
  DateTime? selectedStartDate;
  bool isStartDateToggleOn = false;
  DateTime? selectedEndDate;
  bool isEndDateToggleOn = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleField(),
          SizedBox(height: 16),
          categoryDropdown(),
          SizedBox(
            height: 8,
          ),
          dateField("Start date", true),
          SizedBox(
            height: 8,
          ),
          dateField("End date", false),
        ],
      ),
    );
  }

  Row dateField(String label, bool isStartDateBtn) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
            width: 60,
            child: GFToggle(
              onChanged: (val) {
                setState(() {
                  if (isStartDateBtn) {
                    isStartDateToggleOn = val!;
                  } else {
                    isEndDateToggleOn = val!;
                  }
                });
              },
              value: isStartDateBtn ? isStartDateToggleOn : isEndDateToggleOn,
              type: GFToggleType.ios,
              enabledTrackColor: Colors.black,
            )),
        ElevatedButton(
          onPressed: isStartDateBtn
              ? (isStartDateToggleOn ? () => selectDate(context, true) : null)
              : (isEndDateToggleOn ? () => selectDate(context, false) : null),
          child: Text(
            isStartDateBtn
                ? (selectedStartDate != null
                    ? selectedStartDate.toString().substring(0, 10)
                    : DateTime.now().toString().substring(0, 10))
                : (selectedEndDate != null
                    ? selectedEndDate.toString().substring(0, 10)
                    : DateTime.now().toString().substring(0, 10)),
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> selectDate(BuildContext context, bool isStartDateBtn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime(DateTime.now().year + 100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartDateBtn == true && picked != selectedStartDate) {
        setState(() {
          selectedStartDate = picked;
        });
      } else if (isStartDateBtn == false && picked != selectedEndDate) {
        setState(() {
          selectedEndDate = picked;
        });
      }
    }
  }

  DropdownButtonFormField<Category> categoryDropdown() {
    return DropdownButtonFormField<Category>(
      decoration: formInputDecoration("Category"),
      value: selectedCategory,
      isExpanded: true,
      items: Category.values.map((Category category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Row(
            children: [
              Icon(category.icon),
              SizedBox(width: 8),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (Category? newValue) {
        setState(() {
          selectedCategory = newValue;
        });
      },
    );
  }
}

InputDecoration formInputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black,
      ));
}

TextFormField titleField() {
  return TextFormField(
    decoration: formInputDecoration("Title"),
    style: GoogleFonts.poppins(fontSize: 13),
  );
}
