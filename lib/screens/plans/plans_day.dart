import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/plans_provider.dart' as plansProviderAlias;
import 'package:seminarium/screens/plans/add_exercise_screen.dart';
import 'package:seminarium/screens/plans/edit_exercise_screen.dart';
import 'package:seminarium/screens/plans/plans.dart';

class Exercise {
  final String name;
  final String description;

  Exercise({required this.name, required this.description});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  static Exercise fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class PlansDay extends ConsumerStatefulWidget {
  const PlansDay(
      {super.key,
      required this.day,
      required this.exercises,
      required this.dayContent,
      required this.description});

  final int day;
  final List<Exercise> exercises;
  final String dayContent;
  final String description;

  @override
  _PlansDayState createState() => _PlansDayState();
}

class _PlansDayState extends ConsumerState<PlansDay> {
  final _textController = TextEditingController(text: '');
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    ref.read(plansProviderAlias.exercisesProvider.notifier).loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    final selectedExercises = ref.watch(plansProviderAlias.selectedExercises);
    final plansData = ref.watch(plansProviderAlias.plansProvider);
    final dayContent = plansData.dayContents[widget.day] ?? '';
    final description = plansData.descriptions[widget.day] ?? '';
    final exercises = plansData.exercises[widget.day] ?? [];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Dzień ${widget.day}"),
      ),
      body: exercises.isEmpty
          ? Center(
              child: ElevatedButton(
                child: const Text('Dodaj ćwiczenie'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddExerciseScreen(
                            exercise: Exercise(name: '', description: ''))),
                  );
                },
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(widget.description),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            ref
                                .read(plansProviderAlias
                                    .exercisesProvider.notifier)
                                .removeExercise(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('${exercise.name} usunięto')),
                            );
                          },
                          child: ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(exercise.description),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditExerciseScreen(exerciseIndex: index),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Treść dnia',
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('Zapisz'),
                    onPressed: () async {
                      await saveDayContent(_textController.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return Plans(
                              label: 'B',
                              detailsPath:
                                  '/b/details ${widget.dayContent}${_textController.text}${widget.day}');
                        }),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('Dodaj ćwiczenie'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddExerciseScreen(
                                exercise: Exercise(name: '', description: ''))),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> saveDayContent(String dayContent) async {
    final month = DateTime.now().month; // Pobierz aktualny miesiąc

    // Zapisz dane dnia w dokumencie dla danego miesiąca
    await _firestore.collection('months').doc(month.toString()).set(
        {
          'days': {
            widget.day.toString(): {
              'content': dayContent,
              'description': widget.description,
              'note': _textController.text,
              'exercises': widget.exercises
                  .map((exercise) => {
                        'name': exercise.name,
                        'description': exercise.description,
                      })
                  .toList(),
            },
          },
        },
        SetOptions(
            merge:
                true)); // Użyj SetOptions(merge: true), aby zaktualizować tylko dane dla danego dnia, a nie całego dokumentu
  }
}
