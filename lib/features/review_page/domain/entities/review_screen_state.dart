import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';

class ReviewScreenState {
  ReviewMethods? reviewMethod;
  String? notebookId;
  String? contentFromPages;
  String? sessionTitle;
  bool isFromAutoAnalysis;
  List<String>? notebookPagesIds;

  /// Specific for analyze notes because that feature only uses one note at a time
  String? noteId;

  /// Specific for blurting method
  bool isFromOldBlurtingSession;

  /// Specific for spaced repetition
  bool isFromOldSpacedRepetition;

  /// Specific for active recall
  bool isFromOldActiveRecall;

  ReviewScreenState(
      {this.reviewMethod,
      // ? defaults to "" as accessing it at first where on multi selects throws bad state
      this.notebookId = "",
      this.contentFromPages,
      this.sessionTitle,
      this.isFromAutoAnalysis = false,
      this.notebookPagesIds,
      this.noteId,
      this.isFromOldBlurtingSession = false,
      this.isFromOldSpacedRepetition = false,
      this.isFromOldActiveRecall = false});

  get getReviewMethod => reviewMethod;

  get getNotebookId => notebookId;

  get getContentFromPages => contentFromPages;

  get getSessionTitle => sessionTitle;

  get getIsFromAutoAnalysis => isFromAutoAnalysis;

  get getNoteId => noteId;

  get getNotebookPagesIds => notebookPagesIds;

  get getIsFromOldBlurtingSession => isFromOldBlurtingSession;

  get getIsFromOldSpacedRepetition => isFromOldSpacedRepetition;

  get getIsFromOldActiveRecall => isFromOldActiveRecall;

  void setReviewMethod(ReviewMethods reviewMethod) {
    this.reviewMethod = reviewMethod;
  }

  void setNotebookId(String notebookId) {
    logger.d('Setting notebook ID to: $notebookId');
    this.notebookId = notebookId;
  }

  void setContentFromPages(String contentFromPages) {
    this.contentFromPages = contentFromPages;
  }

  void setSessionTitle(String sessionTitle) {
    logger.d('Setting session title to: $sessionTitle');
    this.sessionTitle = sessionTitle;
  }

  void setIsFromAutoAnalysis(bool isFromAutoAnalysis) {
    this.isFromAutoAnalysis = isFromAutoAnalysis;
  }

  void setNotebookPagesIds(List<String> notebookPagesIds) {
    logger.d('Setting IDs to: $notebookPagesIds');
    this.notebookPagesIds = notebookPagesIds;
  }

  void setNoteId(String noteId) {
    logger.d('Setting note ID to: $noteId');
    this.noteId = noteId;
  }

  void setIsFromOldBlurtingSession(bool value) {
    logger.d('Setting isFromOldBlurtingSession to: $value');
    isFromOldBlurtingSession = value;
  }

  void setIsFromOldSpacedRepetition(bool value) {
    logger.d('Setting isFromOldSpacedRepetition to: $value');
    isFromOldSpacedRepetition = value;
  }

  void setIsFromOldActiveRecall(bool value) {
    logger.d('Setting isFromOldActiveRecall to: $value');
    isFromOldActiveRecall = value;
  }

  void resetState() {
    logger.w('Resetting state...');
    reviewMethod = null;
    notebookId = "";
    notebookPagesIds = null;
    contentFromPages = null;
    sessionTitle = null;
    isFromAutoAnalysis = false;
    noteId = null;
    isFromOldBlurtingSession = false;
    isFromOldSpacedRepetition = false;
    isFromOldActiveRecall = false;
  }

  @override
  String toString() {
    return 'ReviewScreenState{reviewMethod: $reviewMethod, notebookId: $notebookId, contentFromPages: $contentFromPages , sessionTitle: $sessionTitle, notebookPages: $notebookPagesIds, noteId: $noteId, isFromAutoAnalysis: $isFromAutoAnalysis}';
  }
}
