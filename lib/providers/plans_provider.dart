import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/model/plans_models.dart';
import 'package:intl/intl.dart';

final plansProvider = StateNotifierProvider<PlansProvider, PlansState>(
    (ref) => PlansProvider(PlansState(), ref));
final selectedExercisesProvider = StateProvider<List<Exercise>>((ref) => []);
final selectedExerciseTypesProvider = StateProvider<Set<String>>((ref) => {});

class PlansProvider extends StateNotifier<PlansState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StateNotifierProviderRef<PlansProvider, PlansState> ref;

  PlansProvider(PlansState state, this.ref) : super(state);

  Future<List<Exercise>> showExercisesForList(
      String userId, List<String> exerciseList, String selectedList) async {
    List<Exercise> exercises = [];

    DocumentSnapshot doc =
        await _firestore.collection('Exercises').doc('Types').get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    exerciseList.forEach((exerciseType) {
      if (exerciseType == selectedList && data.containsKey(exerciseType)) {
        List<String> exerciseNames = List<String>.from(data[exerciseType]);
        exercises
            .addAll(exerciseNames.map((name) => Exercise(name: name)).toList());
      }
    });

    //Get users/uid/savedExercises
    QuerySnapshot userExercisesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedExercises')
        .get();

    userExercisesSnapshot.docs.forEach((doc) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      if (userData['customName'] == selectedList &&
          userData.containsKey('exercises')) {
        List<String> userExerciseNames =
            List<String>.from(userData['exercises']);
        exercises.addAll(
            userExerciseNames.map((name) => Exercise(name: name)).toList());
      }
    });

    ref.read(selectedExercisesProvider.notifier).state = exercises;

    return exercises;
  }

  Future<void> savePlan(String userId, DateTime date, String description,
      List<String> exercisesForTheDay) async {
    final dateFormat = DateFormat('ddMMyyyy');
    final dateString = dateFormat.format(date);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('days')
        .doc(dateString)
        .set({
      'date': dateString,
      'exercises': exercisesForTheDay,
      'description': description,
      'selectedExercises': ref
          .read(selectedExercisesProvider.notifier)
          .state
          .map((e) => e.name)
          .toList(),
    });
  }

  Future<void> loadPlanForDay(String userId, DateTime date) async {
    final dateFormat = DateFormat('ddMMyyyy');
    final dateString = dateFormat.format(date);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('days')
        .doc(dateString)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data()!;
      final exercises = List<String>.from(data['selectedExercises']);
      final description = data['description'];

      state = state.copyWith(
        exercises: {dateString: exercises},
        descriptions: {dateString: description},
      );
    } else {
      state = state.copyWith(
        exercises: {dateString: []},
        descriptions: {dateString: ''},
      );
    }
  }

  Future<void> saveEditedExerciseList(
      String userId, String customName, List<String> exercises) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedExercises')
        .add({
      'customName': customName,
      'exercises': exercises,
    });
  }
}

class PlansState {
  final Map<String, String> descriptions;
  final Map<String, List<String>> exercises;

  PlansState({
    this.descriptions = const {},
    this.exercises = const {},
  });

  PlansState copyWith({
    Map<String, String>? descriptions,
    Map<String, List<String>>? exercises,
  }) {
    return PlansState(
      descriptions: descriptions ?? this.descriptions,
      exercises: exercises ?? this.exercises,
    );
  }
}
