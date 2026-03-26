import 'package:flutter/material.dart';

class LanguageSwitcher extends StatelessWidget {
  final Locale value;
  final ValueChanged<Locale> onChanged;

  const LanguageSwitcher({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(value: Locale('ru'), child: Text('Русский')),
        PopupMenuItem(value: Locale('en'), child: Text('English')),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            value.languageCode.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
