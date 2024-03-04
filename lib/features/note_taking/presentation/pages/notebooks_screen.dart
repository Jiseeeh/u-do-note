import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';

@RoutePage()
class NotebooksScreen extends ConsumerWidget {
  const NotebooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<NotebookEntity> notes = ref.watch(notesProvider);

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(userNotes: notes),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => _buildAddNotebookDialog(context, ref));
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

  Widget _buildBody({required List<NotebookEntity> userNotes}) {
    if (userNotes.isEmpty) {
      return const Center(child: Text('No Notebooks Yet'));
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: (1 / 1.5),
      padding: const EdgeInsets.all(10),
      //TODO: build using the retrieved data (user_notes)
      children: [
        Column(
          children: [
            Expanded(
                child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('lib/assets/chisaki.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: InkWell(
                // ? InkWell is for the ripple effect
                onTap: () {},
              ),
            )),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Javascript',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: IconButton(
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert)),
                      )
                    ],
                  ),
                  const Text('2024-03-1 04:45',
                      style: TextStyle(color: AppColors.grey))
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  AlertDialog _buildAddNotebookDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    return AlertDialog(
      title: const Text('Add Notebook'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Notebook Name',
              hintText: 'Enter Notebook Name',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
