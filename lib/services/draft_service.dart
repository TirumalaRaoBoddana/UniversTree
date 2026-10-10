import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  static const String _draftKey = 'college_registration_draft_v1';

  static Future<void> saveDraft(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, jsonEncode(data));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftString = prefs.getString(_draftKey);
      if (draftString != null && draftString.isNotEmpty) {
        return jsonDecode(draftString) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }
}
