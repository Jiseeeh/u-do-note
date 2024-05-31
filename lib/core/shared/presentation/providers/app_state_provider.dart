import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/domain/entities/app_state.dart';

part 'app_state_provider.g.dart';

@Riverpod(keepAlive: true)
class AppState extends _$AppState {
  @override
  AppStateEntity build() {
    return AppStateEntity();
  }

  void setCurrentNotebookId(String currentNotebookId) {
    logger.d('Setting current notebook id to $currentNotebookId');
    state.setCurrentNotebookId(currentNotebookId);
  }

  void setCurrentNoteId(String currentNoteId) {
    logger.d('Setting current note id to $currentNoteId');
    state.setCurrentNoteId(currentNoteId);
  }

  void resetState() {
    logger.d('Resetting app state');
    state.resetState();
  }
}
