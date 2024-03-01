import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/plans_provider.dart';
import 'package:seminarium/screens/plans/plans_day.dart';

class EditExerciseScreen extends ConsumerStatefulWidget {
  final int exerciseIndex;

  EditExerciseScreen({required this.exerciseIndex});

  @override
  _EditExerciseScreenState createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends ConsumerState<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;

  @override
  void initState() {
    super.initState();
    final exercise = ref.read(exercisesProvider)[widget.exerciseIndex];
    _name = exercise.name;
    _description = exercise.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edytuj ćwiczenie'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nazwa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić nazwę';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Opis'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić opis';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              ElevatedButton(
                child: Text('Zapisz'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Aktualizuj ćwiczenie
                    final updatedExercise =
                        Exercise(name: _name, description: _description);
                    ref
                        .read(exercisesProvider.notifier)
                        .updateExercise(widget.exerciseIndex, updatedExercise);

                    await ref.read(exercisesProvider.notifier).saveExercises();

                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
