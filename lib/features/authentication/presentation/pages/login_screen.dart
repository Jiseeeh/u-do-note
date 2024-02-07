import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/features/authentication/presentation/providers/user_provider.dart';

import '../widgets/auth_field.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginState();
}

class _LoginState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  String? emailValidator(String? value) {
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

  bool isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final userProvider = ref.read(userNotifierProvider.notifier);

                  final userOrFailure = await userProvider.signInWithEAP(
                      emailController.text, passwordController.text);

                  userOrFailure.fold((failure) => print("THERE IS ERROR"),
                      (userModel) {
                    context.router.replaceNamed('/home');
                  });
                }
              },
              child: const Text('Login'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                TextButton(
                  onPressed: () {
                    context.router.replaceNamed('/sign-up');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
