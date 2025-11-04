/// Local performance analytics data source
import 'package:hive/hive.dart';
import 'dart:convert';

import '../../core/models/models.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/services/logger_service.dart';

class LocalPerformanceSource {
  static const String _analyticsKeyPrefix = 'performance_analytics_';

  String _analyticsKey(String userId) => '$_analyticsKeyPrefix$userId';

  Future<PerformanceAnalytics?> getPerformanceAnalytics(String userId) async {
    try {
      final box = await _getBox();
      final key = _analyticsKey(userId);
      final data = box.get(key) as String?;

      if (data == null) return null;

      final json = jsonDecode(data) as Map<String, dynamic>;
      return PerformanceAnalytics.fromJson(json);
    } catch (e) {
      LoggerService.instance.error(
          'Failed to get performance analytics from storage for user $userId',
          source: 'LocalPerformanceSource',
          error: e);
      return null;
    }
  }

  Future<void> savePerformanceAnalytics(PerformanceAnalytics analytics) async {
    try {
      final box = await _getBox();
      final json = analytics.toJson();
      final key = _analyticsKey(analytics.userId);
      await box.put(key, jsonEncode(json));
    } catch (e) {
      LoggerService.instance.error(
          'Failed to save performance analytics to storage for user ${analytics.userId}',
          source: 'LocalPerformanceSource',
          error: e);
      rethrow;
    }
  }

  Stream<PerformanceAnalytics?> watchPerformanceAnalytics(String userId) {
    return Stream.fromFuture(_getBox()).asyncExpand((box) {
      final key = _analyticsKey(userId);
      return box.watch(key: key).map((_) {
        try {
          final data = box.get(key) as String?;
          if (data == null) return null;

          final json = jsonDecode(data) as Map<String, dynamic>;
          return PerformanceAnalytics.fromJson(json);
        } catch (e) {
          LoggerService.instance.error('Failed to watch performance analytics for user $userId',
              source: 'LocalPerformanceSource', error: e);
          return null;
        }
      });
    });
  }

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(HiveBoxes.profile)) {
      throw Exception('Profile box is not open');
    }
    return Hive.box(HiveBoxes.profile);
  }
}
