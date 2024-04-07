import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/features/authentication/presentation/providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      body: SingleChildScrollView(
        child: Container(
          // width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xff001429)),
          // child:
          // CustomScrollView(
          //   slivers: [
          //     SliverFillRemaining(
          //       hasScrollBody: false,
          //       fillOverscroll: false,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 70),
              const Align(
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage('lib/assets/images/login-accent.png'),
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 238, 238, 238),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35))),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Login to your account",
                        style: TextStyle(
                            color: Color.fromARGB(255, 112, 117, 125),
                            fontSize: 18,
                            fontFamily: 'Inter-Bold',
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xffFFFFFF),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(100, 204, 204, 204),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, -3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              115, 197, 197, 197)),
                                      shape: BoxShape.circle),
                                  child: SvgPicture.asset(
                                    "assets/f.svg",
                                    height: 30,
                                    width: 30,
                                    // ignore: deprecated_member_use
                                    color: const Color(0xff4E8EFF),
                                  ),
                                ),
                                const SocialIcon(
                                  src: "assets/google.svg",
                                ),
                                const SocialIcon(
                                  src: "assets/twitter.svg",
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Email Address",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      AuthField(
                                        label: 'Email Address',
                                        controller: emailController,
                                        isObscuredText: false,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: emailValidator,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Password",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
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
                                              isPasswordObscured =
                                                  !isPasswordObscured;
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
                                const SizedBox(
                                  height: 5,
                                ),
                                const Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "Forgot Password?",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(color: Color(0xff266EF1)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                MaterialButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final userProvider = ref
                                          .read(userNotifierProvider.notifier);

                                      EasyLoading.show(
                                          status: 'Logging you in...',
                                          maskType: EasyLoadingMaskType.black,
                                          dismissOnTap: false);

                                      final userOrFailure =
                                          await userProvider.signInWithEAP(
                                              emailController.text,
                                              passwordController.text);

                                      EasyLoading.dismiss();

                                      userOrFailure.fold(
                                          (failure) => EasyLoading.showError(
                                              failure.message), (userModel) {
                                        EasyLoading.showSuccess(
                                            'Login success!');

                                        context.router.replaceNamed('/home');
                                      });
                                    }
                                  },
                                  height: 50,
                                  // margin: EdgeInsets.symmetric(horizontal: 50),
                                  color: const Color(0xff001429),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  // decoration: BoxDecoration(
                                  // ),
                                  child: const Center(
                                    child: Text(
                                      "LOGIN",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Don\'t have an account?'),
                                    TextButton(
                                      onPressed: () {
                                        context.router.replaceNamed('/sign-up');
                                      },
                                      child: const Text(
                                        'Register here',
                                        style: TextStyle(
                                            color: Color(0xff266EF1),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // ],
    );
    // ));
  }
}

class SocialIcon extends StatelessWidget {
  final String src;
  // final Function press;
  const SocialIcon({super.key, required this.src});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(
              width: 1, color: const Color.fromARGB(115, 197, 197, 197)),
          shape: BoxShape.circle),
      child: SvgPicture.asset(
        src,
        height: 30,
        width: 30,
      ),
    );
  }
}
