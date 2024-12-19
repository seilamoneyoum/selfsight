import 'package:flutter/material.dart';
import 'package:goal_garden/presentation/view/main_goal/main_goal_view.dart';
import 'package:goal_garden/presentation/view/main_goal/main_goal_viewmodel.dart';
import 'package:stacked/stacked.dart';

class MainGoalView extends StatefulWidget {
  const MainGoalView({super.key});

  @override
  State<MainGoalView> createState() => _MainGoalViewState();
}

class _MainGoalViewState extends State<MainGoalView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => MainGoalViewModel(),
        builder: (context, viewModel, child) => Scaffold(
              body: GridView.count(
                crossAxisCount: 2,
                children: List.generate(2, (index) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    color: Colors.blue,
                    child: Center(child: Text('Item $index')),
                  );
                }),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => {},
                child: const Icon(Icons.add),
              ),
            ));
  }
}
