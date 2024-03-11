import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/screens/plans/plans_day.dart';

final plansProvider = StateNotifierProvider<PlansProvider, PlansState>((ref) => PlansProvider(PlansState(), ref));
final selectedExercisesProvider = StateProvider<List<Exercise>>((ref) => []);
final exercisesProvider = StateNotifierProvider<ExercisesNotifier, List<Exercise>>((ref) => ExercisesNotifier());

class PlansProvider extends StateNotifier<PlansState> {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 final Map<int, String> dayContents = {};
 final Map<int, String> descriptions = {};
 final Map<int, String> notes = {};
 final Map<int, List<Exercise>> exercises = {};
 final StateNotifierProviderRef<PlansProvider, PlansState> ref;
 
PlansProvider(PlansState state, this.ref) : super(state) {
  loadSelectedExercises();
  _init();
 }

 Future<void> _init() async {
    // Nasłuchuj zmian w Firebase
    _firestore.collection('plans').snapshots().listen((snapshot) {
      // Aktualizuj stan
      state = PlansState.fromSnapshot(snapshot);
    });
  }
 

void updateSelectedExercises(Exercise exercise, bool isSelected) {
  print('--- updateSelectedExercises CALLED ---'); // Add this
  print('Exercise: ${exercise.name}, isSelected: $isSelected');
    if (isSelected) {
      ref.read(selectedExercisesProvider.notifier).state = 
          [...ref.read(selectedExercisesProvider), exercise]; // Add exercise name
    } else {
      ref.read(selectedExercisesProvider.notifier).state =
          List.from(ref.read(selectedExercisesProvider))..remove(exercise);  // Remove exercise
    }

    saveSelectedExercises(); // Trigger save after each change
  }

  Future<void> loadSelectedExercises() async {
  final data = await FirebaseFirestore.instance.collection('plans').doc('exercises').get();

  // Check if 'selectedExercises' exists before casting
  final exercisesData = data.data()?['selectedExercises'] ?? [];
  final exercises = (exercisesData as List).map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
  ref.read(selectedExercisesProvider.notifier).state = exercises;
}

  // Funkcja zapisująca listę 'selectedExercises' w Firestore
  Future<void> saveSelectedExercises() async {
    await FirebaseFirestore.instance.collection('plans').doc('exercises').set({
'selectedExercises': ref.watch(selectedExercisesProvider.notifier).state.map((e) => e.toJson()).toList(),
    });
  }

  Future<void> savePlan(String userId, int day, String description) async {
  final selectedExercises = ref.read(selectedExercisesProvider.notifier).state;

  // Zapisz do Firebase
  await _firestore.collection('plans').doc(userId).collection('data').doc(day.toString()).set({
    'selectedExercises': selectedExercises.map((e) => e.toJson()).toList(),
    'description': description,
  });

  // Aktualizuj stan
    state = state.copyWith(
    exercises: state.exercises..[day] = selectedExercises,
    descriptions: state.descriptions..[day] = description,
  );
}
}


class PlansState {
 final Map<int, String> dayContents;
 final Map<int, String> descriptions;
 final Map<int, String> notes;
 final Map<int, List<Exercise>> exercises;

PlansState({
    this.dayContents = const {},
    this.descriptions = const {},
    this.notes = const {},
    this.exercises = const {},
  });

factory PlansState.fromSnapshot(QuerySnapshot snapshot) {
    final data = snapshot.docs.first.data();
    if (data is Map<String, dynamic>) {
      return PlansState(
        dayContents: Map.from(data['dayContents'] as Map<String, dynamic> ?? {}),
        descriptions: Map.from(data['descriptions'] as Map<String, dynamic> ?? {}),
        notes: Map.from(data['notes'] as Map<String, dynamic> ?? {}),
        exercises: (data['exercises'] as Map<String, dynamic> ?? {}).map(
          (key, value) => MapEntry(int.parse(key), List<Exercise>.from(value.map((e) => Exercise.fromJson(e as Map<String, dynamic>))))
        ),
      );
    } else {
      return PlansState();
    }
  }

  PlansState copyWith({
    Map<int, String>? dayContents,
    Map<int, String>? descriptions,
    Map<int, String>? notes,
    Map<int, List<Exercise>>? exercises,
  }) {
    return PlansState(
      dayContents: dayContents ?? this.dayContents,
      descriptions: descriptions ?? this.descriptions,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
    );
  }
}




class ExercisesNotifier extends StateNotifier<List<Exercise>> {
 ExercisesNotifier() : super([]);

 final _firestore = FirebaseFirestore.instance;

 Future<void> saveExercises() async {
  final exercisesData = state.map((exercise) => exercise.toJson()).toList();
  await _firestore.collection('exercises').add({
   'exercises': exercisesData,
  });
 }

 void addExercise(Exercise exercise) {
  state = [...state, exercise];
 }

 void removeExercise(int index) {
  state = [...state]..removeAt(index);
 }

 void updateExercise(int index, Exercise updatedExercise) {
  state = [...state]..[index] = updatedExercise;
 }

 Future<void> loadExercises() async {
  final snapshot = await _firestore.collection('exercises').get();
  final exercisesData = snapshot.docs.first.data()['exercises'] as List;
  state = exercisesData.map((data) => Exercise.fromJson(data)).toList();
 }
}

class PlansNotifier extends StateNotifier<Map<String, List<Exercise>>> {
 PlansNotifier() : super({});

 void addExercise(String day, Exercise exercise) {
  state = {
   ...state,
   day: [...state[day] ?? [], exercise],
  };
 }

}