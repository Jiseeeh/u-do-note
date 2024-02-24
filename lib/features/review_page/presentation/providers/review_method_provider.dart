import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/review_method.dart';

part 'review_method_provider.g.dart';

@riverpod
class ReviewMethodNotifier extends _$ReviewMethodNotifier {
  @override
  List<ReviewMethodEntity> build() {
    // define the review methods

    List<ReviewMethodEntity> reviewMethods = [
      ReviewMethodEntity(
        title: 'Leitner System',
        description: 'Use flashcards as a tool for learning.',
        imagePath: 'lib/assets/flashcard.png',
        onPressed: () {},
      ),
      ReviewMethodEntity(
        title: 'Feynman Technique',
        description:
            'Explain a topic that a five (5) year old child can understand',
        imagePath: 'lib/assets/feynman.png',
        onPressed: () {},
      ),
      ReviewMethodEntity(
        title: 'Pomodoro Technique',
        description: 'Generate text based on your input',
        imagePath: 'lib/assets/pomodoro.png',
        onPressed: () {},
      ),
    ];
    return reviewMethods;
  }

  List<Widget> buildReviewMethods() {
    List<ReviewMethodEntity> reviewMethods = state;
    List<Widget> reviewMethodWidgets = [];

    for (var reviewMethod in reviewMethods) {
      reviewMethodWidgets.add(ReviewMethod(
        title: reviewMethod.title,
        description: reviewMethod.description,
        imagePath: reviewMethod.imagePath,
        onPressed: reviewMethod.onPressed,
      ));

      // spacer
      reviewMethodWidgets.add(const SizedBox(height: 16));
    }

    return reviewMethodWidgets;
  }

  List<ListTile> buildReviewMethodTiles(String currentText) {
    List<ReviewMethodEntity> reviewMethods = state;
    List<ListTile> reviewMethodTiles = [];

    for (var reviewMethod in reviewMethods) {
      reviewMethodTiles.add(ListTile(
        title: Text(reviewMethod.title),
        subtitle: Text(reviewMethod.description),
        leading: Image.asset(reviewMethod.imagePath),
        onTap: reviewMethod.onPressed,
      ));
    }

    if (currentText.isEmpty) {
      return reviewMethodTiles;
    }

    reviewMethodTiles = reviewMethodTiles
        .where((element) => element.title
            .toString()
            .toLowerCase()
            .contains(currentText.toLowerCase()))
        .toList();

    if (reviewMethodTiles.isNotEmpty) {
      return reviewMethodTiles;
    }

    return [
      const ListTile(
        title: Text('No results found'),
      )
    ];
  }
}
