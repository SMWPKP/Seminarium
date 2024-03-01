import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/plans_provider.dart' as plansProviderAlias;
import 'package:seminarium/screens/plans/plans_day.dart';

final showAllProvider = StateProvider<bool>((ref) => false);


class AddExerciseScreen extends ConsumerWidget {
  final Exercise exercise;

  const AddExerciseScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _descriptionController =
        TextEditingController(text: exercise.description);

    final exercisesNotifier =
        ref.read(plansProviderAlias.exercisesProvider.notifier);

        final showAll = ref.watch(showAllProvider);

    final _exercisesList = [
      'Przysiady ze sztangą (Squats)',
      'Martwy ciąg (Deadlift)',
      'Wyciskanie sztangi leżąc (Bench Press)',
      'Podciąganie na drążku (Pull-Ups)',
      'Wiosłowanie sztangą w opadzie (Bent-Over Barbell Row)',
      'Wyciskanie hantli leżąc (Dumbbell Bench Press)',
      'Wiosłowanie hantlą w opadzie (Dumbbell Bent-Over Row)',
      'Wyciskanie sztangi nad głowę (Overhead Press)',
      'Podciąganie sztangi w opadzie (Barbell Pulldown)',
      'Przyciąganie sztangi do klatki (Barbell Row)',
      'Uginanie nóg w leżeniu (Leg Curl)',
      'Prostowanie nóg w siadzie (Leg Extension)',
      'Wypychanie hantli na suficie (Triceps Pushdown)',
      'Uginanie przedramion ze sztangą (Barbell Curl)',
      'Uginanie przedramion z hantlą (Dumbbell Curl)',
      'Rozpiętki hantlami leżąc (Dumbbell Flyes)',
      'Wznosy hantli bokiem w opadzie (Dumbbell Lateral Raise)',
      'Skłony tułowia w opadzie ze sztangą (Barbell Good Morning)',
      'Hip Thrust',
      'Mountain Climbers'
    ];

    _exercisesList.sort((a, b) => a.compareTo(b));

    // Funkcja do tworzenia pojedynczego chipa
    Widget _buildExercisesChip(String exercise) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChoiceChip(
          selected: ref
              .watch(plansProviderAlias.selectedExercises)
              .contains(Exercise.fromJson({'name': exercise})),
          onSelected: (selected) {
            if (selected) {
              exercisesNotifier
                  .addExercise(Exercise.fromJson({'name': exercise}));
            } else {
              final index = ref
                  .read(plansProviderAlias.selectedExercises)
                  .indexWhere((e) => e.name == exercise);
              exercisesNotifier.removeExercise(index);
            }
          },
          label: Text(exercise),
          labelStyle: TextStyle(color: Colors.black),
        ),
      );
    }

    List<Widget> _buildExercisesChips() {
  final chips = _exercisesList
      .map((exercise) => _buildExercisesChip(exercise))
      .toList();
  if (showAll) {
    return chips
      ..add(
        TextButton(
          child: Text('Pokaż mniej'),
          onPressed: () {
            ref.read(showAllProvider.notifier).state = false;
          },
        ),
      );
  } else {
    return chips.take(5).toList()
      ..add(
        TextButton(
          child: Text('Pokaż więcej'),
          onPressed: () {
            ref.read(showAllProvider.notifier).state = true;
          },
        ),
      );
  }
}

    return Scaffold(
      appBar: AppBar(
        title: Text('Edytuj ćwiczenie'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Wyświetlanie chipów ćwiczeń
            Wrap(
              children: _buildExercisesChips(),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Opis'),
            ),
            ElevatedButton(
              onPressed: () {
                final newExercise = Exercise(
                  name: _descriptionController.text,
                  description: _descriptionController.text,
                );

                exercisesNotifier.addExercise(newExercise);

                // Opcjonalnie: przejdź do ekranu głównego
                Navigator.pop(context);
              },
              child: Text('Zapisz'),
            ),
          ],
        ),
      ),
    );
  }
}
