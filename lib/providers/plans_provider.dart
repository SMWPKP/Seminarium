import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/screens/plans/plans_models.dart';

final plansProvider = StateNotifierProvider<PlansProvider, PlansState>(
    (ref) => PlansProvider(PlansState(), ref));
final selectedExercisesProvider = StateProvider<List<Exercise>>((ref) => []);
final selectedExerciseTypesProvider = StateProvider<Set<String>>((ref) => {});
final exerciseTypesProvider =
    StateProvider<Map<String, List<String>>>((ref) => {});

class PlansProvider extends StateNotifier<PlansState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<int, String> descriptions = {};
  final Map<int, List<String>> exercises = {};
  final StateNotifierProviderRef<PlansProvider, PlansState> ref;

  PlansProvider(PlansState state, this.ref) : super(state) {
    _init();
  }

  Future<void> _init() async {
    // Nasłuchuj zmian w Firebase
    _firestore.collection('plans').snapshots().listen((snapshot) {
      // Aktualizuj stan
      state = PlansState.fromSnapshot(snapshot);
    });
  }

  Future<void> loadExerciseTypes() async {
    DocumentSnapshot doc =
        await _firestore.collection('Exercises').doc('Types').get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    Map<String, List<String>> exerciseTypes = {};

    data.forEach((key, value) {
      if (value is List<dynamic>) {
        exerciseTypes[key] = List<String>.from(value);
      }
    });

    // Aktualizuj provider z typami ćwiczeń
    ref.read(exerciseTypesProvider.notifier).state = exerciseTypes;
  }

  Future<List<Exercise>> showExercisesForType(String exerciseType) async {
    DocumentSnapshot doc =
        await _firestore.collection('Exercises').doc('Types').get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<String> exerciseNames = [];
    if (data.containsKey(exerciseType)) {
      exerciseNames = List<String>.from(data[exerciseType]);
    }

    List<Exercise> exercises =
        exerciseNames.map((name) => Exercise(name: name)).toList();
    ref.read(selectedExercisesProvider.notifier).state = exercises;

    return exercises;
  }

  Future<List<Exercise>> showExercisesForList(
      String userId, List<String> exerciseList, String selectedList) async {
    List<Exercise> exercises = [];

    // Pobieranie ćwiczeń z Exercises/Types
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

    // Pobieranie ćwiczeń z users/uid/savedExercises
    QuerySnapshot userExercisesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedExercises')
        .get();

    userExercisesSnapshot.docs.forEach((doc) {
  Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
  if (userData['customName'] == selectedList && userData.containsKey('exercises')) {
    List<String> userExerciseNames = List<String>.from(userData['exercises']);
    exercises.addAll(userExerciseNames.map((name) => Exercise(name: name)).toList());
  }
});

    ref.read(selectedExercisesProvider.notifier).state = exercises;

    return exercises;
  }

  Future<void> savePlan(String userId, int day, String description,
      List<String> exercisesForTheDay) async {
    final newDescriptions = Map.of(state.descriptions);
    final newExercises = Map.of(state.exercises);

    newDescriptions[day] = description;
    // Jeśli użytkownik nie dokonał żadnych zmian, użyj domyślnego zestawu ćwiczeń
    newExercises[day] = exercisesForTheDay.isEmpty
        ? await getDefaultExercises()
        : exercisesForTheDay;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('exercises')
        .add({
      'date': day.toString(),
      'exercises': newExercises[day],
      'description': description,
      'selectedExercises': ref
          .read(selectedExercisesProvider.notifier)
          .state
          .map((e) => e.name)
          .toList(),
    });
  }

  Future<List<String>> getDefaultExercises() async {
    final doc = await FirebaseFirestore.instance
        .collection('Exercises')
        .doc('Types')
        .get();
    return List<String>.from(doc.data()?['exercises'] ?? []);
  }

  Future<List<String>> getExercisesForDay(String userId, int day) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('exercises')
        .doc(day.toString())
        .get();
    return List<String>.from(doc.data()?['exercises'] ?? []);
  }

  Future<List<String>> getSavedExercises(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedExercises')
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['customName'] as String)
        .toList();
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
  final Map<int, String> descriptions;
  final Map<int, List<String>> exercises;

  PlansState({
    this.descriptions = const {},
    this.exercises = const {},
  });

  factory PlansState.fromSnapshot(QuerySnapshot snapshot) {
    final data = snapshot.docs.first.data();
    if (data != null && data is Map<String, dynamic>) {
      return PlansState(
        descriptions: Map<int, String>.from(
            data['descriptions'] as Map<String, dynamic> ?? {}),
        exercises: Map<int, List<String>>.from(
            (data['exercises'] as Map<String, dynamic> ?? {}).map(
                (key, value) => MapEntry(int.parse(key),
                    List<String>.from(value as List<dynamic>)))),
      );
    } else {
      return PlansState();
    }
  }
}
