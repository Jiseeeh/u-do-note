import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_notebook_dialog.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/notebook_card.dart';

@RoutePage()
class NotebooksScreen extends ConsumerStatefulWidget {
  const NotebooksScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotebooksScreenState();
}

class _NotebooksScreenState extends ConsumerState<NotebooksScreen> {
  var gridCols = 2;

  @override
  Widget build(BuildContext context) {
    final asyncNotes = ref.watch(notebooksProvider);

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(userNotes: asyncNotes),
        floatingActionButton: SpeedDial(
          activeIcon: Icons.close,
          buttonSize: const Size(50, 50),
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
                elevation: 0,
                child: const Icon(Icons.note_add),
                labelWidget: const Text('Add Notebook'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: ((dialogContext) => const AddNotebookDialog()));
                }),
            SpeedDialChild(
                elevation: 0,
                child: const Icon(Icons.looks_two_rounded),
                labelWidget: const Text('Two Columns'),
                onTap: () {
                  setState(() {
                    if (gridCols != 2) {
                      gridCols = 2;
                    }
                  });
                }),
            SpeedDialChild(
                elevation: 0,
                child: const Icon(Icons.looks_3_rounded),
                labelWidget: const Text('Three Columns'),
                onTap: () {
                  setState(() {
                    if (gridCols != 3) {
                      gridCols = 3;
                    }
                  });
                }),
          ],
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'U Do Note',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }

  Widget _buildBody({required AsyncValue<List<NotebookEntity>> userNotes}) {
    if (userNotes.hasValue && userNotes.value!.isEmpty) {
      return const Center(
        child: Text('No Notebooks yet.'),
      );
    }

    return switch (userNotes) {
      AsyncData(:final value) => GridView.count(
          crossAxisCount: gridCols,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: (1 / 1.5),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
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
