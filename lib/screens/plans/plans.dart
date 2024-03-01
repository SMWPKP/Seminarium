import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/plans_provider.dart';
import 'package:seminarium/screens/plans/plans_day.dart';

class Plans extends ConsumerStatefulWidget {
  const Plans({super.key, required this.label, required this.detailsPath});

  final String label;
  final String detailsPath;

  @override
  _PlansState createState() => _PlansState();

  static of(BuildContext context) {}
}

final plansProvider = StateNotifierProvider<PlansProvider, PlansState>((ref) => PlansProvider(PlansState(), ref));

class _PlansState extends ConsumerState<Plans> {
  final dateNow = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final plansData = ref.watch(plansProvider);
    final notes = ref.watch(plansProvider.notifier).notes;
    int howManyDays = 0;

    if ([1, 3, 5, 7, 8, 10, 12].contains(dateNow.month)) {
      howManyDays = 31;
    } else if ([4, 6, 9, 11].contains(dateNow.month)) {
      howManyDays = 30;
    } else if (dateNow.month == 2) {
      howManyDays = 28;
    }

    List<Widget> dateWidget = [];
    for (int i = 1; i <= howManyDays; i++) {
      final exercises = plansData.exercises[i] ?? [];      final noteExists = notes[i] != null && notes[i]!.isNotEmpty;
      final dayContent = exercises.isNotEmpty ? 'Ćwiczenia: ${exercises.length}, ${noteExists ? 'dodano notatkę' : ''}' : '';
      dateWidget.add(Card(
          child: ListTile(
        title: Text("Dzień $i"),
        subtitle: Text(dayContent),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder:
          (BuildContext context){
            return PlansDay(day: i, exercises: exercises, dayContent: plansData.dayContents[i] ?? '', description: plansData.descriptions[i] ?? '');
          }));
        },
      )));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalendarz"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: dateWidget,
      ),
    );
  }
}
