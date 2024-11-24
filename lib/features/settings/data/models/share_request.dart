import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/data/models/note.dart';

class ShareRequest {
  final String? id;
  final Timestamp createdAt;
  final String senderEmail;
  final String receiverEmail;
  final bool isAccepted;
  final List<NoteModel> notesToShare;

  const ShareRequest({
    this.id,
    required this.createdAt,
    required this.senderEmail,
    required this.receiverEmail,
    this.isAccepted = false,
    required this.notesToShare,
  });

  /// Converts from firestore to [ShareRequest] model
  factory ShareRequest.fromFirestore(String id, Map<String, dynamic> data) {
    return ShareRequest(
        id: id,
        createdAt: data['created_at'],
        senderEmail: data['sender_email'],
        receiverEmail: data['receiver_email'],
        notesToShare: (data['notes_to_share'] as List)
            .map((note) => NoteModel.fromFirestore(note))
            .toList(),
        isAccepted: data['is_accepted']);
  }

  /// Converts from [ShareRequest] model to firestore
  Map<String, dynamic> toFirestore() {
    return {
      'created_at': createdAt,
      'sender_email': senderEmail,
      'receiver_email': receiverEmail,
      'is_accepted': isAccepted,
      'notes_to_share': notesToShare.map((note) => note.toJson()).toList()
    };
  }
}
