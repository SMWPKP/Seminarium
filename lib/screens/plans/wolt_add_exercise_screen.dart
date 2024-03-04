import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/screens/plans/plans_day.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:seminarium/providers/plans_provider.dart' as plansProviderAlias;

final showAllProvider = StateProvider<bool>((ref) => false);
final pageIndexProvider =
    ChangeNotifierProvider<ValueNotifier<int>>((ref) => ValueNotifier<int>(0));

class WoltAddExercise extends ConsumerWidget {
  const WoltAddExercise({Key? key}) : super(key: key);

  static void show(BuildContext context, WidgetRef ref) {
    const double _pageBreakpoint = 768.0;

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

    final pageIndex = ref.watch(pageIndexProvider).value;

    final exercisesNotifier =
        ref.read(plansProviderAlias.exercisesProvider.notifier);

    final showAll = ref.watch(showAllProvider);

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

    SliverWoltModalSheetPage page1(
        BuildContext modalSheetContext, TextTheme textTheme) {
      return WoltModalSheetPage(
          hasSabGradient: false,
          stickyActionBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              ElevatedButton(
                onPressed: () => Navigator.of(modalSheetContext).pop(),
                child: const SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: Center(child: Text('Anuluj')),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(pageIndexProvider).value = pageIndex + 1,
                child: const SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: Center(child: Text('Dalej')),
                ),
              ),
            ]),
          ),
          topBarTitle: Text('Dodaj ćwiczenie', style: textTheme.headline6),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(modalSheetContext).pop(),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 150),
              ),
              Wrap(
                children: _buildExercisesChips(),
              ),
            ],
          ));
    }

      WoltModalSheet.show(
        context: context,
        pageIndexNotifier: ref.watch(pageIndexProvider),
        pageListBuilder: (modalSheetContext) {
          final textTheme = Theme.of(context).textTheme;
          return [
            page1(modalSheetContext, textTheme),
          ];
        },
        modalTypeBuilder: (context) {
          final size = MediaQuery.of(context).size.width;
          if (size < _pageBreakpoint) {
            return WoltModalType.bottomSheet;
          } else {
            return WoltModalType.dialog;
          }
        },
        onModalDismissedWithBarrierTap: () {
          debugPrint('Closed modal sheet with barrier tap');
          ref.read(pageIndexProvider).value = 0;
          Navigator.of(context).pop();
                  },
        maxDialogWidth: 560,
        minDialogWidth: 400,
        minPageHeight: 0.0,
        maxPageHeight: 0.9,
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   return Container();
}
}
