import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';

import 'package:u_do_note/core/shared/widgets/snackbar.dart';
import 'package:u_do_note/features/authentication/presentation/providers/user_provider.dart';
import '../widgets/auth_field.dart';

@RoutePage()
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final TextEditingController displayNameController = TextEditingController();

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }

    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? displayNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }

    if (value.length < 9) {
      return 'Password must be at least 9 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    return null;
  }

  String? repeatPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  bool isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = ref.read(userNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            AuthField(
              label: 'Email',
              controller: emailController,
              isObscuredText: false,
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
            ),
            AuthField(
              label: 'Display Name',
              controller: displayNameController,
              isObscuredText: false,
              keyboardType: TextInputType.text,
              validator: displayNameValidator,
            ),
            AuthField(
              label: 'Password',
              controller: passwordController,
              isObscuredText: isPasswordObscured,
              keyboardType: TextInputType.text,
              validator: passwordValidator,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    isPasswordObscured = !isPasswordObscured;
                  });
                },
                child: Icon(isPasswordObscured
                    ? Icons.visibility
                    : Icons.visibility_off),
              ),
            ),
            AuthField(
              label: 'Repeat Password',
              controller: repeatPasswordController,
              isObscuredText: isPasswordObscured,
              keyboardType: TextInputType.text,
              validator: repeatPasswordValidator,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    isPasswordObscured = !isPasswordObscured;
                  });
                },
                child: Icon(isPasswordObscured
                    ? Icons.visibility
                    : Icons.visibility_off),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  EasyLoading.show(
                      status: 'Signing you up...',
                      maskType: EasyLoadingMaskType.black,
                      dismissOnTap: false);

                  final userOrFailure = await userProvider.signUpWithEAP(
                      emailController.text,
                      displayNameController.text,
                      passwordController.text);

                  EasyLoading.dismiss();

                  userOrFailure.fold((failure) {
                    var failureSnackbar = createSnackbar(failure.message);

                    ScaffoldMessenger.of(context).showSnackBar(failureSnackbar);
                  },
                      (userModel) => {
                            EasyLoading.showSuccess('Sign up success!'),
                            context.router.replaceNamed('/login'),
                          });
                }
              },
              child: const Text('Sign Up'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () {
                    context.router.replaceNamed('/login');
                  },
                  child: const Text('Log In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
