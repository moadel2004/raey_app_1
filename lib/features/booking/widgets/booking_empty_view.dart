import 'package:flutter/material.dart';

class BookingEmptyView extends StatelessWidget {
  const BookingEmptyView({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
    this.showRetry = false,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final bool showRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontFamily: 'Cairo',
              ),
            ),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('حاول تاني'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
