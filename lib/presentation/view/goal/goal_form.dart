import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/priority.dart';
import 'package:selfsight/presentation/view/general/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:selfsight/presentation/view/general/input_decoration.dart';
import 'package:selfsight/presentation/view/general/title_field.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';

class GoalForm extends StatefulWidget {
  final GoalViewModel viewModel;

  const GoalForm({required this.viewModel, super.key});

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
          visionBoardButton(_formKey, context),
          titleField(),
          SizedBox(height: 12),
          categoryDropdown(),
          SizedBox(height: 12),
          dateField("Start date", true),
          SizedBox(height: 12),
          dateField("End date", false),
          SizedBox(height: 12),
          isAccomplishedCheckbox(),
          SizedBox(height: 12),
          priorityDropdown(),
          SizedBox(height: 30),
          confirmButton(_formKey, context)
        ],
      ),
    );
  }

  ElevatedButton visionBoardButton(
      GlobalKey<FormState> formKey, BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            widget.viewModel.navigateToVisionBoardView();
          }
        },
        child: Text(
          "Set Vision Board",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black,
          ),
        ));
  }

  List<DropdownMenuItem<T>> buildDropdownItems<T>({
    required List<T> values,
    required IconData Function(T) getIcon,
    required String Function(T) getLabel,
  }) {
    return values.map((value) {
      return DropdownMenuItem<T>(
        value: value,
        child: Row(
          children: [
            Icon(getIcon(value)),
            const SizedBox(width: 8),
            Text(
              getLabel(value),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
    }).toList();
  }

  DropdownButtonFormField<Category> categoryDropdown() {
    return DropdownButtonFormField<Category>(
      decoration: inputDecoration("Category"),
      initialValue: selectedCategory,
      isExpanded: true,
      items: buildDropdownItems<Category>(
        values: Category.values,
        getIcon: (c) => c.icon,
        getLabel: (c) => c.title,
      ),
      onChanged: (Category? newValue) {
        setState(() {
          selectedCategory = newValue;
        });
      },
    );
  }

  Row isAccomplishedCheckbox() {
    return Row(
      children: [
        Text(
          "Is accomplished?",
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
                )),
            SizedBox(
              width: 60,
              child: Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: isStartDateBtn
                        ? isStartDateToggleOn
                        : isEndDateToggleOn,
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
                  )),
            ),
            if (isStartDateBtn ? isStartDateToggleOn : isEndDateToggleOn)
              toggleDateButton(isStartDateBtn)
          ],
        ));
  }

  Widget toggleDateButton(bool isStartDateBtn) {
    return ElevatedButton(
      onPressed: isStartDateBtn
          ? (isStartDateToggleOn ? () => selectDate(context, true) : null)
          : (isEndDateToggleOn ? () => selectDate(context, false) : null),
      child: Text(
        (isStartDateBtn
            ? (selectedStartDate != null
                ? selectedStartDate.toString().substring(0, 10)
                : DateTime.now().toString().substring(0, 10))
            : (selectedEndDate != null
                ? selectedEndDate.toString().substring(0, 10)
                : DateTime.now().toString().substring(0, 10))),
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.black,
        ),
      ),
    );
  }

  Theme theme(Widget? widget) {
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
      child: widget!,
    );
  }

  Future<DateTime?> pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 50),
      lastDate: DateTime(DateTime.now().year + 50),
      builder: (context, child) {
        return theme(child);
      },
    );
  }

  void updateSelectedDate(DateTime picked, bool isStartDateBtn) {
    setState(() {
      if (isStartDateBtn) {
        selectedStartDate = picked;
      } else {
        selectedEndDate = picked;
      }
    });
  }

  Future<void> selectDate(BuildContext context, bool isStartDateBtn) async {
    final DateTime? picked = await pickDate(context);

    if (picked != null) {
      if (isStartDateBtn && picked != selectedStartDate) {
        updateSelectedDate(picked, true);
      } else if (!isStartDateBtn && picked != selectedEndDate) {
        updateSelectedDate(picked, false);
      }
    }
  }

  DropdownButtonFormField<Priority> priorityDropdown() {
    return DropdownButtonFormField<Priority>(
      decoration: inputDecoration("Priority"),
      initialValue: selectedPriority,
      isExpanded: true,
      items: buildDropdownItems<Priority>(
          values: Priority.values,
          getIcon: (p) => p.icon,
          getLabel: (p) => p.level),
      onChanged: (Priority? newValue) {
        setState(() {
          selectedPriority = newValue;
        });
      },
    );
  }

  ElevatedButton confirmButton(
      GlobalKey<FormState> formKey, BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Data')),
            );
          }
        },
        child: Text("Confirm",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black)));
  }
}
