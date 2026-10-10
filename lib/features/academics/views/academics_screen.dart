import 'package:flutter/material.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/resource_model.dart';
import '../../../models/doubt_model.dart';
import '../../../models/tenant_context.dart';
import '../../../repositories/academic_repository.dart';
import '../../../widgets/resource_card.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_loading_widget.dart';
import '../../../widgets/app_empty_state.dart';

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({super.key});

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AcademicRepository _repository = MockAcademicRepository();
  final TenantContext _tenant = TenantContext.empty();

  String _selectedResourceType = 'All';
  bool _isLoading = true;
  List<ResourceModel> _resources = [];
  List<DoubtModel> _doubts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final resources = await _repository.getResources(
      _tenant,
      type: _selectedResourceType,
    );
    final doubts = await _repository.getDoubts(_tenant);

    if (mounted) {
      setState(() {
        _resources = resources;
        _doubts = doubts;
        _isLoading = false;
      });
    }
  }

  void _onResourceTypeSelected(String type) {
    setState(() => _selectedResourceType = type);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Top Tab Bar (Study Resources vs Academic Doubts)
        Container(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Study Resources & PYQs'),
              Tab(text: 'Academic Doubts (Q&A)'),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Study Resources
              Column(
                children: [
                  // Filter bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.academicTypes.length,
                      separatorBuilder: (_, __) => AppSpacing.horizontalSm,
                      itemBuilder: (context, index) {
                        final type = AppConstants.academicTypes[index];
                        final isSelected = type == _selectedResourceType;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (_) => _onResourceTypeSelected(type),
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: _isLoading
                        ? const AppLoadingWidget(message: 'Loading academic resources...')
                        : _resources.isEmpty
                            ? AppEmptyState(
                                icon: Icons.folder_open_rounded,
                                title: 'No Resources Found',
                                description: 'No study materials found under "$_selectedResourceType".',
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: _resources.length,
                                separatorBuilder: (_, __) => AppSpacing.verticalMd,
                                itemBuilder: (context, index) {
                                  return ResourceCard(resource: _resources[index]);
                                },
                              ),
                  ),
                ],
              ),

              // Tab 2: Doubts
              _isLoading
                  ? const AppLoadingWidget(message: 'Loading doubts...')
                  : _doubts.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.quiz_outlined,
                          title: 'No Doubts Posted',
                          description: 'Be the first to ask an academic question.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: _doubts.length,
                          separatorBuilder: (_, __) => AppSpacing.verticalMd,
                          itemBuilder: (context, index) {
                            final doubt = _doubts[index];
                            return AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: doubt.isResolved
                                              ? AppColors.success.withValues(alpha: 0.1)
                                              : AppColors.warning.withValues(alpha: 0.1),
                                          borderRadius: AppRadius.borderSm,
                                        ),
                                        child: Text(
                                          doubt.isResolved ? 'RESOLVED' : 'OPEN',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: doubt.isResolved ? AppColors.success : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                      AppSpacing.horizontalSm,
                                      Text(
                                        doubt.department,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.verticalSm,
                                  Text(
                                    doubt.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  AppSpacing.verticalXs,
                                  Text(
                                    doubt.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  AppSpacing.verticalSm,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'By ${doubt.authorName}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                        ),
                                      ),
                                      Text(
                                        '${doubt.answerCount} Answers',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ],
    );
  }
}
