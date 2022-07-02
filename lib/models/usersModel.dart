class UsersModel {
  final String name;
  final String email;

  UsersModel({this.name, this.email});

  UsersModel.fromFirestore(Map<String, dynamic> firestore)
      : name = firestore['Name'],
        email = firestore['Email'];
}
