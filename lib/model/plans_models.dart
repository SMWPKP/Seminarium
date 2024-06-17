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
