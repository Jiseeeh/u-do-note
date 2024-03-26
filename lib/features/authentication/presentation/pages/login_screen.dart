import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 0, 20, 41),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 80,
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Welcome Back",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 237, 237, 237),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                        padding: const EdgeInsets.only(top:50),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 60,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                           ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                textAlign: TextAlign.left,
                                "Email Address",
                                style: TextStyle(fontSize: 18,),
                              ),
                              AuthField(
                                label: 'Email',
                                controller: emailController,
                                isObscuredText: false,
                                keyboardType: TextInputType.emailAddress,
                                validator: emailValidator,
                              ),
                              const Text(
                                textAlign: TextAlign.left,
                                "Password",
                                style: TextStyle(fontSize: 18,),
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
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final userProvider = ref.read(userNotifierProvider.notifier);

                  EasyLoading.show(
                      status: 'Logging you in...',
                      maskType: EasyLoadingMaskType.black,
                      dismissOnTap: false);

                  final userOrFailure = await userProvider.signInWithEAP(
                      emailController.text, passwordController.text);

                  EasyLoading.dismiss();

                  userOrFailure
                      .fold((failure) => EasyLoading.showError(failure.message),
                          (userModel) {
                    EasyLoading.showSuccess('Login success!');

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
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      MaterialButton(
                        onPressed: () {},
                        height: 50,
                        // margin: EdgeInsets.symmetric(horizontal: 50),
                        color: Colors.orange[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        // decoration: BoxDecoration(
                        // ),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Inter"),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        "Continue with social media",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: MaterialButton(
                            onPressed: () {},
                            height: 50,
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Center(
                              child: Text(
                                "Facebook",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                          const SizedBox(
                            width: 30,
                          ),
                          Expanded(
                              child: MaterialButton(
                            onPressed: () {},
                            height: 50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            color: Colors.black,
                            child: const Center(
                              child: Text(
                                "Github",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
