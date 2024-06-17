import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

class Plans extends ConsumerStatefulWidget {
  const Plans({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlansState();
}

class _PlansState extends ConsumerState<Plans> {
  DateTime dateNow = DateTime.now();

  int getDaysInMonth(int month, int year) {
    return month == 2
        ? (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))
            ? 29
            : 28
        : (month == 4 || month == 6 || month == 9 || month == 11)
            ? 30
            : 31;
  }

  String getMonthYearString(DateTime date) {
    return DateFormat('MMMM yyyy', 'pl').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plany Treningowe - ${getMonthYearString(dateNow)}',
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            tooltip: 'Kalendarz',
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: GridView.builder(
        itemCount: getDaysInMonth(dateNow.month, dateNow.year),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemBuilder: (context, index) {
          final day = index + 1;
          return InkWell(
            onTap: () {
              GoRouter.of(context)
                  .go('/plans/day/${dateNow.year}/${dateNow.month}/$day');
            },
            child: Card(
              child: Center(
                child: Text('Dzień $day'),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateNow,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateNow) {
      setState(() {
        dateNow = picked;
        ref.read(selectedDateProvider.notifier).state = picked;
      });
    }
  }
}
