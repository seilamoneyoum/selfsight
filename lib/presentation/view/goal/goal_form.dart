import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/priority.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:selfsight/presentation/view/templates.dart';
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
  String? _title;
  Category? _selectedCategory;
  late Progress _selectedProgress;

  bool _isStartDateToggleOn = false;
  bool _isEndDateToggleOn = false;

  bool _hasTitleError = false;
  bool _hasCategoryError = false;
  bool _hasPriorityError = false;
  bool _hasDateError = false;

  @override
  void initState() {
    super.initState();
    _selectedProgress = Progress(isAccomplished: false);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          visionBoardButton(_formKey, context),
          SizedBox(height: 12),
          titleField(),
          if (_hasTitleError == true) errorMessage("Title is needed"),
          SizedBox(height: 12),
          categoryDropdown(),
          if (_hasCategoryError == true)
            errorMessage("Category needs to be selected"),
          SizedBox(height: 12),
          dateField("Start date", true, _selectedProgress),
          SizedBox(height: 12),
          dateField("End date", false, _selectedProgress),
          if (_hasDateError == true)
            errorMessage("End date needs to be after start date"),
          SizedBox(height: 12),
          isAccomplishedCheckbox(),
          SizedBox(height: 12),
          priorityDropdown(_selectedProgress),
          if (_hasPriorityError == true)
            errorMessage("Priority needs to be selected"),
          SizedBox(height: 30),
          confirmButton(_formKey, context, viewModel)
        ],
      ),
    );
  }

  // ======================== Sous-méthodes ====================================

  Text errorMessage(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 10,
        color: Colors.red,
      ),
    );
  }

  TextFormField titleField() {
    return TextFormField(
      decoration: labelInput("Title"),
      initialValue: _title,
      onChanged: (newTitle) {
        _title = newTitle;
      },
      style: GoogleFonts.poppins(fontSize: 12),
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
        child: message("Set Vision Board"));
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
      decoration: labelInput("Category"),
      initialValue: _selectedCategory,
      isExpanded: true,
      items: buildDropdownItems<Category>(
        values: Category.values,
        getIcon: (c) => c.icon,
        getLabel: (c) => c.title,
      ),
      onChanged: (Category? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
    );
  }

  Row isAccomplishedCheckbox() {
    return Row(
      children: [
        message("Is accomplished?"),
        Checkbox(
            checkColor: Colors.white,
            value: _selectedProgress.isAccomplished,
            onChanged: (bool? value) {
              setState(() {
                _selectedProgress.isAccomplished = value!;
              });
            })
      ],
    );
  }

  SizedBox dateField(
      String label, bool isStartDateBtn, Progress selectedProgress) {
    return SizedBox(
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 90, child: message(label)),
            SizedBox(
              width: 60,
              child: Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: isStartDateBtn
                        ? _isStartDateToggleOn
                        : _isEndDateToggleOn,
                    activeTrackColor: Colors.black, // track color when enabled
                    onChanged: (val) {
                      setState(() {
                        if (isStartDateBtn) {
                          _isStartDateToggleOn = val;
                        } else {
                          _isEndDateToggleOn = val;
                        }
                      });
                    },
                  )),
            ),
            if (isStartDateBtn ? _isStartDateToggleOn : _isEndDateToggleOn)
              toggleDateButton(isStartDateBtn, selectedProgress)
          ],
        ));
  }

  Widget toggleDateButton(bool isStartDateBtn, Progress selectedProgress) {
    return ElevatedButton(
        onPressed: isStartDateBtn
            ? (_isStartDateToggleOn
                ? () => selectDate(context, true, selectedProgress)
                : null)
            : (_isEndDateToggleOn
                ? () => selectDate(context, false, selectedProgress)
                : null),
        child: message(isStartDateBtn
            ? (_selectedProgress.startDate != null
                ? _selectedProgress.startDate.toString().substring(0, 10)
                : DateTime.now().toString().substring(0, 10))
            : (_selectedProgress.endDate != null
                ? _selectedProgress.endDate.toString().substring(0, 10)
                : DateTime.now().toString().substring(0, 10))));
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
        _selectedProgress.startDate = picked;
      } else {
        _selectedProgress.endDate = picked;
      }
    });
  }

  Future<void> selectDate(BuildContext context, bool isStartDateBtn,
      Progress selectedProgress) async {
    final DateTime? picked = await pickDate(context);

    if (picked != null) {
      if (isStartDateBtn && picked != selectedProgress.startDate) {
        updateSelectedDate(picked, true);
      } else if (!isStartDateBtn && picked != selectedProgress.endDate) {
        updateSelectedDate(picked, false);
      }
    }
  }

  DropdownButtonFormField<Priority> priorityDropdown(
      Progress selectedProgress) {
    return DropdownButtonFormField<Priority>(
      decoration: labelInput("Priority"),
      initialValue: selectedProgress.priority,
      isExpanded: true,
      items: buildDropdownItems<Priority>(
          values: Priority.values,
          getIcon: (p) => p.icon,
          getLabel: (p) => p.level),
      onChanged: (Priority? newValue) {
        setState(() {
          selectedProgress.priority = newValue;
        });
      },
    );
  }

  ElevatedButton confirmButton(
    GlobalKey<FormState> formKey,
    BuildContext context,
    GoalViewModel viewModel,
  ) {
    return ElevatedButton(
      onPressed: () {
        bool isValid = formKey.currentState!.validate();
        if (isValid) {
          formKey.currentState!.save();
        }

        setState(() {
          _hasTitleError = (_title == null || _title == "");
          _hasCategoryError = (_selectedCategory == null);
          _hasPriorityError = (_selectedProgress.priority == null);
          if (_selectedProgress.endDate != null &&
              _selectedProgress.startDate != null) {
            _hasDateError = (_selectedProgress.endDate
                ?.isBefore(_selectedProgress.startDate!))!;
          }

          viewModel.notifyListeners();
        });

        if (isValid &&
            !_hasTitleError &&
            !_hasCategoryError &&
            !_hasPriorityError &&
            !_hasDateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Processing Data')),
          );
          viewModel.addGoal(_title!, _selectedCategory!, _selectedProgress);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all fields correctly')),
          );
        }
      },
      child: message("Confirm"),
    );
  }
}
