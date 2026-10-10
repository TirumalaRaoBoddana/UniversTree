class PostModel {
  final String id;
  final String tenantId;
  final String collegeId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String authorRole;
  final String? title;
  final String content;
  final List<String> mediaUrls;
  final String category;
  final String? departmentFilter;
  final String visibility; // 'private' | 'global'
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.tenantId,
    required this.collegeId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.authorRole,
    this.title,
    required this.content,
    this.mediaUrls = const [],
    required this.category,
    this.departmentFilter,
    required this.visibility,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      tenantId: map['tenant_id'] as String? ?? '',
      collegeId: map['college_id'] as String? ?? '',
      authorId: map['author_id'] as String? ?? '',
      authorName: map['author_name'] as String? ?? 'Anonymous',
      authorAvatar: map['author_avatar'] as String?,
      authorRole: map['author_role'] as String? ?? 'Student',
      title: map['title'] as String?,
      content: map['content'] as String? ?? '',
      mediaUrls: List<String>.from(map['media_urls'] as List? ?? []),
      category: map['category'] as String? ?? 'General',
      departmentFilter: map['department_filter'] as String?,
      visibility: map['visibility'] as String? ?? 'private',
      likeCount: (map['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (map['comment_count'] as num?)?.toInt() ?? 0,
      isLiked: map['is_liked'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenant_id': tenantId,
      'college_id': collegeId,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'author_role': authorRole,
      'title': title,
      'content': content,
      'media_urls': mediaUrls,
      'category': category,
      'department_filter': departmentFilter,
      'visibility': visibility,
      'like_count': likeCount,
      'comment_count': commentCount,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  PostModel copyWith({
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      tenantId: tenantId,
      collegeId: collegeId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorRole: authorRole,
      title: title,
      content: content,
      mediaUrls: mediaUrls,
      category: category,
      departmentFilter: departmentFilter,
      visibility: visibility,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}
