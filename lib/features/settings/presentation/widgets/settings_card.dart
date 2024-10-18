import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/routes/app_route.dart';

class SettingsCard extends ConsumerWidget {
  final String title;
  final IconData icon;
  // final Function() onPressed;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    // required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(15, 12, 10, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  context.router.push(const ThemeSettingsRoute());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
