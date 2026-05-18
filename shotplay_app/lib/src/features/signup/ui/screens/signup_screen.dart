import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/signup/ui/bloc/signup_bloc.dart';
import 'package:shotplay_app/src/features/signup/ui/sections/signup_footer.dart';
import 'package:shotplay_app/src/features/signup/ui/sections/signup_form_section.dart';
import 'package:shotplay_app/src/features/signup/ui/sections/signup_header.dart';
import 'package:shotplay_app/src/features/signup/ui/widgets/signup_background.dart';
import 'package:shotplay_app/src/features/signup/ui/widgets/signup_terms_notice.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  DateTime? _birthdate;
  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passController.dispose();
    birthdateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$mm / $dd / $yyyy';
  }

  String _formatBirthdateIso(DateTime date) {
    return date.toIso8601String();
  }

  bool _isAdult(DateTime date) {
    final today = DateTime.now();
    final adultDate = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );
    return !date.isAfter(adultDate);
  }

  Future<void> _pickBirthdate() async {
    final today = DateTime.now();
    final initial = _birthdate ?? DateTime(today.year - 18, today.month, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked != null) {
      setState(() {
        _birthdate = picked;
        birthdateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso. Inicia sesion.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is SignupFailState) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF16111C),
        body: SignupBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 80,
                        left: 24,
                        right: 24,
                        bottom: 48,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SignupHeader(),
                              const SizedBox(height: 40),
                              BlocBuilder<SignupBloc, SignupState>(
                                builder: (context, state) {
                                  final loading = state is SignupLoadingState;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SignupFormSection(
                                        usernameController: usernameController,
                                        emailController: emailController,
                                        passwordController: passController,
                                        birthdateController: birthdateController,
                                        isPasswordObscured: _obscurePassword,
                                        onTogglePassword: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                        onPickBirthdate: _pickBirthdate,
                                        usernameValidator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El username es obligatorio.';
                                          }
                                          return null;
                                        },
                                        emailValidator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'El correo es obligatorio.';
                                          }
                                          final email = value.trim();
                                          final emailRegex = RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                          );
                                          if (!emailRegex.hasMatch(email)) {
                                            return 'El correo no es valido.';
                                          }
                                          return null;
                                        },
                                        passwordValidator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'La contrasena es obligatoria.';
                                          }
                                          if (value.length < 8) {
                                            return 'Minimo 8 caracteres.';
                                          }
                                          return null;
                                        },
                                        birthdateValidator: (_) {
                                          if (_birthdate == null) {
                                            return 'La fecha de nacimiento es obligatoria.';
                                          }
                                          if (!_isAdult(_birthdate!)) {
                                            return 'Debes ser mayor de 18 anos.';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      SignupFooter(
                                        isLoading: loading,
                                        onSubmit: () {
                                          final form = _formKey.currentState;
                                          if (form == null || !form.validate()) {
                                            return;
                                          }
                                          if (_birthdate == null) {
                                            return;
                                          }
                                          context.read<SignupBloc>().add(
                                                SignupSubmitEvent(
                                                  username: usernameController.text,
                                                  email: emailController.text,
                                                  password: passController.text,
                                                  birthdateIso:
                                                      _formatBirthdateIso(_birthdate!),
                                                ),
                                              );
                                        },
                                        onLoginTap: () {
                                          Navigator.pushNamed(context, '/login');
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      const Center(child: SignupTermsNotice()),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
