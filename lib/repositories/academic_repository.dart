import '../models/resource_model.dart';
import '../models/doubt_model.dart';
import '../models/tenant_context.dart';

abstract class AcademicRepository {
  Future<List<ResourceModel>> getResources(
    TenantContext tenant, {
    String? department,
    int? semester,
    String? type,
  });

  Future<List<DoubtModel>> getDoubts(
    TenantContext tenant, {
    String? department,
  });
}

class MockAcademicRepository implements AcademicRepository {
  final List<ResourceModel> _resources = [];
  final List<DoubtModel> _doubts = [];

  MockAcademicRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();

    _resources.addAll([
      ResourceModel(
        id: 'res_1',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        department: 'CSE',
        semester: 5,
        subjectCode: 'CS8591',
        subjectName: 'Computer Networks',
        title: 'Unit 1-5 Comprehensive Handwritten Lecture Notes',
        fileUrl: 'https://example.com/cn_notes.pdf',
        fileType: 'pdf',
        type: 'Notes',
        uploaderName: 'Prof. K. Vignesh',
        upvotes: 45,
        downloadsCount: 180,
        visibility: 'private',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      ResourceModel(
        id: 'res_2',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        department: 'CSE',
        semester: 5,
        subjectCode: 'CS8501',
        subjectName: 'Theory of Computation',
        title: 'Nov/Dec 2023 Solved Question Paper',
        fileUrl: 'https://example.com/toc_pyq.pdf',
        fileType: 'pdf',
        type: 'PYQs',
        uploaderName: 'Student Association CSE',
        upvotes: 78,
        downloadsCount: 310,
        visibility: 'private',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      ResourceModel(
        id: 'res_3',
        tenantId: 'anna_univ_global',
        collegeId: 'anna_univ_global',
        department: 'All',
        semester: 1,
        subjectCode: 'CY3151',
        subjectName: 'Engineering Chemistry',
        title: 'Regulation 2021 Official Anna University Syllabus Document',
        fileUrl: 'https://example.com/chem_syllabus.pdf',
        fileType: 'pdf',
        type: 'Syllabus',
        uploaderName: 'University Academic Cell',
        upvotes: 112,
        downloadsCount: 950,
        visibility: 'global',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ]);

    _doubts.addAll([
      DoubtModel(
        id: 'dbt_1',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        department: 'CSE',
        subjectName: 'Operating Systems',
        authorId: 'u_105',
        authorName: 'Sanjay V.',
        title: 'Difference between Banker\'s Algorithm and Wait-For Graph in Deadlock Detection?',
        body:
            'Can someone explain with an example when to prefer resource-allocation graph cycle detection over Banker\'s safety state algorithm during exam answers?',
        tags: ['OS', 'Deadlocks', 'Sem5'],
        answerCount: 4,
        isResolved: true,
        visibility: 'private',
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      DoubtModel(
        id: 'dbt_2',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        department: 'ECE',
        subjectName: 'Digital Signal Processing',
        authorId: 'u_106',
        authorName: 'Priya M.',
        title: 'DIT-FFT Butterfly diagram calculation doubt in Unit 3',
        body:
            'How do we derive twiddle factors for 8-point radix-2 DIT FFT without memorizing the full matrix?',
        tags: ['DSP', 'ECE', 'Sem4'],
        answerCount: 2,
        isResolved: false,
        visibility: 'private',
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
    ]);
  }

  @override
  Future<List<ResourceModel>> getResources(
    TenantContext tenant, {
    String? department,
    int? semester,
    String? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _resources.where((r) {
      final matchesTenant = r.collegeId == tenant.collegeId || r.visibility == 'global';
      final matchesDept = department == null || department == 'All' || r.department == department;
      final matchesSem = semester == null || r.semester == semester;
      final matchesType = type == null || type == 'All' || r.type == type;
      return matchesTenant && matchesDept && matchesSem && matchesType;
    }).toList();
  }

  @override
  Future<List<DoubtModel>> getDoubts(
    TenantContext tenant, {
    String? department,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _doubts.where((d) {
      final matchesTenant = d.collegeId == tenant.collegeId || d.visibility == 'global';
      final matchesDept = department == null || department == 'All' || d.department == department;
      return matchesTenant && matchesDept;
    }).toList();
  }
}
