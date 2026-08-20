import 'package:flutter/material.dart';
import 'package:selfsight/presentation/view/goal/task/task_viewmodel.dart';

class TaskWidget extends StatelessWidget {
  final TaskViewModel viewModel;

  const TaskWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => showForm(context, formKey),
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
              ),
            ),
            tasksList(),
          ],
        );
      },
    );
  }

  // =========================== SOUS-MÉTHODES ============================================================================
  // Formulaire d'ajout d'une tâche
  void showForm(BuildContext context, GlobalKey<FormState> key) {
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              content: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Form(
                    key: key,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        submitCancelButtons(context, key),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }

  Padding submitCancelButtons(BuildContext context, GlobalKey<FormState> key) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ElevatedButton(
          child: const Text('Submit'),
          onPressed: () {
            if (key.currentState!.validate()) {
              key.currentState!.save();
            }
          },
        ),
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ]),
    );
  }

// -----------------------------------------------------------------------------------------------------
  // Liste des tâches ajoutés
  Expanded tasksList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 1, //viewModel.tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("TEST"), //Text(viewModel.tasks[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                //  viewModel.removeTask(index);
              },
            ),
          );
        },
      ),
    );
  }
}
