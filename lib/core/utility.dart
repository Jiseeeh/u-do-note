import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomDialog {
  static Future<T> show<T>(
    BuildContext context, {
    required String title,
    required String subTitle,
    Widget? content,
    List<CustomDialogButton<T>>? buttons,
  }) async {
    final result = await showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          scrollable: true,
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
          content: content,
          actions: [
            if (buttons != null)
              for (final button in buttons)
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(button.value);

                    button.onPressed?.call();
                  },
                  child: Text(context.tr(button.text)),
                ),
          ],
        );
      },
    );
    return Future.value(result);
  }
}

class CustomDialogButton<T> {
  final String text;
  final T? value;
  final VoidCallback? onPressed;

  CustomDialogButton({required this.text, this.value, this.onPressed});
}
