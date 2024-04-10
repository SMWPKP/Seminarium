import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/plans_provider.dart';
import 'package:seminarium/screens/plans/wolt_add_exercise_screen.dart';

class PlansDay extends ConsumerStatefulWidget {
  const PlansDay({Key? key, required this.day}) : super(key: key);

  final int day;

  @override
  _PlansDayState createState() => _PlansDayState();
}

class _PlansDayState extends ConsumerState<PlansDay> {
  @override
  Widget build(BuildContext context) {
    final plansData = ref.watch(plansProvider);
    final exercises = plansData.exercises[widget.day] ?? [];
    final description = plansData.descriptions[widget.day] ?? '';
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
                  if (userId != null) {
                    WoltAddExercise.show(context, ref, userId, widget.day);
                  } else {
                    // Wyświetl komunikat o błędzie lub zaloguj użytkownika
                  }
                },
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(description),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return ListTile(
                          title: Text(exercise),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Dodaj ćwiczenie'),
                    onPressed: () {
                      if (userId != null) {
                        WoltAddExercise.show(context, ref, userId, widget.day);
                      } else {
                        // Wyświetl komunikat o błędzie lub zaloguj użytkownika
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
