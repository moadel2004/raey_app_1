import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../cubit/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // القيم اللي بتتبعت للـ API: 'Farmer' | 'Veterinarian'
  String? _selectedRole;
  bool _obscurePassword = true;

  static const _roles = [
    ('مزارع / صاحب مواشي', 'Farmer'),
    ('دكتور بيطري', 'Veterinarian'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار نوع الحساب'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    context.read<AuthCubit>().register(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.go('/home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.createAccount,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سجل بياناتك عشان تنضم لعيلة ${AppStrings.appName}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 40),

                    // الاسم بالكامل
                    Text(
                      AppStrings.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'اكتب اسمك الثلاثي',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? AppStrings.requiredField : null,
                    ),
                    const SizedBox(height: 20),

                    // رقم التليفون
                    Text(
                      AppStrings.phoneNumber,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        hintText: '01012345678',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return AppStrings.requiredField;
                        if (!RegExp(r'^01[0-2,5]\d{8}$').hasMatch(v.trim())) {
                          return AppStrings.invalidPhone;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // كلمة السر
                    Text(
                      AppStrings.password,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.requiredField;
                        if (v.length < 6) return AppStrings.shortPassword;
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // نوع الحساب
                    Text(
                      'بتسجل بصفتك إيه؟',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _roles.map((pair) {
                        final (label, value) = pair;
                        final selected = _selectedRole == value;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedRole = value),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primarySurface
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      value == 'Farmer'
                                          ? Icons.agriculture_outlined
                                          : Icons.medical_services_outlined,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textLight,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // زرار التسجيل
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _submit(context),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(AppStrings.register),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // رابط تسجيل الدخول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.hasAccount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            AppStrings.signIn,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
