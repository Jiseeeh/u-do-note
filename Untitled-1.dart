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
          ],
        ),
      ),