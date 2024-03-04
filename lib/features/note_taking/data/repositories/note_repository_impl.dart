import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/datasources/note_remote_datasource.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource _noteRemoteDataSource;

  const NoteRepositoryImpl(this._noteRemoteDataSource);

  @override
  Future<Either<Failure, void>> createNote({required NoteModel note}) {
    // TODO: implement createNote
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> createNotebook({required String name}) async {
    try {
      String res = await _noteRemoteDataSource.createNotebook(name: name);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote({required String id}) {
    // TODO: implement deleteNote
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<NotebookModel>>> getNotebooks() {
    // TODO: implement getNotebooks
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateNote({required String id}) {
    // TODO: implement updateNote
    throw UnimplementedError();
  }
}
