import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/domain/entities/task/frequency.dart';
import 'package:selfsight/presentation/view/goal/task/task_helpers.dart';
import 'package:selfsight/presentation/view/goal/task/task_viewmodel.dart';
import 'package:selfsight/presentation/view/templates.dart';

class TaskFormSheet extends StatefulWidget {
  final TaskViewModel viewModel;

  const TaskFormSheet({required this.viewModel});

  @override
  State<TaskFormSheet> createState() => TaskFormSheetState();
}

class TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  Unit? selectedUnit;
  List<Day> selectedDays = [];

  bool _hasNameError = false;
  bool _hasValueError = false;
  bool _hasUnitError = false;
  bool _hasScheduleError = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.viewModel.editingTask;
    if (existing != null) {
      nameController.text = existing.name;
      selectedUnit = existing.frequency.unit;
      selectedDays = List.of(existing.frequency.days ?? []);
      timeController.text = existing.frequency.time?.toString() ?? "";
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.viewModel.editingTask != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              subtitleInterface(isEditing ? "Edit task" : "New task"),
              const SizedBox(height: 12),
              nameField(),
              if (_hasNameError) errorMessage("Task name is needed"),
              const SizedBox(height: 16),
              amountFields(),
              if (_hasValueError)
                errorMessage(
                    "Value needs to be set and valid with a number without decimals"),
              if (_hasUnitError) errorMessage("Unit needs to be selected"),
              const SizedBox(height: 16),
              if (_hasScheduleError) errorMessage("Days need to be selected"),
              scheduleFields(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: message("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _onConfirm,
                    child: message(isEditing ? "Save" : "Add"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== Sous-méthodes ====================================
  TextFormField nameField() {
    return TextFormField(
      controller: nameController,
      decoration: labelInput("Task name"),
      style: GoogleFonts.poppins(fontSize: 12),
    );
  }

  Widget amountFields() {
    return Row(
      children: [
        message("Amount per day: "),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: TextFormField(
            controller: timeController,
            keyboardType: TextInputType.number,
            decoration: labelInput("Value"),
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<Unit>(
            initialValue: selectedUnit,
            decoration: labelInput("Unit"),
            isExpanded: true,
            items: Unit.values
                .map((u) => DropdownMenuItem(
                      value: u,
                      child: message(capitalize(u.name)),
                    ))
                .toList(),
            onChanged: (val) => setState(() => selectedUnit = val),
          ),
        ),
      ],
    );
  }

  Widget scheduleFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: Day.values.map((day) {
            final isSelected = selectedDays.contains(day);
            return FilterChip(
              label: message(capitalize(day.name)),
              selected: isSelected,
              selectedColor: Colors.black,
              showCheckmark: false,
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedDays.add(day);
                  } else {
                    selectedDays.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onConfirm() {
    setState(() {
      _hasNameError = nameController.text.trim().isEmpty;
      _hasUnitError = selectedUnit == null;
      _hasValueError = timeController.text.trim().isEmpty ||
          int.tryParse(timeController.text) == null;
      _hasScheduleError = selectedDays.isEmpty;
    });

    if ((_hasNameError ||
            _hasUnitError ||
            _hasValueError ||
            _hasScheduleError) ==
        true) {
      return;
    }

    final frequency = Frequency(
      unit: selectedUnit,
      time: int.tryParse(timeController.text),
      days: selectedDays,
    );

    if (widget.viewModel.editingTask != null) {
      widget.viewModel.updateTask(nameController.text.trim(), frequency);
    } else {
      widget.viewModel.addTask(nameController.text.trim(), frequency);
    }

    Navigator.of(context).pop();
  }
}
