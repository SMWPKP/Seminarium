import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/plans_provider.dart';
import 'package:seminarium/screens/plans/plans_models.dart';
import 'package:seminarium/widgets/bottom_sheet_plans.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

final showAllProvider = StateProvider<bool>((ref) => false);
final pageIndexProvider =
    ChangeNotifierProvider<ValueNotifier<int>>((ref) => ValueNotifier<int>(0));
final editingExerciseProvider = StateProvider<bool>((ref) => false);
final exerciseDescriptionProvider = StateProvider<String>((ref) => '');
final selectedExercisesByType =
    StateProvider<Map<String, List<Exercise>>>((ref) => {});
final selectedExerciseType = StateProvider<String>((ref) => '');
final selectedExerciseProvider =
    StateNotifierProvider<ExerciseNotifier, String>(
        (ref) => ExerciseNotifier());

class ExerciseNotifier extends StateNotifier<String> {
  ExerciseNotifier() : super('');

  String? selectedExercise;

  void selectExercise(String exercise) {
    selectedExercise = exercise;
    state = exercise;
  }

  bool isSelected(String exercise) {
    return selectedExercise == exercise;
  }
}

final exerciseTypeProvider =
    StateNotifierProvider<ExerciseTypeNotifier, String>(
        (ref) => ExerciseTypeNotifier());

class ExerciseTypeNotifier extends StateNotifier<String> {
  ExerciseTypeNotifier() : super('');

  String? selectedExerciseType;

  void selectExerciseType(String exerciseType) {
    if (selectedExerciseType == exerciseType) {
      // Jeśli użytkownik kliknie na już zaznaczoną kartę, odznaczamy ją.
      selectedExerciseType = null;
    } else {
      // W przeciwnym razie zaznaczamy wybraną kartę i odznaczamy wszystkie inne.
      selectedExerciseType = exerciseType;
    }
    state = selectedExerciseType ?? '';
  }
}

final exerciseDescriptionController = TextEditingController();

final selectedExercisesWithCustomName =
    StateProvider<Map<String, String>>((ref) => {
          // Dodaj ćwiczenia z tabeli 2 do mapy
          'Własne ćwiczenia': ''
        });

final customNameProvider = StateNotifierProvider<CustomNameNotifier, String>(
    (ref) => CustomNameNotifier());

class CustomNameNotifier extends StateNotifier<String> {
  CustomNameNotifier() : super('');

  void update(String newName) {
    state = newName;
  }
}

final selectedProvider = StateProvider<String>((ref) => '');

class WoltAddExercise extends ConsumerWidget {
  const WoltAddExercise({Key? key}) : super(key: key);

