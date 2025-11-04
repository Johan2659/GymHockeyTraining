import 'package:url_launcher/url_launcher.dart';
import '../logging/logger_config.dart';

/// Service for handling YouTube video searches
/// Respects iOS and Android app store guidelines by:
/// - Using deep links to YouTube app
/// - Falling back to web browser if app not installed
/// - Not embedding videos directly (avoids YouTube API restrictions)
class YouTubeService {
  static final _logger = AppLogger.getLogger();

  /// Opens YouTube search for the given query
  /// 
  /// This method attempts to:
  /// 1. Open in YouTube app (if installed)
  /// 2. Fall back to YouTube website in browser
  /// 
  /// Returns true if successfully opened, false otherwise
  static Future<bool> searchYouTube(String query) async {
    if (query.isEmpty) {
      _logger.w('YouTubeService: Empty search query provided');
      return false;
    }

    try {
      // URL encode the search query
      final encodedQuery = Uri.encodeComponent(query);
      
      // Try YouTube app deep link first (works on both iOS and Android)
      final youtubeAppUrl = Uri.parse('youtube://results?search_query=$encodedQuery');
      
      _logger.d('YouTubeService: Attempting to open YouTube app with query: $query');
      
      // Check if YouTube app can be launched
      if (await canLaunchUrl(youtubeAppUrl)) {
        _logger.i('YouTubeService: Opening YouTube app');
        return await launchUrl(
          youtubeAppUrl,
          mode: LaunchMode.externalApplication,
        );
      }
      
      // Fallback to web browser
      final youtubeWebUrl = Uri.parse('https://www.youtube.com/results?search_query=$encodedQuery');
      
      _logger.d('YouTubeService: YouTube app not available, falling back to web');
      
      if (await canLaunchUrl(youtubeWebUrl)) {
        _logger.i('YouTubeService: Opening YouTube in browser');
        return await launchUrl(
          youtubeWebUrl,
          mode: LaunchMode.externalApplication,
        );
      }
      
      _logger.e('YouTubeService: Cannot launch YouTube URL');
      return false;
      
    } catch (e, stackTrace) {
      _logger.e(
        'YouTubeService: Failed to open YouTube search',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Opens a specific YouTube video by ID
  /// 
  /// This is useful if you have a specific video ID in the future
  static Future<bool> openVideo(String videoId) async {
    if (videoId.isEmpty) {
      _logger.w('YouTubeService: Empty video ID provided');
      return false;
    }

    try {
      // Try YouTube app deep link first
      final youtubeAppUrl = Uri.parse('youtube://watch?v=$videoId');
      
      _logger.d('YouTubeService: Attempting to open video: $videoId');
      
      if (await canLaunchUrl(youtubeAppUrl)) {
        _logger.i('YouTubeService: Opening video in YouTube app');
        return await launchUrl(
          youtubeAppUrl,
          mode: LaunchMode.externalApplication,
        );
      }
      
      // Fallback to web browser
      final youtubeWebUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');
      
      if (await canLaunchUrl(youtubeWebUrl)) {
        _logger.i('YouTubeService: Opening video in browser');
        return await launchUrl(
          youtubeWebUrl,
          mode: LaunchMode.externalApplication,
        );
      }
      
      _logger.e('YouTubeService: Cannot launch YouTube video URL');
      return false;
      
    } catch (e, stackTrace) {
      _logger.e(
        'YouTubeService: Failed to open YouTube video',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Validates if the device can open YouTube links
  static Future<bool> canOpenYouTube() async {
    try {
      // Check if we can open YouTube web at minimum
      final youtubeWebUrl = Uri.parse('https://www.youtube.com');
      return await canLaunchUrl(youtubeWebUrl);
    } catch (e) {
      _logger.e('YouTubeService: Error checking YouTube availability', error: e);
      return false;
    }
  }
}
