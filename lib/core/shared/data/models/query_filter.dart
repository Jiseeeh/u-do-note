import 'package:u_do_note/core/firestore_filter_enum.dart';

class QueryFilter {
  final String field;
  final FirestoreFilter operation;
  final dynamic value;

  QueryFilter({
    required this.field,
    required this.operation,
    this.value,
  });
}
