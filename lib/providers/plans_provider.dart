import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/screens/plans/plans_day.dart';

final plansProvider = StateNotifierProvider<PlansProvider, PlansState>((ref) => PlansProvider(PlansState(), ref));
final selectedDayProvider = StateProvider<int>((ref) => 0);
final exercisesProvider = StateNotifierProvider<ExercisesNotifier, List<Exercise>>((ref) => ExercisesNotifier());
final selectedExercises = StateProvider<List<Exercise>>((ref) => []); 


class PlansProvider extends StateNotifier<PlansState> {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 final Map<int, String> dayContents = {};
 final Map<int, String> descriptions = {};
 final Map<int, String> notes = {};
 final Map<int, List<Exercise>> exercises = {};
 final StateNotifierProviderRef<PlansProvider, PlansState> ref;

 
PlansProvider(PlansState state, this.ref) : super(state) {
  loadDayContents();
  loadSelectedExercises();
 }

 Future<void> loadDayContents() async {
 final month = DateTime.now().month; // Pobierz aktualny miesiąc

 // Pobierz dane dla danego miesiąca
 final doc = await _firestore.collection('months').doc(month.toString()).get();
 final data = doc.data();
 if (data != null) {
  final daysData = data['days'] as Map<String, dynamic>;
  for (var dayData in daysData.entries) {
   final day = int.parse(dayData.key);
   final content = dayData.value['content'];
   final description = dayData.value['description'];
   final note = dayData.value['note'];
   final exercisesData = (dayData.value['exercises'] as List)
     .map((e) => Exercise(name: e['name'], description: e['description']))
     .toList();

   dayContents[day] = content;
   descriptions[day] = description;
   notes[day] = note;
   exercises[day] = exercisesData;
  }
 }
}

void updateSelectedExercises(Exercise exercise, bool isSelected) {
    final currentState = ref.read(selectedExercises);
    final updatedList = currentState?.toList() ?? [];

    if (isSelected) {
      updatedList.add(exercise);
    } else {
      updatedList.remove(exercise);
    }

    ref.read(selectedExercises.notifier).state = updatedList;
  }

  Future<void> loadSelectedExercises() async {
    // Pobierz dane z Firestore
    final data = await FirebaseFirestore.instance.collection('plans').doc('exercises').get();

    // Zdekoduj dane do listy Exercise
    final exercises = (data.data()?['selectedExercises'] as List)
        ?.map((e) => Exercise.fromJson(e))
        ?.toList();

    // Zaktualizuj stan providera
    ref.read(selectedExercises.notifier).state = exercises ?? [];
  }

  // Funkcja zapisująca listę 'selectedExercises' w Firestore
  Future<void> saveSelectedExercises() async {
    // Zaktualizuj dane w Firestore
    await FirebaseFirestore.instance.collection('plans').doc('exercises').set({
      'selectedExercises': ref.watch(selectedExercises).map((e) => e.toJson()).toList(),
    });
  }

}

class PlansState {
 final Map<int, String> dayContents = {};
 final Map<int, String> descriptions = {};
 final Map<int, String> notes = {};
 final Map<int, List<Exercise>> exercises = {};
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