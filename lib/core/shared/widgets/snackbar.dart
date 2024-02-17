import 'package:flutter/material.dart';

// TODO: can be improved or just use a package for snackbars
// TODO: move this folder `widgets` to `shared/presentation/`

SnackBar createSnackbar(String message) {
  return SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
  );
}
