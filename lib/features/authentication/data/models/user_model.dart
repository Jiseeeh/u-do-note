import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_do_note/features/authentication/domain/entities/user.dart';

typedef FirebaseUser = User;

class UserModel {
  final String id;
  final String email;
  final String name;
  final String photoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.photoUrl,
  });

  // entity to model
  factory UserModel.fromEntity(UserEntity user) => UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        photoUrl: user.photoUrl,
      );

  // model to entity
  UserEntity toEntity() =>
      UserEntity(id: id, email: email, name: name, photoUrl: photoUrl);

  // from firestore to model
  factory UserModel.fromFirebaseUser(FirebaseUser? firebaseUser) {
    return UserModel(
      id: firebaseUser!.uid,
      email: firebaseUser.email!,
      name: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL ?? '',
    );
  }
}
