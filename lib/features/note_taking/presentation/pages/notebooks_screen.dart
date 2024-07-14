import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:u_do_note/core/shared/domain/providers/shared_preferences_provider.dart';
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
  var sortBy = 'name'; // Default sorting criteria

  @override
  void initState() {
    super.initState();
    initGridCols();
  }

  void initGridCols() async {
    var prefs = await ref.read(sharedPreferencesProvider.future);
    var cols = prefs.getInt('nbGridCols');
    if (cols != null) {
      setState(() {
        gridCols = cols;
      });
    }
  }

  void sortNotebooks(List<NotebookEntity>? notebooks) {
    if (notebooks == null) return;
    if (sortBy == 'name') {
      notebooks.sort((a, b) => a.subject.compareTo(b.subject));
    } else if (sortBy == 'date') {
      notebooks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    var notebooksAsync = ref.watch(notebooksStreamProvider);
    var notebooksSync = notebooksAsync.value;
    if (notebooksSync != null) {
      sortNotebooks(notebooksSync);
    }

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(notebooksAsync, notebooksSync),
        floatingActionButton: SpeedDial(
          activeIcon: Icons.close,
          buttonSize: const Size(50, 50),
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
                elevation: 0,
                child: const Icon(Icons.note_add),
                labelWidget: Text(context.tr("create_notebook")),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: ((dialogContext) => const AddNotebookDialog()));
                }),
            SpeedDialChild(
                elevation: 0,
                child: const Icon(Icons.looks_two_rounded),
                labelWidget: Text(context.tr("two_col")),
                onTap: () async {
                  var prefs = await ref.read(sharedPreferencesProvider.future);
                  prefs.setInt('nbGridCols', 2);
                  setState(() {
                    if (gridCols != 2) {
                      gridCols = 2;
                    }
                  });
                }),
            SpeedDialChild(
                elevation: 0,
                child: const Icon(Icons.looks_3_rounded),
                labelWidget: Text(context.tr("three_col")),
                onTap: () async {
                  var prefs = await ref.read(sharedPreferencesProvider.future);
                  prefs.setInt('nbGridCols', 3);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        'U Do Note',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              sortBy = value;
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'name',
              child: Text(context.tr("sort_title")),
            ),
            PopupMenuItem(
              value: 'date',
              child: Text(context.tr("sort_date")),
            ),
          ],
          icon: const Icon(Icons.sort),
        ),
      ],
    );
  }

  Widget _buildBody(AsyncValue<List<NotebookEntity>> notebooksAsync,
      List<NotebookEntity>? notebooksSync) {
    if (notebooksSync != null && notebooksSync.isEmpty) {
      return Center(
        child: Text(context.tr("no_notebook")),
      );
    }

    return switch (notebooksAsync) {
      AsyncData(:final value) => GridView.count(
          crossAxisCount: gridCols,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: (1 / 1.5),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
          children: [for (var notebook in value) NotebookCard(notebook)],
        ),
      AsyncError(:final error) => Center(child: Text(error.toString())),
      _ => const Center(
          child: CircularProgressIndicator(),
        ),
    };
  }
}
