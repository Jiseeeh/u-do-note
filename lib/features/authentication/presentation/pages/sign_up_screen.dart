import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/theme/text_styles.dart';
import 'package:u_do_note/core/shared/presentation/widgets/snackbar.dart';
import 'package:u_do_note/features/authentication/presentation/providers/user_provider.dart';
import 'package:u_do_note/features/authentication/presentation/widgets/social_icon.dart';
import 'package:u_do_note/features/authentication/presentation/widgets/auth_field.dart';

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

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#\$&*~]'))) {
      return 'Password must contain at least one special character (e.g., !, @, #, \$, &, *, ~)';
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
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: AppColors.secondary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Align(
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage('assets/images/register-accent.png'),
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.darkSecondaryText,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "Create New Account",
                        style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 18,
                            fontFamily: 'Inter-Bold',
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryText.withOpacity(.5),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: const Offset(
                                0, -3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      final GoogleSignIn googleSignIn =
                                          GoogleSignIn();

                                      final GoogleSignInAccount? googleUser =
                                          await googleSignIn.signIn();

                                      final GoogleSignInAuthentication?
                                          googleAuth =
                                          await googleUser?.authentication;

                                      final AuthCredential credential =
                                          GoogleAuthProvider.credential(
                                        accessToken: googleAuth!.accessToken,
                                        idToken: googleAuth.idToken,
                                      );

                                      await FirebaseAuth.instance
                                          .signInWithCredential(credential);

                                      if (!context.mounted) return;

                                      context.router.replaceNamed('/home');
                                    } catch (e) {
                                      EasyLoading.showToast(
                                          "Error signing in with Google, please try again later",
                                          duration: const Duration(seconds: 2),
                                          toastPosition:
                                              EasyLoadingToastPosition.bottom);
                                    }
                                  },
                                  child: const SocialIcon(
                                    src: "assets/google.svg",
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Email Address",
                                            textAlign: TextAlign.left,
                                            style: AppTextStyles.h5.copyWith(
                                                color: AppColors.primaryText),
                                          )),
                                      AuthField(
                                        label: 'juandelacruz@example.com',
                                        controller: emailController,
                                        isObscuredText: false,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: emailValidator,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Display Name",
                                          textAlign: TextAlign.left,
                                          style: AppTextStyles.h5.copyWith(
                                              color: AppColors.primaryText),
                                        ),
                                      ),
                                      AuthField(
                                        label: 'Juan dela Cruz',
                                        controller: displayNameController,
                                        isObscuredText: false,
                                        keyboardType: TextInputType.text,
                                        validator: displayNameValidator,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Password",
                                          textAlign: TextAlign.left,
                                          style: AppTextStyles.h5.copyWith(
                                              color: AppColors.primaryText),
                                        ),
                                      ),
                                      AuthField(
                                        label: '*********',
                                        controller: passwordController,
                                        isObscuredText: isPasswordObscured,
                                        keyboardType: TextInputType.text,
                                        validator: passwordValidator,
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isPasswordObscured =
                                                  !isPasswordObscured;
                                            });
                                          },
                                          child: Icon(isPasswordObscured
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Repeat Password",
                                          textAlign: TextAlign.left,
                                          style: AppTextStyles.h5.copyWith(
                                              color: AppColors.primaryText),
                                        ),
                                      ),
                                      AuthField(
                                        label: '********',
                                        controller: repeatPasswordController,
                                        isObscuredText: isPasswordObscured,
                                        keyboardType: TextInputType.text,
                                        validator: repeatPasswordValidator,
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isPasswordObscured =
                                                  !isPasswordObscured;
                                            });
                                          },
                                          child: Icon(isPasswordObscured
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      MaterialButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            EasyLoading.show(
                                                status: 'Signing you up...',
                                                maskType:
                                                    EasyLoadingMaskType.black,
                                                dismissOnTap: false);

                                            final userOrFailure =
                                                await userProvider
                                                    .signUpWithEAP(
                                                        emailController.text,
                                                        displayNameController
                                                            .text,
                                                        passwordController
                                                            .text);

                                            EasyLoading.dismiss();

                                            userOrFailure.fold((failure) {
                                              var failureSnackbar =
                                                  createSnackbar(
                                                      failure.message);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                      failureSnackbar);
                                            },
                                                (userModel) => {
                                                      EasyLoading.showSuccess(
                                                          'Sign up success!'),
                                                      context.router
                                                          .replaceNamed(
                                                              '/login'),
                                                    });
                                          }
                                        },
                                        height: 50,
                                        color: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "REGISTER",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Already Have an Account?',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                )),
                                            TextButton(
                                              onPressed: () {
                                                context.router
                                                    .replaceNamed('/login');
                                              },
                                              child: const Text(
                                                'Login here',
                                                style: TextStyle(
                                                    color: AppColors.secondary,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      // ],
      // ),
    );
  }
}
