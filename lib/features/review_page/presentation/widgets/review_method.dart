import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewMethod extends ConsumerWidget {
  final String title;
  final String description;
  final String imagePath;
  final Function() onPressed;
  const ReviewMethod(
      {super.key,
      required this.title,
      required this.description,
      required this.imagePath,
      required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xffeaf2ff),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        // TODO: use theme
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      // TODO: use theme
                      Text(
                        description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  )),
                  TextButton(
                    onPressed: onPressed,
                    style: ButtonStyle(
                        // lessen the border radius
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xff006ffd))),
                    // TODO: use theme
                    child: const Text('Start',
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
          // ?IDK WHY THIS WORKS, BUT IT DOES. I'M NOT GONNA QUESTION IT
          // ?MONKEY PATCHING FTW
          Container(
              width: 130,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
                child: Image(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              )),
        ],
      ),
    );
  }
}
