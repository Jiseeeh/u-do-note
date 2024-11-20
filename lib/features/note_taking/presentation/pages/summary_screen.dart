import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SummaryScreen extends ConsumerWidget {
  final String topic;
  final String summary;

  const SummaryScreen({required this.topic, required this.summary, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (context.mounted) {
          context.router.back();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Summary'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: summary));

              EasyLoading.showSuccess('Copied to clipboard!');
            },
            child: const Icon(Icons.copy),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(
                    topic,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      summary,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
