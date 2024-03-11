import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_notebook_dialog.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/notebook_card.dart';

@RoutePage()
class NotebooksScreen extends ConsumerWidget {
  const NotebooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotes = ref.watch(notebooksProvider);

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(userNotes: asyncNotes),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => const AddNotebookDialog());
            },
            child: const Icon(Icons.add)),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      title: const Text(
        'U Do Note',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody({required AsyncValue<List<NotebookEntity>> userNotes}) {
    return switch (userNotes) {
      AsyncData(:final value) => GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: (1 / 1.5),
          padding: const EdgeInsets.all(10),
          children: [for (var notebook in value) NotebookCard(notebook)],
        ),
      AsyncError(:final error) => Center(
          child: Text(error.toString()),
        ),
      _ => const Center(
          child: CircularProgressIndicator(),
        ),
    };
  }
}
