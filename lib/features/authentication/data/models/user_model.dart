import 'package:u_do_note/features/authentication/domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String photoUrl;
  final String uid;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.uid,
  });

  // entity to model
  factory UserModel.fromEntity(User user) => UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      uid: user.uid);

  // model to entity
  User toEntity() =>
      User(id: id, email: email, name: name, photoUrl: photoUrl, uid: uid);

  // from firestore to model
  factory UserModel.fromSnapshot(Map<String, dynamic> snapshot) {
    return UserModel(
      id: snapshot['id'],
      email: snapshot['email'],
      name: snapshot['name'],
      photoUrl: snapshot['photoUrl'],
      uid: snapshot['uid'],
    );
  }
}
