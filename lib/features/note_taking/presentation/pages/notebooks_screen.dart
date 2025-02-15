import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_category_dialog.dart';
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
  List _elements = [], _categories = [];
  var filterCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  void getCategories() async {
    var failureOrCategories =
        await ref.read(notebooksProvider.notifier).getCategories();
    var notebooks = await ref.read(notebooksProvider.notifier).getNotebooks();

    if (failureOrCategories is Failure) {
      EasyLoading.showError(
          "Something went wrong when getting your categories.");
      logger.w("Cause: ${failureOrCategories.message}");
      return;
    }

    if (notebooks is Failure) {
      EasyLoading.showError("Something went wrong when getting your notebooks");
      logger.w("Cause: ${notebooks.message}");
      return;
    }

    notebooks = notebooks as List<NotebookModel>;
    if (filterCategory != 'All') {
      _elements = notebooks
          .map(
            (notebook) => {
              'subject': notebook.subject,
              'category': notebook.category,
              'cover':
                  notebook.coverUrl.isNotEmpty ? notebook.coverUrl : 'default'
            },
          )
          .where((e) => e['category'] == filterCategory)
          .toList();
    } else {
      _elements = notebooks
          .map(
            (notebook) => {
              'id': notebook.id,
              'subject': notebook.subject,
              'category': notebook.category,
              'cover':
                  notebook.coverUrl.isNotEmpty ? notebook.coverUrl : 'default',
              'created_at': notebook.createdAt,
            },
          )
          .toList();
    }

    setState(() {
      _categories = failureOrCategories;
      _isLoading = false;
    });
  }

  void _update(String categoryName) {
    setState(() {
      filterCategory = categoryName;
      getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    var notebooksAsync = ref.watch(notebooksStreamProvider);
    var notebooksSync = notebooksAsync.value;

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
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: ((dialogContext) => AddNotebookDialog(
                            categories: _categories.cast<String>(),
                          )));
                  _update('All');
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
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.15,
                maxChildSize: 0.5,
                expand: false,
                builder: (_, controller) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: ((dialogContext) =>
                                    const AddCategoryDialog()),
                              );
                              getCategories();
                            },
                          )
                        ],
                      ),
                    ),
                    buildCategoryListItem('All'),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: _categories.length,
                        itemBuilder: (_, index) {
                          return buildCategoryListItem(_categories[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
        child: Text(
          context.tr("no_notebook"),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return switch (notebooksAsync) {
      AsyncData(:final value) => Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
          child: GroupedListView<dynamic, String>(
            elements: _elements,
            groupBy: (element) => element['category'],
            groupComparator: (value1, value2) => value2.compareTo(value1),
            itemComparator: (item1, item2) =>
                item1['category'].compareTo(item2['category']),
            order: GroupedListOrder.ASC,
            useStickyGroupSeparators: false,
            groupSeparatorBuilder: (String value) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                value,
              ),
            ),
            itemBuilder: (c, element) {
              return Column(
                children: [
                  for (var notebook in value)
                    if (notebook.subject == element['subject'])
                      NotebookCard(
                          notebook, _update, _categories.cast<String>())
                ],
              );
            },
          ),
        ),
      AsyncError(:final error) => Center(child: Text(error.toString())),
      _ => const Center(
          child: CircularProgressIndicator(),
        ),
    };
  }

  Widget buildCoverImage(String coverFileName) {
    if (coverFileName != "default") {
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

  Future<dynamic> getUserConfirmation(
      BuildContext context, String notebookOrCategory) {
    var deleteConfirm = (notebookOrCategory == "Notebook")
        ? context.tr("delete_notebook_confirm")
        : context.tr("delete_category_confirm");

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$notebookOrCategory deletion'),
          content: Text(deleteConfirm),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('No')),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> getIntent(BuildContext context, String notebookOrCategory) {
    var action = (notebookOrCategory == "Notebook")
        ? context.tr("notebook_action")
        : context.tr("category_action");

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$notebookOrCategory Actions'),
          content: Text(action),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: Text(
                  context.tr("delete_action"),
                  style: const TextStyle(color: AppColors.error),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: Text(context.tr("edit_action"))),
          ],
        );
      },
    );
  }

  Widget buildCategoryListItem(String categoryName) {
    onCategoryPressed() async {
      // intent to edit or delete
      // true for edit, false for delete
      var isEdit = await getIntent(context, 'Category');
      bool hasNet = await InternetConnection().hasInternetAccess;

      // user cancelled
      if (isEdit == null) return;

      // user wants to delete
      if (isEdit == false && mounted) {
        var userChoice = await getUserConfirmation(context, 'Category');

        if (userChoice == null || userChoice == false) {
          return;
        }

        if (!mounted) return;

        EasyLoading.show(
            status: context.tr("delete_category_loading"),
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false);

        if (!hasNet) {
          ref
              .read(notebooksProvider.notifier)
              .deleteCategory(categoryName: categoryName);

          EasyLoading.dismiss();
          return;
        }

        var res = await ref
            .read(notebooksProvider.notifier)
            .deleteCategory(categoryName: categoryName);

        EasyLoading.dismiss();

        if (res is Failure) {
          logger.w(
              'Encountered an error while deleting category: ${res.message}');

          EasyLoading.showError(res.message);
          return;
        }

        EasyLoading.showSuccess(res);
      }

      // user wants to edit
      if (isEdit && mounted) {
        await showDialog(
            context: context,
            builder: (dialogContext) =>
                AddCategoryDialog(categoryName: categoryName));
      }

      _update('All');
      if (mounted) Navigator.pop(context);
    }

    return InkWell(
      onTap: () => {
        _update(categoryName),
        Navigator.pop(context),
      }, // Update state
      onLongPress: () {
        if (categoryName == 'All' || categoryName == 'Uncategorized') {
          _update(categoryName);
          Navigator.pop(context);
        } else {
          onCategoryPressed();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.label_outlined,
              size: 15,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(categoryName),
          ],
        ),
      ),
    );
  }
}
