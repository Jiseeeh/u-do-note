import 'package:u_do_note/core/review_methods.dart';

class ReviewScreenState {
  ReviewMethods? reviewMethod;
  String? notebookId;
  String? noteId;

  ReviewScreenState({
    this.reviewMethod,
    this.notebookId,
    this.noteId,
  });

  get getReviewMethod => reviewMethod;
  get getNotebookId => notebookId;
  get getNoteId => noteId;

  void setReviewMethod(ReviewMethods reviewMethod) {
    this.reviewMethod = reviewMethod;
  }

  void setNotebookId(String notebookId) {
    this.notebookId = notebookId;
  }

  void setNoteId(String noteId) {
    this.noteId = noteId;
  }

  void resetState() {
    reviewMethod = null;
    notebookId = null;
    noteId = null;
  }

  @override
  String toString() {
    return 'ReviewScreenState(reviewMethod: $reviewMethod, notebookId: $notebookId, noteId: $noteId)';
  }
}
