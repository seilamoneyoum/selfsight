import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/priority.dart';
import 'package:flutter/cupertino.dart';

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
        children: [
          titleField(),
          SizedBox(height: 16), //ou Spacer()
          categoryDropdown(),
          SizedBox(height: 8),
          dateField("Start date", true),
          SizedBox(height: 8),
          dateField("End date", false),
          SizedBox(height: 8),
          isAccomplishedCheckbox(),
          SizedBox(height: 8),
          priorityDropdown(),
          SizedBox(height: 32),
          confirmButton()
        ],
      ),
    );
  }

  ElevatedButton confirmButton() {
    return ElevatedButton(
        onPressed: () {
          // Validate returns true if the form is valid, or false otherwise.
          if (_formKey.currentState!.validate()) {
            // If the form is valid, display a snackbar. In the real world,
            // you'd often call a server or save the information in a database.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Data')),
            );
          }
        },
        child: Text("Confirm",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black)));
  }

  Row isAccomplishedCheckbox() {
    return Row(
      children: [
        Text(
          "Is accomplished",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        Checkbox(
            checkColor: Colors.white,
            value: isAccomplished,
            onChanged: (bool? value) {
              setState(() {
                isAccomplished = value!;
              });
            })
      ],
    );
  }

  SizedBox dateField(String label, bool isStartDateBtn) {
    return SizedBox(
        height: 30,
        child: Row(
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
              child: CupertinoSwitch(
                value: isStartDateBtn ? isStartDateToggleOn : isEndDateToggleOn,
                activeTrackColor: Colors.black, // track color when enabled
                onChanged: (val) {
                  setState(() {
                    if (isStartDateBtn) {
                      isStartDateToggleOn = val;
                    } else {
                      isEndDateToggleOn = val;
                    }
                  });
                },
              ),
            ),
            if (isStartDateBtn ? isStartDateToggleOn : isEndDateToggleOn)
              ElevatedButton(
                onPressed: isStartDateBtn
                    ? (isStartDateToggleOn
                        ? () => selectDate(context, true)
                        : null)
                    : (isEndDateToggleOn
                        ? () => selectDate(context, false)
                        : null),
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
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ));
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

  DropdownButtonFormField<Priority> priorityDropdown() {
    return DropdownButtonFormField<Priority>(
      decoration: formInputDecoration("Priority"),
      initialValue: selectedPriority,
      isExpanded: true,
      items: Priority.values.map((Priority priority) {
        return DropdownMenuItem<Priority>(
          value: priority,
          child: Row(
            children: [
              Icon(priority.icon),
              SizedBox(width: 8),
              Text(
                priority.level,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (Priority? newValue) {
        setState(() {
          selectedPriority = newValue;
        });
      },
    );
  }

  DropdownButtonFormField<Category> categoryDropdown() {
    return DropdownButtonFormField<Category>(
      decoration: formInputDecoration("Category"),
      initialValue: selectedCategory,
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
    style: GoogleFonts.poppins(fontSize: 12),
  );
}
