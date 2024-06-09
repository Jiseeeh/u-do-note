// TODO: pending for deletion (unused)
class AppStateEntity {
  String currentNotebookId;
  String currentNoteId;

  AppStateEntity({
    this.currentNotebookId = '',
    this.currentNoteId = '',
  });

  get getCurrentNotebookId => currentNotebookId;
  get getCurrentNoteId => currentNoteId;

  void setCurrentNotebookId(String currentNotebookId) {
    this.currentNotebookId = currentNotebookId;
  }

  void setCurrentNoteId(String currentNoteId) {
    this.currentNoteId = currentNoteId;
  }

  void resetState() {
    currentNotebookId = '';
    currentNoteId = '';
  }

  @override
  String toString() {
    return 'AppState{currentNotebookId: $currentNotebookId, currentNoteId: $currentNoteId}';
  }
}
