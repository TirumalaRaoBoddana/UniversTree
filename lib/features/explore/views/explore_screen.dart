import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/post_model.dart';
import '../../../repositories/post_repository.dart';
import '../../../widgets/post_card.dart';
import '../../../widgets/app_loading_widget.dart';
import '../../../widgets/app_empty_state.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PostRepository _postRepository = MockPostRepository();
  bool _isLoading = true;
  List<PostModel> _globalPosts = [];

  @override
  void initState() {
    super.initState();
    _loadGlobalPosts();
  }

  Future<void> _loadGlobalPosts() async {
    setState(() => _isLoading = true);
    final posts = await _postRepository.getGlobalFeed();
    if (mounted) {
      setState(() {
        _globalPosts = posts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadGlobalPosts,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Banner Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.primaryDark, AppColors.backgroundDark]
                    : [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.borderLg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inter-College Hub 🌐',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        'Discover hackathons, symposiums, and achievements shared globally across colleges.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.horizontalMd,
                const Icon(
                  Icons.public_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          AppSpacing.verticalLg,

          Text(
            'Global Feeds & Announcements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),

          AppSpacing.verticalMd,

          if (_isLoading)
            const AppLoadingWidget(message: 'Loading global updates...')
          else if (_globalPosts.isEmpty)
            const AppEmptyState(
              icon: Icons.public_off_rounded,
              title: 'No Global Updates',
              description: 'Check back later for cross-college announcements.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _globalPosts.length,
              separatorBuilder: (_, __) => AppSpacing.verticalMd,
              itemBuilder: (context, index) {
                final post = _globalPosts[index];
                return PostCard(post: post);
              },
            ),
        ],
      ),
    );
  }
}
