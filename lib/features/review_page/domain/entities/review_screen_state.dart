import 'package:u_do_note/core/review_methods.dart';

class ReviewScreenState {
  ReviewMethods? reviewMethod;
  String? notebookId;
  List<String>? notebookPagesIds;

  /// Specific for analyze notes because that feature only uses one note at a time
  String? noteId;

  ReviewScreenState({
    this.reviewMethod,
    this.notebookId,
    this.notebookPagesIds,
    this.noteId,
  });

  get getReviewMethod => reviewMethod;
  get getNotebookId => notebookId;
  get getNoteId => noteId;
  get getNotebookPages => notebookPagesIds;

  void setReviewMethod(ReviewMethods reviewMethod) {
    this.reviewMethod = reviewMethod;
  }

  void setNotebookId(String notebookId) {
    this.notebookId = notebookId;
  }

  void setNotebookPagesIds(List<String> notebookPagesIds) {
    this.notebookPagesIds = notebookPagesIds;
  }

  void setNoteId(String noteId) {
    this.noteId = noteId;
  }

  void resetState() {
    reviewMethod = null;
    notebookId = null;
    notebookPagesIds = null;
    noteId = null;
  }

  @override
  String toString() {
    return 'ReviewScreenState{reviewMethod: $reviewMethod, notebookId: $notebookId, notebookPages: $notebookPagesIds, noteId: $noteId}';
  }
}
