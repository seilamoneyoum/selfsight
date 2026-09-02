import 'package:flutter/material.dart';
import 'package:selfsight/presentation/view/home/home_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/domain/entities/goal/category.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (viewModel) => viewModel.loadGoals(),
      builder: (context, viewModel, child) => Scaffold(
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : viewModel.goals.isEmpty
                ? const Center(child: Text('No goals yet'))
                : GridView.count(
                    crossAxisCount: 2,
                    children: viewModel.goals.map((goal) {
                      return GestureDetector(
                        onTap: () => viewModel.navigateToSpecificGoal(goal.id),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 193, 173, 226),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                goal.category?.icon ?? Icons.category,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                goal.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                goal.progress.isAccomplished
                                    ? 'Completed'
                                    : 'In progress',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: goal.progress.isAccomplished
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await viewModel.navigateToMainGoalView();
            viewModel.loadGoals();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
