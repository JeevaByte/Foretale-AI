import 'dart:async';
import 'package:flutter/material.dart';

mixin PollingMixin on ChangeNotifier {
  Timer? _pollingTimer;
  bool _isPolling = false;
  Duration _pollingInterval = const Duration(seconds: 30);

  bool get isPolling => _isPolling;
  Duration get pollingInterval => _pollingInterval;
  bool _isFetching = false;

  /// Start polling with a list of fetch functions
  void startPollingMultiple(BuildContext context, List<Future<void> Function(BuildContext)> fetchFunctions) {
    if (!_isPolling) {
      _isPolling = true;
      _pollingTimer = Timer.periodic(_pollingInterval, (_) async {
        if (_isFetching) return;
        _isFetching = true;
        try {
          // Check if context is still mounted before calling fetch functions
          if (context.mounted) {
            // Execute all fetch functions concurrently
            await Future.wait(fetchFunctions.map((fetchFunction) => fetchFunction(context)));
          } else {
            debugPrint('Context no longer mounted, stopping polling');
            stopPolling();
          }
        } catch (e) {
          debugPrint('Polling error: $e');
          // If context is no longer mounted, stop polling
          if (!context.mounted) {
            stopPolling();
          }
        } finally {
          _isFetching = false;
        }
      });
      notifyListeners();
    }
  }

  /// Stop the polling
  void stopPolling() {
    if (_isPolling) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
      _isPolling = false;
      notifyListeners();
    }
  }

  /// Set a new polling interval
  void setPollingInterval(Duration interval) {
    _pollingInterval = interval;
    if (_isPolling) {
      stopPolling();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
} 