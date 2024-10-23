import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:u_do_note/core/error/failures.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_preferences_provider.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_notebook_dialog.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/notebook_card_v2.dart';

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
  List _elements = [];

  @override
  void initState() {
    super.initState();
    initGridCols();
    getCategories();
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

  void getCategories() async {
    var failureOrCategories =
        await ref.read(notebooksProvider.notifier).getCategories();
    var notebooks = await ref.read(notebooksProvider.notifier).getNotebooks();

    if (failureOrCategories is Failure) {
      print('Error is: ' + failureOrCategories.message);
      return;
    }

    if (notebooks is Failure) {
      print('Error is: ' + notebooks.message);
      return;
    }

    notebooks = notebooks as List<NotebookModel>;
    _elements = notebooks
        .map((notebook) => {
              'subject': notebook.subject,
              'category': notebook.category,
              'cover':
                  notebook.coverUrl.isNotEmpty ? notebook.coverUrl : 'default'
            })
        .toList();

    print('Elements: $_elements');
    print('Categories: $failureOrCategories');
    print('Notebooks: $notebooks');
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
      toolbarHeight: 80,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text('U Do Note', style: Theme.of(context).textTheme.bodyLarge),
          Text('Notebooks', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.category_outlined),
          color: Theme.of(context).primaryColor,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16))),
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.75,
                expand: false,
                builder: (_, controller) => Column(
                  children: [
                    SizedBox(height: 3.h),
                    Text('Categories',
                        style: Theme.of(context).textTheme.headlineMedium),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: 10,
                        itemBuilder: (_, index) {
                          return InkWell(
                            onTap: () => Navigator.pop(context), // Update state
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text("Element at index($index)"),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
          icon: Icon(
            Icons.sort_outlined,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
      centerTitle: false,
      elevation: 0,
    );
  }

  Widget _buildBody(AsyncValue<List<NotebookEntity>> notebooksAsync,
      List<NotebookEntity>? notebooksSync) {
    if (notebooksSync != null && notebooksSync.isEmpty) {
      return Center(
        child: Text(context.tr("no_notebook")),
      );
    }

    // return SafeArea(
    //   child: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       children: [
    //         Expanded(
    //           child: SingleChildScrollView(
    //             child: Column(
    //               children: [
    //                 ExpansionTile(
    //                   trailing: const Icon(
    //                     Icons.arrow_drop_down,
    //                     // color: Colors.transparent,
    //                   ),
    //                   tilePadding: const EdgeInsets.all(0),
    //                   minTileHeight: 0,
    //                   shape: Border.all(color: Colors.transparent, width: 0),
    //                   collapsedShape:
    //                       Border.all(color: Colors.transparent, width: 0),
    //                   initiallyExpanded: true,
    //                   title: Text(
    //                     'UNCATEGORIZED',
    //                     style: Theme.of(context).textTheme.bodyMedium,
    //                   ),
    //                   children: <Widget>[
    //                     ListView.builder(
    //                       shrinkWrap: true,
    //                       physics: const NeverScrollableScrollPhysics(),
    //                       scrollDirection: Axis.vertical,
    //                       itemCount: 3,
    //                       itemBuilder: (BuildContext context, int index) {
    //                         return const NotebookCardV2(
    //                           notebookName: 'Notebook Name',
    //                           imagePath: 'assets/images/feynman.png',
    //                           pages: '2',
    //                         );
    //                       },
    //                     )
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
      child: GroupedListView<dynamic, String>(
        elements: _elements,
        groupBy: (element) => element['category'],
        groupComparator: (value1, value2) => value2.compareTo(value1),
        itemComparator: (item1, item2) =>
            item1['subject'].compareTo(item2['subject']),
        order: GroupedListOrder.ASC,
        useStickyGroupSeparators: false,
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            value,
            // textAlign: TextAlign.center,
            // style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        itemBuilder: (c, element) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: const AlignmentDirectional(-1, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(0),
                    ),
                    child: buildCoverImage(element['cover']),
                    // 'assets/images/default.png',
                    // notebook.coverUrl.isNotEmpty
                    //     ? notebook.coverUrl
                    //     :
                    // 'https://firebasestorage.googleapis.com/v0/b/u-do-note-0.appspot.com/o/notebook_covers%2Fdefault.png?alt=media&token=42535473-0ffa-47a8-b53c-b6f95081ebed',
                    //   notebook.coverUrl.isNotEmpty
                    //   ? NetworkImage(notebook.coverUrl) as ImageProvider
                    //   // TODO: replace with default one
                    //   : const AssetImage('assets/images/default.png')) as String,
                    // width: 85,
                    // height: 100,
                    // fit: BoxFit.cover,
                    // ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(8, 12, 16, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-1, 0),
                            child: Text(element['subject'],
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
                                child: Text(
                                  'Pages:',
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '%pages%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.color),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.chevron_right),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
    // return switch (notebooksAsync) {
    //   AsyncData(:final value) => Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: SingleChildScrollView(
    //         child: Column(
    //           children: [for (var notebook in value) NotebookCardV2(notebook)],
    //         ),
    //       ),
    //     ),
    //   AsyncError(:final error) => Center(child: Text(error.toString())),
    //   _ => const Center(
    //       child: CircularProgressIndicator(),
    //     ),
    // };

    // return switch (notebooksAsync) {
    //   AsyncData(:final value) => GridView.count(
    //       crossAxisCount: gridCols,
    //       crossAxisSpacing: 10,
    //       mainAxisSpacing: 10,
    //       childAspectRatio: (1 / 1.5),
    //       padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
    //       children: [for (var notebook in value) NotebookCard(notebook)],
    //     ),
    //   AsyncError(:final error) => Center(child: Text(error.toString())),
    //   _ => const Center(
    //       child: CircularProgressIndicator(),
    //     ),
    // };
  }

  Widget buildCoverImage(String coverFileName) {
    if (coverFileName.isNotEmpty) {
      return Image.network(
        coverFileName,
        width: 80,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/default.png',
        width: 80,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }
}
