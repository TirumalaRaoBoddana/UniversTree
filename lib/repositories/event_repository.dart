import '../models/event_model.dart';
import '../models/tenant_context.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents(TenantContext tenant, {String? category});
  Future<void> toggleRsvp(String eventId);
}

class MockEventRepository implements EventRepository {
  final List<EventModel> _events = [];

  MockEventRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _events.addAll([
      EventModel(
        id: 'evt_1',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        organizerName: 'Computer Society of India - CEG',
        organizerType: 'club',
        title: 'Machine Learning Workshop: Vision Transformers',
        description:
            'A hands-on workshop covering state-of-the-art vision models and practical deployment using PyTorch.',
        venue: 'CS Dept Auditorium - Hall A',
        startTime: now.add(const Duration(days: 2, hours: 3)),
        endTime: now.add(const Duration(days: 2, hours: 6)),
        category: 'Workshop',
        visibility: 'private',
        rsvpCount: 64,
        isRsvped: true,
      ),
      EventModel(
        id: 'evt_2',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        organizerName: 'CEG Sports Board',
        organizerType: 'college',
        title: 'Inter-Department Cricket Tournament 2024',
        description:
            'Knockout matches begin this Saturday. Come support your department teams at the main pavilion ground.',
        venue: 'Main Campus Cricket Pavilion',
        startTime: now.add(const Duration(days: 5, hours: 1)),
        endTime: now.add(const Duration(days: 5, hours: 8)),
        category: 'Sports',
        visibility: 'private',
        rsvpCount: 120,
      ),
      EventModel(
        id: 'evt_3',
        tenantId: 'anna_univ_global',
        collegeId: 'anna_univ_global',
        organizerName: 'Kurukshetra Tech Fest',
        organizerType: 'college',
        title: 'Kurukshetra 2024 International Techno-Management Fest',
        description:
            'UNESCO patronized international festival featuring robotics competitions, paper presentations, and guest lectures.',
        venue: 'Tagore Auditorium & Online',
        startTime: now.add(const Duration(days: 14)),
        endTime: now.add(const Duration(days: 17)),
        category: 'Technical',
        visibility: 'global',
        rsvpCount: 450,
      ),
    ]);
  }

  @override
  Future<List<EventModel>> getEvents(TenantContext tenant, {String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _events.where((e) {
      final matchesTenant = e.collegeId == tenant.collegeId || e.visibility == 'global';
      final matchesCategory = category == null || category == 'All' || e.category == category;
      return matchesTenant && matchesCategory;
    }).toList();
  }

  @override
  Future<void> toggleRsvp(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final evt = _events[index];
      _events[index] = evt.copyWith(
        isRsvped: !evt.isRsvped,
        rsvpCount: evt.isRsvped ? evt.rsvpCount - 1 : evt.rsvpCount + 1,
      );
    }
  }
}
