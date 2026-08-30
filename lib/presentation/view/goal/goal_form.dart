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

class GoalFormState extends State<GoalForm> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();

  Category? selectedCategory;
  late Progress selectedProgress;

  bool _isStartDateToggleOn = false;
  bool _isEndDateToggleOn = false;

  bool _hasTitleError = false;
  bool _hasCategoryError = false;
  bool _hasPriorityError = false;
  bool _hasDateError = false;

  Object? _loadedGoalId;

  /// Appelée une seule fois, donc la première fois que ce GoalForm apparaît à l'écran
  @override
  void initState() {
    super.initState();
    selectedProgress = Progress(isAccomplished: false);
    _updateFieldsFromGoal();
  }

  /// Appelée quand le widget parent reconstruit ce GoalForm avec une nouvelle instance du widget
  @override
  void didUpdateWidget(covariant GoalForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentGoal = widget.viewModel.goal;
    if (currentGoal != null && currentGoal.id != _loadedGoalId) {
      _updateFieldsFromGoal();
    }
  }

  void _updateFieldsFromGoal() {
    final goal = widget.viewModel.goal;
    if (goal != null) {
      setState(() {
        titleController.text = goal.title;
        selectedCategory = goal.category;
        selectedProgress = goal.progress;
        _isStartDateToggleOn = goal.progress.startDate != null;
        _isEndDateToggleOn = goal.progress.endDate != null;
        _loadedGoalId = goal.id;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleField(),
          if (_hasTitleError) errorMessage("Title is needed"),
          const SizedBox(height: 12),
          categoryDropdown(),
          if (_hasCategoryError) errorMessage("Category needs to be selected"),
          const SizedBox(height: 12),
          dateField("Start date", true, selectedProgress),
          const SizedBox(height: 12),
          dateField("End date", false, selectedProgress),
          if (_hasDateError)
            errorMessage("End date needs to be after start date"),
          const SizedBox(height: 12),
          isAccomplishedCheckbox(),
          const SizedBox(height: 12),
          priorityDropdown(selectedProgress),
          if (_hasPriorityError) errorMessage("Priority needs to be selected"),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              confirmButton(_formKey, context, widget.viewModel),
              if (widget.viewModel.goal != null) deleteButton(widget.viewModel)
            ],
          )
        ],
      ),
    );
  }

  // ======================== Sous-méthodes ====================================
  TextFormField titleField() {
    return TextFormField(
      controller: titleController,
      decoration: labelInput("Title"),
      style: GoogleFonts.poppins(fontSize: 12),
    );
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
            message(getLabel(value)),
          ],
        ),
      );
    }).toList();
  }

  DropdownButtonFormField<Category> categoryDropdown() {
    return DropdownButtonFormField<Category>(
      decoration: labelInput("Category"),
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
        message("Is accomplished?"),
        Checkbox(
            checkColor: Colors.white,
            value: selectedProgress.isAccomplished,
            onChanged: (bool? value) {
              setState(() {
                selectedProgress.isAccomplished = value!;
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
                    activeTrackColor: Colors.black,
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
            ? (selectedProgress.startDate != null
                ? selectedProgress.startDate.toString().substring(0, 10)
                : "Select date")
            : (selectedProgress.endDate != null
                ? selectedProgress.endDate.toString().substring(0, 10)
                : "Select date")));
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
        selectedProgress.startDate = picked;
      } else {
        selectedProgress.endDate = picked;
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
        getLabel: (p) => p.level,
      ),
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
          _hasTitleError = (titleController.text == "");
          _hasCategoryError = (selectedCategory == null);
          _hasPriorityError = (selectedProgress.priority == null);
          if (_isEndDateToggleOn == false) selectedProgress.endDate = null;
          if (_isStartDateToggleOn == false) selectedProgress.startDate = null;
          if (selectedProgress.endDate != null &&
              selectedProgress.startDate != null) {
            _hasDateError = (selectedProgress.endDate
                ?.isBefore(selectedProgress.startDate!))!;
          }

          viewModel.notifyListeners();
        });

        if (isValid &&
            !_hasTitleError &&
            !_hasCategoryError &&
            !_hasPriorityError &&
            !_hasDateError) {
          if (viewModel.goalId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: message('New goal is added successfully ')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: message('Goal is saved successfully')),
            );
          }

          if (viewModel.goal == null) {
            viewModel.addGoal(
                titleController.text, selectedCategory!, selectedProgress);
          } else {
            viewModel.updateGoal(
                titleController.text, selectedCategory!, selectedProgress);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: message('Please fill all fields correctly')),
          );
        }
      },
      child: message(viewModel.goalId == null ? "Confirm" : "Save"),
    );
  }

  ElevatedButton deleteButton(GoalViewModel viewModel) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: subtitleInterface('Confirm Action'),
              content: message(
                  'Are you sure you want to delete the goal? Once you delete this goal, there is no way of retrieving it.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: message('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    viewModel.deleteGoal();
                  },
                  child: message('Confirm'),
                ),
              ],
            );
          },
        );
      },
      child: message("Delete"),
    );
  }
}
