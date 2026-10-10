import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final double maxWidth;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.maxWidth = 720.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              child: body,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar != null
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: bottomNavigationBar,
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
    );
  }
}
