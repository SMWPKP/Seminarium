import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/plans_provider.dart';
import 'package:seminarium/model/plans_models.dart';
import 'package:seminarium/features/plans/wolt_add_exercise_screen.dart';

final bottomSheetData = StateProvider<Map<String, dynamic>>((ref) => {});

class MyBottomSheet extends ConsumerStatefulWidget {
  final List<Exercise> exercises;
  

  MyBottomSheet({required this.exercises});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();

  void show(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return MyBottomSheet(exercises: [...exercises]); // Tworzymy nową instancję MyBottomSheet z kopią listy ćwiczeń
    },
  );
}
}

class _MyBottomSheetState extends ConsumerState<MyBottomSheet> {
  List<Exercise> exercises = [];
  Exercise? lastRemovedExercise;

  @override
  void initState() {
    super.initState();
    exercises = widget.exercises;
  }

  Future<void> _addExercise() async {
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Podaj nazwę ćwiczenia'),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  exercises.add(Exercise(name: controller.text));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveExercise(String customName, bool saveForLater) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Wyświetl komunikat o błędzie
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: nie jesteś zalogowany')),
      );
      return;
    }
    List<String> exerciseList = exercises.map((e) => e.name).toList();

    if (saveForLater) {
      ref
          .read(plansProvider.notifier)
          .saveEditedExerciseList(uid, customName, exerciseList);
    }
    ref.read(pageIndexProvider).value=1;
  }

  Future<void> _getCustomName() async {
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Podaj nazwę dla listy ćwiczeń'),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                await _saveExercise(controller.text, true);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (exercises.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edycja ćwiczeń'),
        ),
        body: ListView.builder(
          itemCount: exercises.length + 2,
          itemBuilder: (context, index) {
            if (index == exercises.length) {
              return ListTile(
                title: Text('Dodaj ćwiczenie'),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addExercise,
                ),
              );
            } else if (index == exercises.length + 1) {
              return ListTile(
                title: Text('Zapisz edycje'),
                trailing: IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    ref.read(bottomSheetData.notifier).state = {
                      'exercises': exercises.map((e) => e.name).toList(),
                    };
                    await _getCustomName();
                    Navigator.of(context).pop();
                  },
                ),
              );
            } else {
              return ListTile(
                title: Text(exercises.elementAt(index).name),
                trailing: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      lastRemovedExercise = exercises.removeAt(index);
                    });
                  },
                ),
              );
            }
          },
        ),
        floatingActionButton: lastRemovedExercise != null
            ? FloatingActionButton(
                child: Icon(Icons.undo),
                onPressed: () {
                  setState(() {
                    exercises.add(lastRemovedExercise!);
                    lastRemovedExercise = null;
                  });
                },
              )
            : null,
      );
    } else {
      return Container(child: Text('Brak ćwiczeń'));
    }
  }
}
