import 'package:flutter/material.dart';

class AuthButtonGroup extends StatelessWidget {
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final VoidCallback? onTwitter;
  final bool isLoading;
  final String label;

  const AuthButtonGroup({super.key, required this.onGoogle, required this.onApple, required this.onTwitter, this.isLoading = false, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 12),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(label, style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AuthIcon(icon: Icons.g_mobiledata, label: 'Google', onTap: isLoading ? null : onGoogle),
                  const SizedBox(width: 16),
                  _AuthIcon(icon: Icons.apple, label: 'Apple', onTap: isLoading ? null : onApple),
                  const SizedBox(width: 16),
                  _AuthIcon(icon: Icons.alternate_email, label: 'Twitter', onTap: isLoading ? null : onTwitter),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _AuthIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _AuthIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon, size: 36), splashRadius: 24),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
