import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';

@RoutePage()
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(ref),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(WidgetRef ref) {
    var currentUser = ref.read(firebaseAuthProvider).currentUser;
    String username = currentUser!.displayName!;

    return AppBar(
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

  Widget _buildBody() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SearchAnchor(
              isFullScreen: false,
              builder: (context, controller) {
                return SearchBar(
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder: (context, controller) {
                // TODO: Implement the suggestions builder with the review methods
                return List<ListTile>.generate(20, (index) {
                  final String item = 'item$index';
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      controller.closeView(item);
                    },
                  );
                });
              },
            ),
            // TODO: Implement the review list methods to choose from
          ],
        ));
  }
}
