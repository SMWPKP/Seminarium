class Exercise {
  final String name;
  final String? customName;

  Exercise({required this.name, this.customName});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  static Exercise fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
    );
  }
}

class User {
  final String uid;
  final List<Exercise> exercises;

  User({required this.uid, required this.exercises});
}
