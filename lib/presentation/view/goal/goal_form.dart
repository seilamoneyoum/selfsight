import 'package:flutter/material.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/priority.dart';
import 'package:selfsight/presentation/view/goal/form/confirm_button.dart';
import 'package:selfsight/presentation/view/goal/form/text.dart';
import 'package:selfsight/presentation/view/goal/form/build_dropdown_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:selfsight/presentation/view/goal/form/input_decoration.dart';
import 'package:selfsight/presentation/view/goal/form/title_field.dart';

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
        text("Is accomplished?"),
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
            SizedBox(width: 90, child: text(label)),
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
      child: text(isStartDateBtn
          ? (selectedStartDate != null
              ? selectedStartDate.toString().substring(0, 10)
              : DateTime.now().toString().substring(0, 10))
          : (selectedEndDate != null
              ? selectedEndDate.toString().substring(0, 10)
              : DateTime.now().toString().substring(0, 10))),
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
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime(DateTime.now().year + 100),
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
}
