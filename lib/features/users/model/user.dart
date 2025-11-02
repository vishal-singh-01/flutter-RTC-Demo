class UserX {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;


  UserX({required this.id, required this.email, required this.firstName, required this.lastName, required this.avatar});


  factory UserX.fromJson(Map<String, dynamic> j) => UserX(
    id: j['id'] as int,
    email: j['email'] as String,
    firstName: j['first_name'] as String,
    lastName: j['last_name'] as String,
    avatar: j['avatar'] as String,
  );


  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'avatar': avatar,
  };
}