import 'package:flutter/material.dart';

class BackButtonHeader extends StatelessWidget {
  final VoidCallback onBack;
  const BackButtonHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8080),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
              shape: const CircleBorder(),
            ),
            child: const Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }
}
