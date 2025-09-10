/// Local performance analytics data source
import 'package:hive/hive.dart';
import 'dart:convert';

import '../../core/models/models.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/services/logger_service.dart';

class LocalPerformanceSource {
  static const String _analyticsKey = 'performance_analytics';

  Future<PerformanceAnalytics?> getPerformanceAnalytics() async {
    try {
      final box = await _getBox();
      final data = box.get(_analyticsKey) as String?;
      
      if (data == null) return null;
      
      final json = jsonDecode(data) as Map<String, dynamic>;
      return PerformanceAnalytics.fromJson(json);
    } catch (e) {
      LoggerService.instance.error('Failed to get performance analytics from storage', 
        source: 'LocalPerformanceSource', error: e);
      return null;
    }
  }

  Future<void> savePerformanceAnalytics(PerformanceAnalytics analytics) async {
    try {
      final box = await _getBox();
      final json = analytics.toJson();
      await box.put(_analyticsKey, jsonEncode(json));
    } catch (e) {
      LoggerService.instance.error('Failed to save performance analytics to storage', 
        source: 'LocalPerformanceSource', error: e);
      rethrow;
    }
  }

  Stream<PerformanceAnalytics?> watchPerformanceAnalytics() {
    return Stream.fromFuture(_getBox()).asyncExpand((box) {
      return box.watch(key: _analyticsKey).map((_) {
        try {
          final data = box.get(_analyticsKey) as String?;
          if (data == null) return null;
          
          final json = jsonDecode(data) as Map<String, dynamic>;
          return PerformanceAnalytics.fromJson(json);
        } catch (e) {
          LoggerService.instance.error('Failed to watch performance analytics', 
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
