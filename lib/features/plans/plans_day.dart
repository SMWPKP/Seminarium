import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seminarium/providers/plans_provider.dart';
import 'package:seminarium/features/plans/wolt_add_exercise_screen.dart';
import 'package:intl/intl.dart';

class PlansDay extends ConsumerStatefulWidget {
  const PlansDay({Key? key, required this.initialDate}) : super(key: key);

  final DateTime initialDate;

  @override
  _PlansDayState createState() => _PlansDayState();
}

class _PlansDayState extends ConsumerState<PlansDay> {
  late DateTime selectedDate;
  late Map<String, bool> exerciseCompletionStatus;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    exerciseCompletionStatus = {};
    _loadPlan();
    _loadCompletionStatus();
  }

  Future<void> _loadPlan() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await ref
          .read(plansProvider.notifier)
          .loadPlanForDay(userId, selectedDate);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _loadPlan();
      await _loadCompletionStatus();
    }
  }

  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = DateFormat('ddMMyyyy').format(selectedDate);
    final completionStatus = prefs.getStringList(dateKey) ?? [];

    setState(() {
      exerciseCompletionStatus = {
        for (var exercise in completionStatus) exercise: true
      };
    });
  }

  Future<void> _toggleCompletionStatus(String exercise) async {
    setState(() {
      exerciseCompletionStatus[exercise] =
          !(exerciseCompletionStatus[exercise] ?? false);
    });

    final prefs = await SharedPreferences.getInstance();
    final dateKey = DateFormat('ddMMyyyy').format(selectedDate);
    final completionStatus = exerciseCompletionStatus.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    await prefs.setStringList(dateKey, completionStatus);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(plansProvider, (_, __) {
      setState(() {});
    });

    final plansData = ref.watch(plansProvider);
    final dateKey = DateFormat('ddMMyyyy').format(selectedDate);
    final exercises = plansData.exercises[dateKey] ?? [];
    final description = plansData.descriptions[dateKey] ?? '';
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dzień ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (exercises.isNotEmpty) ...[
              ExpansionTile(
                title: Text("Pakiet ćwiczeń"),
                children: exercises.map((exercise) {
                  final isCompleted =
                      exerciseCompletionStatus[exercise] ?? false;
                  return CheckboxListTile(
                    title: Text(exercise),
                    value: isCompleted,
                    onChanged: (bool? value) {
                      _toggleCompletionStatus(exercise);
                    },
                  );
                }).toList(),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Opis:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(description),
                    ],
                  ),
                ),
              ElevatedButton(
                child: Text('Edytuj ćwiczenia'),
                onPressed: () {
                  if (userId != null) {
                    WoltAddExercise.show(context, ref, userId, selectedDate);
                  } else {
                    throw Exception(
                        'Nie można edytować ćwiczeń, użytkownik nie jest zalogowany');
                  }
                },
              ),
            ] else
              Center(
                child: ElevatedButton(
                  child: const Text('Dodaj ćwiczenie'),
                  onPressed: () {
                    if (userId != null) {
                      WoltAddExercise.show(context, ref, userId, selectedDate);
                    } else {
                      throw Exception(
                          'Nie można dodać ćwiczeń, użytkownik nie jest zalogowany');
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
