import 'package:flutter/material.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/event_model.dart';
import '../../../models/tenant_context.dart';
import '../../../repositories/event_repository.dart';
import '../../../widgets/event_card.dart';
import '../../../widgets/app_loading_widget.dart';
import '../../../widgets/app_empty_state.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventRepository _eventRepository = MockEventRepository();
  final TenantContext _tenant = TenantContext.empty();

  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await _eventRepository.getEvents(_tenant, category: _selectedCategory);
    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRsvpToggle(String eventId) async {
    await _eventRepository.toggleRsvp(eventId);
    _loadEvents();
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Filter Bar
        Container(
          height: 48,
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.eventCategories.length,
            separatorBuilder: (_, __) => AppSpacing.horizontalSm,
            itemBuilder: (context, index) {
              final cat = AppConstants.eventCategories[index];
              final isSelected = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => _onCategorySelected(cat),
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
          child: RefreshIndicator(
            onRefresh: _loadEvents,
            child: _isLoading
                ? const AppLoadingWidget(message: 'Loading campus events...')
                : _events.isEmpty
                    ? AppEmptyState(
                        icon: Icons.event_busy_rounded,
                        title: 'No Events Scheduled',
                        description: 'No events found under "$_selectedCategory".',
                        actionLabel: 'Show All Events',
                        onAction: () => _onCategorySelected('All'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _events.length,
                        separatorBuilder: (_, __) => AppSpacing.verticalMd,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return EventCard(
                            event: event,
                            onRsvpToggle: () => _onRsvpToggle(event.id),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
