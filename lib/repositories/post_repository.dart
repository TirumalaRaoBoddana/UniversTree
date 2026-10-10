import '../models/post_model.dart';
import '../models/tenant_context.dart';

abstract class PostRepository {
  Future<List<PostModel>> getCampusFeed(TenantContext tenant, {String? category});
  Future<List<PostModel>> getGlobalFeed({String? category});
  Future<PostModel> createPost(PostModel post);
  Future<void> toggleLikePost(String postId);
}

class MockPostRepository implements PostRepository {
  final List<PostModel> _posts = [];

  MockPostRepository() {
    _seedData();
  }

  void _seedData() {
    _posts.addAll([
      PostModel(
        id: 'post_1',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        authorId: 'u_102',
        authorName: 'Dr. R. Ramanathan',
        authorRole: 'Head of Department',
        title: 'End-Semester Exam Schedule Released',
        content:
            'The end-semester practical and theory examination schedule for Nov/Dec 2024 has been uploaded to the academic portal. All students are advised to clear pending dues before hall ticket download.',
        category: 'Announcement',
        departmentFilter: 'CSE',
        visibility: 'private',
        likeCount: 42,
        commentCount: 18,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PostModel(
        id: 'post_2',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        authorId: 'u_103',
        authorName: 'Rotaract Club CEG',
        authorRole: 'Club Coordinator',
        title: 'Annual Blood Donation Camp 2024',
        content:
            'Join us at the Student Activity Centre tomorrow from 9:00 AM onwards for the annual blood drive in partnership with Rajiv Gandhi Govt Hospital.',
        category: 'Club',
        visibility: 'private',
        likeCount: 89,
        commentCount: 7,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PostModel(
        id: 'post_3',
        tenantId: 'mit_chennai',
        collegeId: 'mit_chennai',
        authorId: 'u_104',
        authorName: 'Inter-College Tech Fest Admin',
        authorRole: 'Organizing Committee',
        title: 'Hackathon 2024 - Open for All Tamil Nadu Colleges',
        content:
            'Registrations are officially open for Smart India Regional Hackathon! Prize pool of Rs. 1,50,000 up for grabs.',
        category: 'Achievement',
        visibility: 'global',
        likeCount: 156,
        commentCount: 34,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ]);
  }

  @override
  Future<List<PostModel>> getCampusFeed(TenantContext tenant, {String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _posts.where((p) {
      final matchesTenant = p.collegeId == tenant.collegeId || p.visibility == 'global';
      final matchesCategory = category == null || category == 'All' || p.category == category;
      return matchesTenant && matchesCategory;
    }).toList();
  }

  @override
  Future<List<PostModel>> getGlobalFeed({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _posts.where((p) {
      final matchesGlobal = p.visibility == 'global';
      final matchesCategory = category == null || category == 'All' || p.category == category;
      return matchesGlobal && matchesCategory;
    }).toList();
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    _posts.insert(0, post);
    return post;
  }

  @override
  Future<void> toggleLikePost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
      );
    }
  }
}
