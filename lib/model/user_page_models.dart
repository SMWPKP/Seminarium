class UserPage {
  final String imagePath;
  final String name;
  final String email;
  final String about;
  final int phoneNumber;

  const UserPage(
      {required this.imagePath,
      required this.name,
      required this.email,
      required this.about,
      required this.phoneNumber});


  UserPage.fromFirestore(Map<String, dynamic> firestore)
      : imagePath = firestore['imagePath'] ?? '',
        name = firestore['name'] ?? 'uzupełnij dane',
        email = firestore['email'] ?? 'uzupełnij dane',
        about = firestore['about'] ?? 'uzupełnij dane',
        phoneNumber = firestore['phoneNumber'] ?? 123456789;

  Map<String, dynamic> toFirestore() => {
        'imagePath': imagePath,
        'name': name,
        'email': email,
        'about': about,
        'phoneNumber': phoneNumber,
      };

UserPage copyWith({
    String? imagePath,
    String? name,
    String? email,
    String? about,
    int? phoneNumber,
  }) {
    return UserPage(
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      email: email ?? this.email,
      about: about ?? this.about,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
