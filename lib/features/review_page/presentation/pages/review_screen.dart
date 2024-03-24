import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_method_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/review_method.dart';

@RoutePage()
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(ref),
      body: _buildBody(ref),
    );
  }

  AppBar _buildAppBar(WidgetRef ref) {
    var currentUser = ref.read(firebaseAuthProvider).currentUser;
    String username = currentUser!.displayName!;

    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back,',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add,
              color: Colors.blue,
              size: 40,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBody(WidgetRef ref) {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchAnchor(
                isFullScreen: false,
                builder: (context, controller) {
                  return SearchBar(
                    hintText: 'Search',
                    backgroundColor: MaterialStateColor.resolveWith((_) {
                      return const Color(0xffececec);
                    }),
                    shadowColor: MaterialStateColor.resolveWith((_) {
                      return Colors.transparent;
                    }),
                    controller: controller,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTap: () {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  return _buildReviewMethodTiles(context, ref, controller.text);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(children: _buildReviewMethods(context, ref))),
              )
            ],
          )),
    );
  }

  List<Widget> _buildReviewMethods(BuildContext context, WidgetRef ref) {
    List<ReviewMethodEntity> reviewMethods = ref
        .read(reviewMethodNotifierProvider.notifier)
        .getReviewMethods(context);
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

  List<ListTile> _buildReviewMethodTiles(
      BuildContext context, WidgetRef ref, String currentText) {
    List<ReviewMethodEntity> reviewMethods = ref
        .read(reviewMethodNotifierProvider.notifier)
        .getReviewMethods(context);
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
