import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';

class MultiSelect<T> extends ConsumerWidget {
  final List<T> initialItems;
  final String title;
  final String subTitle;
  final List<MultiSelectItem<T>> items;
  final IconData buttonIcon;
  final String? buttonText;
  final GlobalKey<FormFieldState<dynamic>>? customKey;
  final void Function(List<T>) onConfirm;
  final void Function(List<T>)? onSelectionChanged;

  const MultiSelect(
      {required this.initialItems,
      required this.title,
      required this.subTitle,
      required this.items,
      required this.buttonIcon,
      required this.onConfirm,
      this.buttonText,
      this.customKey,
      this.onSelectionChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MultiSelectDialogField(
      key: customKey,
      initialValue: initialItems,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr(title)),
          Text(
            context.tr(subTitle),
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
      items: items,
      selectedItemsTextStyle: const TextStyle(color: AppColors.white),
      selectedColor: AppColors.secondary,
      listType: MultiSelectListType.CHIP,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      onSelectionChanged: onSelectionChanged,
      onConfirm: onConfirm,
      buttonIcon: Icon(
        buttonIcon,
        color: AppColors.secondary,
      ),
      buttonText: Text(
        buttonText ?? title,
      ),
    );
  }
}
