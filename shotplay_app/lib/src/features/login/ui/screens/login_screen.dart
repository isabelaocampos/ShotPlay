import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/login/ui/bloc/login_bloc.dart';
import 'package:shotplay_app/src/core/routing/app_routes.dart';
import 'package:shotplay_app/src/features/login/ui/sections/login_footer.dart';
import 'package:shotplay_app/src/features/login/ui/sections/login_form_section.dart';
import 'package:shotplay_app/src/features/login/ui/sections/login_header.dart';
import 'package:shotplay_app/src/features/login/ui/sections/login_social_section.dart';
import 'package:shotplay_app/src/features/login/ui/widgets/login_background.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          Navigator.pushReplacementNamed(context, AppRoutes.enterCode);
        } else if (state is LoginFailState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF16111C),
        body: LoginBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 884),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 85),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const LoginHeader(),
                        const SizedBox(height: 40),
                        BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            final isLoading = state is LoginLoadingState;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LoginFormSection(
                                  emailController: emailController,
                                  passwordController: passController,
                                  isLoading: isLoading,
                                  onSubmit: () {
                                    context.read<LoginBloc>().add(
                                          LoginSubmitEvent(
                                            email: emailController.text,
                                            password: passController.text,
                                          ),
                                        );
                                  },
                                  onForgotPassword: () {},
                                ),
                                const SizedBox(height: 24),
                                LoginSocialSection(
                                  onGoogle: () {},
                                  onDiscord: () {},
                                ),
                                const SizedBox(height: 16),
                                LoginFooter(
                                  onCreateAccount: () {
                                    Navigator.pushNamed(context, '/signup');
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
