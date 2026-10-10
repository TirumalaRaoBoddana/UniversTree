import 'package:flutter/material.dart';

class UniverstreeLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const UniverstreeLogo({
    super.key,
    this.size = 80.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F766E).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Stylized Tree / Network Icon representation using custom painter or icons
              Icon(
                Icons.account_tree_rounded,
                size: size * 0.55,
                color: Colors.white,
              ),
              Positioned(
                bottom: size * 0.18,
                child: Container(
                  width: size * 0.3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24), // Academic Gold accent
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'UNIVERSTREE',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Institutional Ecosystem',
            style: TextStyle(
              fontSize: size * 0.11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}