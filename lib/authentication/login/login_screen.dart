import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dialog_utils.dart';
import '../../methods/common_methods.dart';
import '../../theme/theme.dart';
import '../component/custom_text_form_field.dart';
import '../register/register_screen.dart';
import 'login_navigator.dart';
import 'login_screen_view_model.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements LoginNavigator {
  bool isObscure = true;
  LoginScreenViewModel viewModelLogin = LoginScreenViewModel();
  CommonMethods cMethods = CommonMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewModelLogin.navigator = this;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModelLogin,
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: MyTheme.redColor,
          title: Text('Ambulance App',
              style: TextStyle(color: MyTheme.whiteColor)),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/ambulance_icon.png'),
                  radius: 60,
                  backgroundColor: MyTheme.redColor,
                ),
              ),
              Form(
                  key: viewModelLogin.formKey,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        CustomTextFormField(
                            prefixIcon: Icon(Icons.email_rounded,
                                color: MyTheme.redColor),
                            label: 'Email address',
                            keyboardType: TextInputType.emailAddress,
                            controller: viewModelLogin.emailController,
                            validator: (text) {
                              if (text == null || text.trim().isEmpty) {
                                return 'Please Enter an Email';
                              }
                              bool emailValid = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(text);
                              if (!emailValid) {
                                return 'Please Enter Valid Email';
                              }
                              return null;
                            }),
                        CustomTextFormField(
                            prefixIcon:
                                Icon(Icons.lock, color: MyTheme.redColor),
                            label: 'Password',
                            isPassword: isObscure,
                            keyboardType: TextInputType.number,
                            controller: viewModelLogin.passwordController,
                            validator: (text) {
                              if (text == null || text.trim().isEmpty) {
                                return 'Please Enter a Password';
                              }
                              if (text.length < 6) {
                                return 'Password should be at least 6 characters';
                              }
                              if (text !=
                                  viewModelLogin.passwordController.text) {
                                return "password doesn't match";
                              }
                              return null;
                            }),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              viewModelLogin.login(context);
                            },
                            child: Text('Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: MyTheme.redColor,
                                padding: EdgeInsets.symmetric(vertical: 10)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500)),
                            TextButton(
                                onPressed: () {
                                  // navigate to register screen
                                  Navigator.of(context).pushReplacementNamed(
                                      RegisterScreen.routeName);
                                },
                                child: Text('Sign Up',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: MyTheme.redColor,
                                        fontWeight: FontWeight.w600)))
                          ],
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void hideMyLoading() {
    // TODO: implement hideMyLoading
    DialogUtils.hideLoading(context);
  }

  @override
  void showMyLoading() {
    // TODO: implement showMyLoading
    DialogUtils.showLoading(context, 'Loading...');
  }

  @override
  void showMessage(String message) {
    // TODO: implement showMessage
    DialogUtils.showMessage(
      context,
      message,
      posActionName: 'ok',
      title: 'Sign-In',
      barrierDismissible: false,
      posAction: () {
        // h3ml navigate ll home screen
      },
    );
  }
}
