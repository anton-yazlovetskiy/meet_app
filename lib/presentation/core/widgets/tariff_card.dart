import 'package:flutter/material.dart';

class TariffCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final List<String> features;
  final bool isPhysical;

  const TariffCard({super.key, required this.title, required this.description, required this.price, required this.features, this.isPhysical = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 180),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 6),
                      Expanded(child: Text(feature, style: const TextStyle(fontSize: 10))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
