import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seminarium/providers/plans_provider.dart';
import 'package:seminarium/features/plans/plans_day.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({ Key? key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Future<void> _checkTodayPlanFuture;

  @override
  void initState() {
    super.initState();
    _checkTodayPlanFuture = _checkTodayPlan();
  }

  Future<void> _checkTodayPlan() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final today = DateTime.now();
    if (userId != null) {
      await ref.read(plansProvider.notifier).loadPlanForDay(userId, today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final plansData = ref.watch(plansProvider);
    final dateKey = DateFormat('ddMMyyyy').format(today);
    final exercises = plansData.exercises[dateKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: FutureBuilder(
        future: _checkTodayPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (exercises.isNotEmpty) {
            return Center(
              child: ElevatedButton(
                child: const Text('Przejdź do dzisiejszego planu'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlansDay(initialDate: today),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Brak zaplanowanych ćwiczeń na dziś :)',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            );
          }
        },
      ),
    );
  }
}
