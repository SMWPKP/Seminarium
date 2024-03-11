import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/plans_provider.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

final showAllProvider = StateProvider<bool>((ref) => false);
final pageIndexProvider =
    ChangeNotifierProvider<ValueNotifier<int>>((ref) => ValueNotifier<int>(0));
final editingExerciseProvider = StateProvider<bool>((ref) => false);
final selectedExercisesProvider = StateProvider<Set<String>>((ref) => {});
final exerciseDescriptionProvider = StateProvider<String>((ref) => '');

final exerciseDescriptionController = TextEditingController();

class WoltAddExercise extends ConsumerWidget {
  const WoltAddExercise({Key? key}) : super(key: key);

  static void show(BuildContext context, WidgetRef ref, String userId, int day) {
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

    final showAll = ref.watch(showAllProvider);

    Widget _buildExercisesChip(String exerciseName) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer(
          builder: (context, ref, child) {
            final isSelected =
                ref.watch(selectedExercisesProvider).contains(exerciseName);
            return ChoiceChip(
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedExercisesProvider.notifier).state = {
                    ...ref.read(selectedExercisesProvider.notifier).state,
                    exerciseName
                  };
                } else {
                  ref.read(selectedExercisesProvider.notifier).state = {
                    ...ref.read(selectedExercisesProvider.notifier).state
                      ..remove(exerciseName)
                  };
                }
              },
              label: Text(exerciseName),
              labelStyle: const TextStyle(color: Colors.black),
            );
          },
        ),
      );
    }

    List<Widget> _buildExercisesChips() {
      final chips = _exercisesList
          .map((exercise) => _buildExercisesChip(exercise))
          .toList();
      chips.add(
        ChoiceChip(
          label: const Text('Dodaj nowe ćwiczenie'),
          selected: ref.watch(editingExerciseProvider.notifier).state,
          onSelected: (selected) {
            ref.read(editingExerciseProvider.notifier).state = selected;
          },
          selectedColor: Colors.lightGreen,
        ),
      );
      //currently not used
      if (showAll) {
        return chips
          ..add(
            TextButton(
              child: const Text('Pokaż mniej'),
              onPressed: () {
                ref.read(showAllProvider.notifier).state = false;
              },
            ),
          );
      } else {
        return chips.take(5).toList()
          ..add(
            TextButton(
              child: const Text('Pokaż więcej'),
              onPressed: () {
                ref.read(showAllProvider.notifier).state = true;
              },
            ),
          );
      }
    }

    //code for page 1 (user can select exercises)
    SliverWoltModalSheetPage page1(
        BuildContext modalSheetContext, TextTheme textTheme) {
      return SliverWoltModalSheetPage(
        mainContentSlivers: [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                childAspectRatio: 3),
            delegate: SliverChildBuilderDelegate(
                (_, index) => _buildExercisesChip(_exercisesList[index]),
                childCount: _exercisesList.length),
          ),
          SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () {
                    final pageIndex = ref.read(pageIndexProvider).value;
                    if (pageIndex < 1) {
                      ref.read(pageIndexProvider).value = pageIndex + 1;
                    }
                  },
                  child: const Text('Dalej'),
                ),
              )),
        ],
        hasSabGradient: false,
        topBarTitle: Text('Dodaj ćwiczenie', style: textTheme.titleLarge),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          padding: const EdgeInsets.all(16),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(modalSheetContext).pop(),
        ),
      );
    }

    //code for page 2 (user can create a description of exercises)
    SliverWoltModalSheetPage page2(
        BuildContext modalSheetContext, TextTheme textTheme) {
      return SliverWoltModalSheetPage(
        mainContentSlivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: exerciseDescriptionController,
                minLines: 6,
                maxLines: null,
                maxLength: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Opis ćwiczeń',
                ),
                onChanged: (value) {
                  ref.read(exerciseDescriptionProvider.notifier).state = value;
                },
              ),
            ),
          ),
          SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () {
                    final pageIndex = ref.read(pageIndexProvider).value;
                    if (pageIndex < 2) {
                      ref.read(pageIndexProvider).value = pageIndex + 1;
                    }
                  },
                  child: const Text('Dalej'),
                ),
              )),
          SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () {
                    final pageIndex = ref.read(pageIndexProvider).value;
                    if (pageIndex > 0) {
                      ref.read(pageIndexProvider).value = pageIndex - 1;
                    }
                    ref.read(pageIndexProvider).value = 0;
                  },
                  child: const Text('Wstecz'),
                ),
              )),
        ],
        hasSabGradient: false,
        topBarTitle: Text('Dodaj opis do ćwiczeń', style: textTheme.titleLarge),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          padding: const EdgeInsets.all(16),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(modalSheetContext).pop(),
        ),
      );
    }

    //code for page 3 (all selected chips and description of exercises)
    SliverWoltModalSheetPage page3(
        BuildContext modalSheetContext, TextTheme textTheme) {
      return SliverWoltModalSheetPage(
        mainContentSlivers: [
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final selectedExercises =
                    ref.watch(selectedExercisesProvider.notifier).state;
                final exerciseDescription =
                    ref.watch(exerciseDescriptionProvider.notifier).state;
                return Column(
                  children: [
                    ...selectedExercises
                        .map((exercise) => Chip(label: Text(exercise)))
                        .toList(),
                    SizedBox(height: 16),
                    if (exerciseDescription != null &&
                        exerciseDescription.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(exerciseDescription,
                            style: TextStyle(fontSize: 20)),
                      )
                  ],
                );
              },
            ),
          ),
          SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () async {
                    final description = ref.read(exerciseDescriptionProvider.notifier).state;
                    await ref.read(plansProvider.notifier).savePlan(userId, day, description);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Zapisz'),
                ),
              )),
          SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () {
                    final pageIndex = ref.read(pageIndexProvider).value;
                    if (pageIndex > 0) {
                      ref.read(pageIndexProvider).value = pageIndex - 1;
                    }
                  },
                  child: const Text('Wstecz'),
                ),
              )),
        ],
        hasSabGradient: false,
        topBarTitle: Text('Podsumowanie', style: textTheme.titleLarge),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          padding: const EdgeInsets.all(16),
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(modalSheetContext).pop(),
        ),
      );
    }

    WoltModalSheet.show(
      context: context,
      pageIndexNotifier: ref.watch(pageIndexProvider),
      pageListBuilder: (modalSheetContext) {
        final textTheme = Theme.of(context).textTheme;
        return [
          page1(modalSheetContext, textTheme),
          page2(modalSheetContext, textTheme),
          page3(modalSheetContext, textTheme),
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
        print('Closed modal sheet with barrier tap');
        Navigator.of(context).pop();
        ref.read(pageIndexProvider).value = 0;
        print('Reset pageIndex to ${ref.read(pageIndexProvider).value}');
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
