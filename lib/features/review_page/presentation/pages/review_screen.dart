import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_method_provider.dart';

@RoutePage()
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    var reviewMethodsNotifier = ref.read(reviewMethodNotifierProvider.notifier);

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
                  return reviewMethodsNotifier
                      .buildReviewMethodTiles(controller.text);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                        children: reviewMethodsNotifier.buildReviewMethods())),
              )
            ],
          )),
    );
  }
}
