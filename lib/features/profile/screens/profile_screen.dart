import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('حسابي')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileLoaded) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primarySurface,
                  child: Icon(Icons.person, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    user.displayRole,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoTile(Icons.phone, 'رقم التليفون', user.phone),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<ProfileCubit>().signOut();
                    if (context.mounted) context.go(AppRoutes.onboarding);
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(color: AppColors.error, fontFamily: 'Cairo'),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontFamily: 'Cairo')),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
            ],
          ),
        ],
      ),
    );
  }
}