  static void show(
      BuildContext context, WidgetRef ref, String userId, int day) {
    const double _pageBreakpoint = 768.0;
    

    Widget _buildExerciseTypeCard(String exerciseType,
        {String? customName, List<String>? exerciseList}) {
      return Consumer(
        builder: (context, watch, child) {
          final selectedExerciseType =
              ref.watch(selectedProvider.notifier).state;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                ref.read(selectedProvider.notifier).state = exerciseType;
                ref
                    .read(selectedExerciseProvider.notifier)
                    .selectExercise(exerciseType);
              },
              child: Card(
                key: ValueKey(exerciseType),
                color:
                    selectedExerciseType == exerciseType ? Colors.green : null,
                child: ListTile(
                  title: Text(customName != null ? customName : exerciseType),
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () async {
                      if (customName != null) {
                        ref.read(customNameProvider.notifier).state =
                            customName;
                        ref
                            .read(selectedExercisesWithCustomName.notifier)
                            .state[exerciseType] = customName;
                      }
                      ref
                          .read(selectedExercisesByType.notifier)
                          .state[exerciseType]
                          ?.clear();
                      final exercises = await ref
                          .read(plansProvider.notifier)
                          .showExercisesForList(userId, [exerciseType],
                              customName ?? exerciseType);
                      ref
                          .read(selectedExercisesByType.notifier)
                          .state[exerciseType] = exercises;
                      MyBottomSheet(
                              exercises: ref
                                      .read(selectedExercisesByType.notifier)
                                      .state[exerciseType] ??
                                  [])
                          .show(context);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    //code for page 1 (user can select exercises)
    SliverWoltModalSheetPage page1(
        BuildContext modalSheetContext, TextTheme textTheme) {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      return SliverWoltModalSheetPage(
        mainContentSlivers: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('Exercises').doc('Types').snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(child: Text('Wystąpił błąd'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                    child: CircularProgressIndicator());
              }
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<String> exerciseTypes = data.keys.toList();
              exerciseTypes.add('Własne ćwiczenia');
              return SliverFillRemaining(
                  child: CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            childAspectRatio: 1),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) {
                        if (exerciseTypes[index] == 'Własne ćwiczenia') {
                          return InkWell(
                            onTap: () {
                              ref.read(pageIndexProvider).value = 3;
                            },
                            child: Card(
                              color: Colors.blue,
                              child: ListTile(
                                title: const Text('Własne ćwiczenia'),
                              ),
                            ),
                          );
                        } else {
                          return _buildExerciseTypeCard(exerciseTypes[index]);
                        }
                      },
                      childCount: exerciseTypes.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ElevatedButton(
                      onPressed: () {
                        final pageIndex = ref.read(pageIndexProvider).value;
                        if (pageIndex < 1) {
                          ref.read(pageIndexProvider).value = pageIndex + 1;
                        }
                      },
                      child: const Text('Dalej'),
                    ),
                  )
                ],
              ));
            },
          ),
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

    //code for custom list of exercises
    SliverWoltModalSheetPage pageCustom(
        BuildContext modalSheetContext, TextTheme textTheme) {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      return SliverWoltModalSheetPage(
        mainContentSlivers: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(userId)
                .collection('savedExercises')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(child: Text('Wystąpił błąd'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                    child: CircularProgressIndicator());
              }
              List<QueryDocumentSnapshot> exercises = snapshot.data!.docs;
              return SliverFillRemaining(
                  child: CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            childAspectRatio: 1),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) {
                        // Pobieramy dane z dokumentu
                        Map<String, dynamic> data =
                            exercises[index].data() as Map<String, dynamic>;
                        // Pobieramy listę ćwiczeń z danych
                        List<String> exerciseList =
                            List<String>.from(data.values.first);
                        //Pobieramy customName z danych
                        String customName = data['customName'];
                        // Budujemy kartę z losowym ćwiczeniem
                        return _buildExerciseTypeCard(
                          customName,
                          customName: customName,
                          exerciseList: exerciseList,
                        );
                      },
                      childCount: exercises.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ElevatedButton(
                      onPressed: () {
                        final pageIndex = ref.read(pageIndexProvider).value;
                        if (pageIndex > 1) {
                          ref.read(pageIndexProvider).value = 1;
                        }
                      },
                      child: const Text('Dalej'),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          onPressed: () {
                            final pageIndex = ref.read(pageIndexProvider).value;
                            if (pageIndex > 0) {
                              ref.read(pageIndexProvider).value = 0;
                            }
                          },
                          child: const Text('Wstecz'),
                        ),
                      )),
                ],
              ));
            },
          ),
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
                final selectedExercise =
                    ref.watch(selectedExerciseProvider.notifier).state;
                final exerciseDescription =
                    ref.watch(exerciseDescriptionProvider.notifier).state;
                return Column(
                  children: [
                    _buildExerciseTypeCard(
                      selectedExercise,
                      customName: ref
                          .read(selectedExercisesWithCustomName.notifier)
                          .state[selectedExercise],
                    ),
                    SizedBox(height: 16),
                    if (exerciseDescription != null &&
                        exerciseDescription.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          exerciseDescription,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
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
                    final description =
                        ref.read(exerciseDescriptionProvider.notifier).state;
                    await ref.read(plansProvider.notifier).savePlan(
                        userId,
                        day,
                        description,
                        ref
                            .read(selectedExerciseTypesProvider.notifier)
                            .state
                            .toList());
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
          pageCustom(modalSheetContext, textTheme)
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
        Navigator.of(context).pop();
        ref.read(pageIndexProvider).value = 0;
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
