import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goal_garden/presentation/view/home/home_viewmodel.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => HomeViewModel(),
        builder: (context, viewModel, child) => Scaffold(
              body: GridView.count(
                crossAxisCount: 2,
                children: List.generate(20, (index) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    color: Colors.blue,
                    child: Center(child: Text('Item $index')),
                  );
                }),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => {HomeViewModel},
                child: const Icon(Icons.add),
              ),
            ));
  }
}

      /* appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Goal Garden"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.message,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          )
        ],
      ),
      body: const Center(child: Text('Test')),*/