import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/leitner_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner_sytem_repository.dart';

class LeitnerSystemImpl implements LeitnerSystemRepository {
  final LeitnerRemoteDataSource _leitnerRemoteDataSource;

  LeitnerSystemImpl(this._leitnerRemoteDataSource);

  @override
  Future<Either<Failure, List<FlashcardModel>>> generateFlashcards(
      {required String userId, required String userNoteId}) async {
    try {
      final flashcards =
          await _leitnerRemoteDataSource.generateFlashcards(userId, userNoteId);
      final firestore = FirebaseFirestore.instance;

      var leitnerSystem = LeitnerSystemModel(
        userId: userId,
        userNoteId: userNoteId,
        flashcards: flashcards,
      );

      // Save the flashcards to firestore to be updated
      // after the user has reviewed the flashcards.
      await firestore.collection('remarks').add(<String, dynamic>{
        ...leitnerSystem.toJson(),
        'remark': '',
        'score': null,
        'last_updated': DateTime.now(),
      });

      return Right(flashcards);
    } on RequestFailedException catch (e) {
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } on Exception catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
