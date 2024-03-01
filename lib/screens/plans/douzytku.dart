import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Douzytku extends ConsumerStatefulWidget {
  @override
  _DouzytkuState createState() => _DouzytkuState();
}

class _DouzytkuState extends ConsumerState<Douzytku> {
  List<String> _exercisesList = [
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

  // Zmienna stanu dla śledzenia wybranych marek
  List<String> _selectedExercises = [];

  List<Widget> _buildExercisesChips() {
    return _exercisesList
        .map((Exercises) => _buildExercisesChip(Exercises))
        .toList();
  }

  Widget _buildExercisesChip(String Exercises) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChoiceChip(
        selected: _selectedExercises.contains(Exercises),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedExercises.add(Exercises);
            } else {
              _selectedExercises.remove(Exercises);
            }
          });
        },
        label: Text(Exercises),
        labelStyle: TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj ćwiczenie do planu treningowego'),
      ),
      body: Wrap(
        children: _buildExercisesChips(),
      ),
    );
  }
}
