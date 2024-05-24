import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_screen_state.dart';

part 'review_screen_provider.g.dart';

@Riverpod(keepAlive: true)
class ReviewScreen extends _$ReviewScreen {
  @override
  ReviewScreenState build() {
    return ReviewScreenState();
  }

  void setReviewMethod(ReviewMethods reviewMethod) {
    state.setReviewMethod(reviewMethod);

    logger
        .d('state is now $state after setting review method to $reviewMethod');
  }

  void setNotebookId(String notebookId) {
    state.setNotebookId(notebookId);

    logger.d('state is now $state after setting notebook id to $notebookId');
  }

  void setNotebookPagesIds(List<String> notebookPagesIds) {
    state.setNotebookPagesIds(notebookPagesIds);

    logger.d('state is now $state after setting notebook ids to $notebookPagesIds');
  }

  void setNoteId(String noteId) {
    state.setNoteId(noteId);

    logger.d('state is now $state after setting note id to $noteId');
  }

  void resetState() {
    state.resetState();

    logger.d('state is now $state after resetting');
  }
}
