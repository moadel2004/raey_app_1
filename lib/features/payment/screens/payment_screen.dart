import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/payment_info.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, this.amount});

  final double? amount;

  // ── helpers ───────────────────────────────────────────────────────────────

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok  = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(AppStrings.paymentLaunchError,
            style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(AppStrings.paymentCopied,
          style: TextStyle(fontFamily: 'Cairo')),
      duration: Duration(seconds: 2),
      backgroundColor: AppColors.success,
    ));
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.paymentTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          // ── Amount banner ────────────────────────────────────────────────
          if (amount != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    AppStrings.paymentAmount,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${amount!.toStringAsFixed(0)} ج',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── InstaPay card ────────────────────────────────────────────────
          _PayCard(
            title: 'InstaPay',
            icon: Icons.qr_code_2_outlined,
            child: Column(
              children: [
                const Text(
                  AppStrings.paymentScanQr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 12),
                // White background so QR is readable on any theme
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: QrImageView(
                    data: PaymentInfo.instapayLink,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // IPA row
                _CopyRow(
                  value: PaymentInfo.instapayIpa,
                  onCopy: () => _copy(context, PaymentInfo.instapayIpa),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  label: AppStrings.paymentInstapay,
                  onPressed: () =>
                      _launch(context, PaymentInfo.instapayLink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Vodafone Cash card ───────────────────────────────────────────
          _PayCard(
            title: AppStrings.paymentVodafone,
            icon: Icons.phone_android_outlined,
            child: Column(
              children: [
                Text(
                  PaymentInfo.vodafoneCash,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.paymentVodafoneHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 12),
                _CopyRow(
                  value: PaymentInfo.vodafoneCash,
                  onCopy: () => _copy(context, PaymentInfo.vodafoneCash),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Confirmation card ────────────────────────────────────────────
          _PayCard(
            title: AppStrings.paymentConfirmTitle,
            icon: Icons.verified_outlined,
            iconColor: Colors.green.shade700,
            child: Column(
              children: [
                const Text(
                  AppStrings.paymentWhatsappNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textMedium,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: AppStrings.paymentWhatsappBtn,
                  onPressed: () {
                    final msg = Uri.encodeComponent(
                        'السلام عليكم، حابب أأكّد دفع الاستشارة');
                    _launch(
                      context,
                      'https://wa.me/${PaymentInfo.whatsappNumber}?text=$msg',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable card shell ───────────────────────────────────────────────────────

class _PayCard extends StatelessWidget {
  const _PayCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor = AppColors.primary,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Copy row (value + copy button) ───────────────────────────────────────────

class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.value, required this.onCopy});

  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onCopy,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.copy_outlined, size: 16,
                color: AppColors.primary),
            label: const Text(
              AppStrings.paymentCopy,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
