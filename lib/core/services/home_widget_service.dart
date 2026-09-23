import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Platform channel bridge between Flutter and native Android/iOS home screen widgets.
class HomeWidgetService {
  HomeWidgetService({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('com.zemetia.pencatatan_keuangan/home_widget');

  final MethodChannel _channel;
  void Function(String route)? _routeCallback;

  /// Initializes listening for route navigation events triggered from home widget clicks.
  void initNavigationListener(void Function(String route) onNavigate) {
    _routeCallback = onNavigate;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNavigateRoute') {
        final route = call.arguments as String?;
        if (route != null && _routeCallback != null) {
          _routeCallback!(route);
        }
      }
    });
  }

  /// Updates the native home screen widget with current balance and subtitle text.
  Future<bool> updateWidgetData({
    required int balanceCents,
    required String formattedBalance,
    String? subtitle,
  }) async {
    try {
      final success = await _channel.invokeMethod<bool>('updateWidgetData', {
        'balance_text': formattedBalance,
        'subtitle_text': subtitle ?? 'Pencatatan Keuangan • Real-time',
      });
      return success ?? false;
    } on MissingPluginException {
      // Running on an unsupported platform (Web, Desktop, or Unit test)
      return false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Requests the OS launcher to pin the widget to the home screen (Android 8.0+).
  Future<bool> requestPinWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPinWidget');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the application was launched via a widget action intent.
  Future<String?> getInitialRoute() async {
    try {
      return await _channel.invokeMethod<String>('getInitialRoute');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }
}

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService();
});
