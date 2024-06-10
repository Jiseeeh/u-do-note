import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/features/review_page/domain/entities/review_screen_state.dart';

part 'review_screen_provider.g.dart';

@Riverpod(keepAlive: true)
class ReviewScreen extends _$ReviewScreen {
  @override
  ReviewScreenState build() {
    return ReviewScreenState();
  }
}
