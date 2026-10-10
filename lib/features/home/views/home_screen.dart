import 'package:flutter/material.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/post_model.dart';
import '../../../models/tenant_context.dart';
import '../../../repositories/post_repository.dart';
import '../../../widgets/post_card.dart';
import '../../../widgets/app_loading_widget.dart';
import '../../../widgets/app_empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostRepository _postRepository = MockPostRepository();
  final TenantContext _tenant = TenantContext.empty();

  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<PostModel> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    final posts = await _postRepository.getCampusFeed(_tenant, category: _selectedCategory);
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadFeed();
  }

  Future<void> _onLikeToggle(String postId) async {
    await _postRepository.toggleLikePost(postId);
    _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Category Filter Bar
        Container(
          height: 48,
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.postCategories.length,
            separatorBuilder: (_, __) => AppSpacing.horizontalSm,
            itemBuilder: (context, index) {
              final cat = AppConstants.postCategories[index];
              final isSelected = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => _onCategorySelected(cat),
                selectedColor: AppColors.primary,
                backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderPill,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        // Main Campus Feed Area
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFeed,
            child: _isLoading
                ? const AppLoadingWidget(message: 'Loading campus feed...')
                : _posts.isEmpty
                    ? AppEmptyState(
                        icon: Icons.article_outlined,
                        title: 'No Posts Found',
                        description:
                            'There are no posts under "$_selectedCategory" for ${_tenant.collegeShortName} yet.',
                        actionLabel: 'Reset Category',
                        onAction: () => _onCategorySelected('All'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _posts.length,
                        separatorBuilder: (_, __) => AppSpacing.verticalMd,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return PostCard(
                            post: post,
                            onLikeToggle: () => _onLikeToggle(post.id),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
