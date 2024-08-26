import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class MultiSelect<T extends Object> extends ConsumerWidget {
  final List<DropdownItem<T>> items;
  final MultiSelectController<T>? controller;
  final bool singleSelect;
  final String hintText;
  final String title;
  final String? subTitle;
  final String validationText;
  final IconData prefixIcon;
  final GlobalKey<FormFieldState<dynamic>>? customKey;
  final void Function(List<T>)? onSelectionChanged;

  const MultiSelect({required this.items,
    required this.hintText,
      required this.title,
      required this.validationText,
      required this.prefixIcon,
      this.controller,
      this.subTitle,
      this.singleSelect = false,
      this.customKey,
      this.onSelectionChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MultiDropdown<T>(
      key: customKey,
      items: items,
      controller: controller,
      enabled: true,
      singleSelect: singleSelect,
      onSelectionChange: onSelectionChanged,
      fieldDecoration: FieldDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black87),
        prefixIcon: Icon(prefixIcon),
        showClearIcon: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.black87,
          ),
        ),
      ),
      dropdownDecoration: DropdownDecoration(
        marginTop: 2,
        maxHeight: 500,
        header: Padding(
          padding: const EdgeInsets.all(8),
          child: RichText(
            text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                text: context.tr(title),
                children: [
                  subTitle != null
                      ? const TextSpan(text: "\n")
                      : const TextSpan(text: ""),
                  subTitle != null
                      ? TextSpan(
                          text: context.tr(subTitle!),
                          style: Theme.of(context).textTheme.bodySmall)
                      : const TextSpan(text: ""),
                ]),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationText;
        }
        return null;
      },
    );
  }
}
